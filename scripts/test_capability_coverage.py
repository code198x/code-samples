"""Prove the retained-evidence guard rejects incomplete or altered claims."""

from __future__ import annotations

import copy
import importlib.util
import json
import shutil
import tempfile
import unittest
from argparse import Namespace
from pathlib import Path
from unittest.mock import patch

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


class RebuiltCompositionProgramTests(unittest.TestCase):
    setUpClass = classmethod(CapabilityCoverageTests.setUpClass.__func__)
    tearDownClass = classmethod(CapabilityCoverageTests.tearDownClass.__func__)
    setUp = CapabilityCoverageTests.setUp

    def rebuilt_row(self) -> dict:
        """The Amiga composition, whose disk is also built by build198x."""
        return next(
            r for r in self.manifest["systems"] if r["machine_id"] == "commodore-amiga"
        )

    def edit(self, row: dict, name: str, old: str, new: str) -> Path:
        path = self.root / Path(row["record"]).parent.parent / name
        text = path.read_text()
        self.assertEqual(text.count(old), 1)
        path.write_text(text.replace(old, new))
        self.addCleanup(path.write_text, text)
        return path

    def test_rebuilt_program_ignores_a_comment(self) -> None:
        row = self.rebuilt_row()
        self.edit(
            row,
            "demo.asm",
            '    include "rules.inc"',
            '    include "rules.inc" ; rules',
        )
        GUARD.validate(self.root, self.manifest)

    def test_rebuilt_program_with_a_changed_operand_fails(self) -> None:
        row = self.rebuilt_row()
        self.edit(row, "rules.inc", "    move.w #2,player_x", "    move.w #3,player_x")
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            GUARD.validate(self.root, self.manifest)

    def test_forged_program_digest_fails(self) -> None:
        row = self.rebuilt_row()
        path = self.root / row["record"]
        saved = path.read_bytes()
        record = json.loads(saved)
        record["programs"]["demo.adf"] = "0" * 64
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
            tools = record["tools"]
            self.assertEqual(
                tools["assembler"]["executable_sha256"], record["assembler_sha256"]
            )
            self.assertEqual(
                tools["emulator"]["executable_sha256"], record["emulator_sha256"]
            )
            if "build198x_sha256" in record:
                self.assertEqual(
                    tools["build198x"]["executable_sha256"],
                    record["build198x_sha256"],
                )
            for tool in tools.values():
                self.assertTrue(tool["release"].startswith("https://github.com/"))
                for value in tool.values():
                    self.assertFalse(value.startswith("/"), value)
        self.assertGreater(rebuilt, 0)

    def test_programs_without_a_recorder_fail(self) -> None:
        row = self.rebuilt_row()
        record = json.loads((self.root / row["record"]).read_text())
        with self.assertRaisesRegex(ValueError, "No recorder"):
            GUARD.require_program(self.root, row["machine_id"], record, "unregistered")


class FreshGameLoopRecorderTests(unittest.TestCase):
    def recorder(self):
        spec = importlib.util.spec_from_file_location(
            "fresh_game_loop", ROOT / "scripts/verify-game-loops.py"
        )
        assert spec is not None and spec.loader is not None
        recorder = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(recorder)
        return recorder

    def test_fresh_tree_builds_symbols_before_starting_emulator(self) -> None:
        recorder = self.recorder()
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            folder = root / "bbc-micro/patterns/assembly/framework/game-loop"
            folder.mkdir(parents=True)
            args = Namespace(
                assembler="assembler", build198x="builder", native=root,
                firmware_root=root, bbc_basic=root / "basic.rom",
            )

            def build(name, assembler, builder, out):
                self.assertEqual((name, assembler, builder),
                                 ("bbc", "assembler", "builder"))
                self.assertFalse((folder / "build").exists())
                (folder / "build").mkdir()
                (folder / "build/demo.sym").write_text("updates = $3000\n")
                return {}

            def start(command):
                self.assertTrue((folder / "build/verification").is_dir())
                raise RuntimeError("stop before emulator execution")

            with (
                patch.object(recorder, "ROOT", root),
                patch.object(recorder, "build", side_effect=build) as built,
                patch.object(recorder, "Machine", side_effect=start) as machine,
                self.assertRaisesRegex(RuntimeError, "stop before emulator execution"),
            ):
                recorder.run("bbc", args)
            built.assert_called_once()
            machine.assert_called_once()

    def test_failed_build_propagates_before_symbol_read_or_emulator(self) -> None:
        recorder = self.recorder()
        failure = RuntimeError("assembler failed")
        with (
            tempfile.TemporaryDirectory() as directory,
            patch.object(recorder, "ROOT", Path(directory)),
            patch.object(recorder, "build", side_effect=failure) as built,
            patch.object(recorder, "symbols") as symbols,
            patch.object(recorder, "Machine") as machine,
        ):
            with self.assertRaises(RuntimeError) as caught:
                recorder.run("bbc", Namespace(assembler="assembler", build198x="builder"))
            self.assertIs(caught.exception, failure)
            built.assert_called_once()
            symbols.assert_not_called()
            machine.assert_not_called()


if __name__ == "__main__":
    unittest.main()
