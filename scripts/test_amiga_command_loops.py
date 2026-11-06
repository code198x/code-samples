"""Falsified claims, missing observations and changed pixels must go red."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-amiga-command-loops.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class Records(unittest.TestCase):
    def setUp(self) -> None:
        self.folder = C.ROOT / "commodore-amiga/patterns/amos/framework/command-loop"
        self.record = json.loads(
            (self.folder / "verification/results.json").read_text()
        )

    def test_identity_controls(self) -> None:
        for key, value in [
            ("language", "blitz"),
            ("machine_id", "commodore-64"),
            ("status", "passed"),
            ("configuration", "NTSC A500"),
            ("release", "old"),
            ("emulator_sha256", "0" * 64),
            ("firmware_sha256", "0" * 64),
            ("runtime", "AmiBlitz/PED"),
            ("runtime_media_sha256", {}),
            ("sources", {}),
            ("variants", {}),
        ]:
            with self.subTest(key=key):
                record = copy.deepcopy(self.record)
                record[key] = value
                with self.assertRaises(ValueError):
                    C.check("amos", record=record)

    def test_missing_capture(self) -> None:
        record = copy.deepcopy(self.record)
        record["variants"]["working"]["captures"].pop()
        with self.assertRaisesRegex(ValueError, "captures"):
            C.check("amos", record=record)

    def test_missing_phase(self) -> None:
        record = copy.deepcopy(self.record)
        name = next(n for n in record["sources"] if "/phases/" in n)
        del record["sources"][name]
        with self.assertRaisesRegex(ValueError, "bindings"):
            C.check("amos", record=record)

    def test_rehashed_wrong_native_value(self) -> None:
        with tempfile.TemporaryDirectory(prefix="amiga-loop-control-") as temp:
            root = Path(temp)
            record = copy.deepcopy(self.record)
            for relative in record["sources"]:
                dest = root / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(C.ROOT / relative, dest)
            out = root / self.folder.relative_to(C.ROOT) / "verification"
            for name in record["artifacts"]:
                shutil.copy2(self.folder / "verification" / name, out / name)
            target = record["variants"]["working"]["captures"][0]
            wrong = record["variants"]["wrong"]["captures"][-1]
            shutil.copy2(out / wrong, out / target)
            record["artifacts"][target] = hashlib.sha256(
                (out / target).read_bytes()
            ).hexdigest()
            with self.assertRaisesRegex(ValueError, "Native amos/working"):
                C.check("amos", root=root, record=record)

    def test_forged_case_disk_is_rebuilt(self) -> None:
        """A record claiming another AMOS disk is caught only by the rebuild."""
        out = self.folder / "verification"
        toolchain = json.loads((out / "toolchain.json").read_text())
        toolchain["source_fixture_sha256"] = "0" * 64
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.require_programs("amos", out, toolchain)

    def test_forged_blitz_typing_is_regenerated(self) -> None:
        """A phase that typed another program is caught only by the regeneration."""
        folder = C.ROOT / "commodore-amiga/patterns/blitz/framework/command-loop"
        toolchain = json.loads((folder / "verification/toolchain.json").read_text())
        with tempfile.TemporaryDirectory(prefix="amiga-loop-blitz-") as temp:
            out = Path(temp)
            shutil.copytree(folder / "verification/phases", out / "phases")
            phase = out / "phases/blitz-working-case.json"
            steps = json.loads(phase.read_text())
            typed = next(s for s in steps if s["action"] == "type_string")
            typed["text"] = typed["text"].replace("=1", "=2")
            phase.write_text(json.dumps(steps))
            with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
                C.require_programs("blitz", out, toolchain)

    def test_source_digests_are_provenance(self) -> None:
        """Rewritten script and lesson-file digests leave the evidence valid."""
        for language in ["amos", "blitz"]:
            folder = C.ROOT / f"commodore-amiga/patterns/{language}"
            record = json.loads(
                (
                    folder / "framework/command-loop/verification/results.json"
                ).read_text()
            )
            record["sources"] = {
                name: digest if "/phases/" in name else "0" * 64
                for name, digest in record["sources"].items()
            }
            with self.subTest(language=language):
                C.check(language, record=record)

    def test_arithmetic_boundaries(self) -> None:
        self.assertEqual(C.expected("wrap"), [254, 255, 255, 0])
        self.assertEqual(C.expected("nonzero"), [100, 99, 99, 98])
        self.assertNotEqual(C.expected("wrong"), C.expected("working"))


if __name__ == "__main__":
    unittest.main()
