"""Prove the retained-evidence guard rejects incomplete or altered claims."""

from __future__ import annotations

import copy
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "coverage_guard", ROOT / "scripts/check-capability-coverage.py"
)
assert SPEC is not None and SPEC.loader is not None
GUARD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GUARD)


class CapabilityCoverageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.temp = tempfile.TemporaryDirectory()
        cls.root = Path(cls.temp.name)
        cls.original = json.loads((ROOT / "docs/capability-coverage.json").read_text())
        files = set(cls.original["verification_tools"])
        files.add(cls.original["registry"]["snapshot"])
        for row in cls.original["systems"]:
            files.add(row["record"])
            files.update(json.loads((ROOT / row["record"]).read_text())["sources"])
            files.update(row["captures"])
            if row["sound"]["status"] == "executed":
                files.add(row["sound"]["excerpt"])
        for name in files:
            target = cls.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, target)
        # Records that list their programs are rebuilt by their recorders.
        shutil.copytree(
            ROOT / "scripts",
            cls.root / "scripts",
            dirs_exist_ok=True,
            ignore=shutil.ignore_patterns("__pycache__"),
        )

    @classmethod
    def tearDownClass(cls) -> None:
        cls.temp.cleanup()

    def setUp(self) -> None:
        self.manifest = copy.deepcopy(self.original)
        # Rebuilds are cached per build; these tests change the sources.
        GUARD.E.rebuild.cache_clear()

    def test_complete_evidence_passes(self) -> None:
        result = GUARD.validate(self.root, self.manifest)
        self.assertEqual(result["machines"], 30)
        self.assertEqual(result["sound_executed"], 28)

    def test_empty_inventory_fails(self) -> None:
        self.manifest["systems"] = []
        with self.assertRaisesRegex(ValueError, "Empty capability"):
            GUARD.validate(self.root, self.manifest)

    def test_missing_machine_fails(self) -> None:
        self.manifest["systems"].pop()
        with self.assertRaisesRegex(ValueError, "exact registry"):
            GUARD.validate(self.root, self.manifest)

    def test_dropping_machine_from_both_inventories_fails(self) -> None:
        machine = self.manifest["systems"].pop()["machine_id"]
        self.manifest["registry"]["systems"] = [
            r
            for r in self.manifest["registry"]["systems"]
            if r["machine_id"] != machine
        ]
        with self.assertRaisesRegex(ValueError, "Pinned registry membership"):
            GUARD.validate(self.root, self.manifest)

    def test_wrong_executable_fails(self) -> None:
        self.manifest["emulator_builds"]["acorn-atom"]["sha256"] = "incorrect"
        with self.assertRaisesRegex(ValueError, "Wrong executable"):
            GUARD.validate(self.root, self.manifest)

    def test_invented_stock_sound_fails(self) -> None:
        row = next(
            r for r in self.manifest["systems"] if r["machine_id"] == "sinclair-zx80"
        )
        row["sound"]["status"] = "executed"
        with self.assertRaisesRegex(ValueError, "Invented stock sound"):
            GUARD.validate(self.root, self.manifest)

    def test_missing_negative_control_fails(self) -> None:
        row = next(r for r in self.manifest["systems"] if r["kind"] == "hardware")
        path = self.root / row["record"]
        saved = path.read_bytes()
        record = json.loads(saved)
        record["negative_controls"]["sound"]["same_guard_rejected"] = False
        try:
            path.write_text(json.dumps(record))
            row["record_sha256"] = GUARD.sha(path)
            with self.assertRaisesRegex(ValueError, "Missing independent negatives"):
                GUARD.validate(self.root, self.manifest)
        finally:
            path.write_bytes(saved)

    def test_changed_source_fails(self) -> None:
        row = self.manifest["systems"][0]
        record = json.loads((self.root / row["record"]).read_text())
        path = self.root / next(iter(record["sources"]))
        saved = path.read_bytes()
        try:
            path.write_bytes(saved + b"\nREM altered\n")
            with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
                GUARD.validate(self.root, self.manifest)
        finally:
            path.write_bytes(saved)

    def rebuilt_row(self) -> dict:
        return next(
            r
            for r in self.manifest["systems"]
            if r["machine_id"] == "coleco-colecovision"
        )

    def edit_source(self, row: dict, old: str, new: str) -> None:
        path = self.root / row["path"] / "demo.asm"
        text = path.read_text()
        self.assertEqual(text.count(old), 1)
        path.write_text(text.replace(old, new))

    def restore_sources(self, row: dict) -> None:
        for name in ("demo.asm", "picture.inc", "sound.inc"):
            shutil.copy2(ROOT / row["path"] / name, self.root / row["path"] / name)

    def test_rebuilt_program_ignores_a_comment(self) -> None:
        row = self.rebuilt_row()
        try:
            self.edit_source(
                row, "    call draw_picture", "    call draw_picture ; draw it"
            )
            GUARD.validate(self.root, self.manifest)
        finally:
            self.restore_sources(row)

    def test_rebuilt_program_with_a_changed_operand_fails(self) -> None:
        row = self.rebuilt_row()
        path = self.root / row["path"] / "picture.inc"
        text = path.read_text()
        self.assertEqual(text.count("    ld a,$9f"), 1)
        try:
            path.write_text(text.replace("    ld a,$9f", "    ld a,$9e"))
            with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
                GUARD.validate(self.root, self.manifest)
        finally:
            self.restore_sources(row)

    def test_forged_program_digest_fails(self) -> None:
        row = self.rebuilt_row()
        path = self.root / row["record"]
        saved = path.read_bytes()
        record = json.loads(saved)
        record["programs"]["sound.cv"] = "0" * 64
        try:
            path.write_text(json.dumps(record))
            row["record_sha256"] = GUARD.sha(path)
            with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
                GUARD.validate(self.root, self.manifest)
        finally:
            path.write_bytes(saved)

    def test_tampered_record_fails(self) -> None:
        row = self.rebuilt_row()
        path = self.root / row["record"]
        saved = path.read_bytes()
        try:
            path.write_bytes(saved.replace(b'"passed"', b'"passed" ', 1))
            with self.assertRaisesRegex(ValueError, "Changed file"):
                GUARD.validate(self.root, self.manifest)
        finally:
            path.write_bytes(saved)

    def test_rebuilt_records_name_released_tools_without_local_paths(self) -> None:
        rebuilt = 0
        for row in self.original["systems"]:
            record = json.loads((ROOT / row["record"]).read_text())
            if "programs" not in record:
                continue
            rebuilt += 1
            self.assertIn(row["kind"], GUARD.RECORDERS)
            assembler = record["tools"]["assembler"]
            self.assertEqual(assembler["executable_sha256"], record["assembler_sha256"])
            self.assertTrue(assembler["release"].startswith("https://github.com/"))
            emulator = record["tools"]["emulator"]
            self.assertEqual(emulator["executable_sha256"], record["emulator_sha256"])
            self.assertTrue(emulator["release"].startswith("https://github.com/"))
            for tool in record["tools"].values():
                for value in tool.values():
                    self.assertFalse(value.startswith("/"), value)
        self.assertGreater(rebuilt, 0)

    def test_missing_picture_fails(self) -> None:
        row = self.manifest["systems"][0]
        path = self.root / next(iter(row["captures"]))
        saved = path.read_bytes()
        try:
            path.unlink()
            with self.assertRaisesRegex(ValueError, "Missing/empty file"):
                GUARD.validate(self.root, self.manifest)
        finally:
            path.write_bytes(saved)


if __name__ == "__main__":
    unittest.main()
