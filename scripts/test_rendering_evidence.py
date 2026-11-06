"""Rendering evidence is stale when a rebuilt program's bytes change."""

from __future__ import annotations

import copy
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "guard", ROOT / "scripts/check-rendering-evidence.py"
)
assert spec and spec.loader
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)

# Everything the recorder's programs() and the callers' Makefiles read.
SCRIPTS = [
    "verify-rendering-families.py",
    "verify-game-loops.py",
    "verify-z80-library-routines.py",
]
FOLDERS = [
    "sinclair-zx-spectrum/patterns/assembly/rendering/software-scrolling",
    "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing",
    "nintendo-entertainment-system/patterns/assembly/rendering/nametable-scrolling",
    "nintendo-entertainment-system/patterns/assembly/rendering/multi-sprite-oam",
    "bbc-micro/patterns/assembly/rendering/masked-sprites",
]
# A source the pinned programs are built from, and an operand change in it.
SOURCE = (
    "sinclair-zx-spectrum/patterns/assembly/rendering/software-scrolling/scroll.inc"
)
OPERAND = ("    or 31\n", "    or 30\n")


class RenderingEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        # Rebuilds are cached by folder, so each test edits its own copy.
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.record = json.loads((ROOT / G.EVIDENCE / "results.json").read_text())
        for name in SCRIPTS:
            (self.root / "scripts").mkdir(exist_ok=True)
            shutil.copy2(ROOT / "scripts" / name, self.root / "scripts" / name)
        for name in [*FOLDERS, G.EVIDENCE]:
            shutil.copytree(
                ROOT / name,
                self.root / name,
                ignore=shutil.ignore_patterns("build"),
            )

    def test_unchanged_evidence_passes(self) -> None:
        G.validate(ROOT, self.record)

    def test_comment_only_change_still_matches(self) -> None:
        p = self.root / SOURCE
        p.write_text(p.read_text() + "; a comment changes no program byte\n")
        G.validate(self.root, self.record)

    def test_changed_operand_is_stale(self) -> None:
        p = self.root / SOURCE
        text = p.read_text()
        self.assertEqual(text.count(OPERAND[0]), 1)
        p.write_text(text.replace(*OPERAND))
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            G.validate(self.root, self.record)

    def test_changed_capture_is_stale(self) -> None:
        p = self.root / G.EVIDENCE / "bbc.png"
        p.write_bytes(p.read_bytes() + b"changed")
        with self.assertRaisesRegex(ValueError, "Changed .*capture"):
            G.validate(self.root, self.record)

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""
        for key in ["fixture_programs", "caller_programs"]:
            with self.subTest(key=key):
                record = copy.deepcopy(self.record)
                name = min(record[key])
                record[key][name] = record[key][name][::-1]
                with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
                    G.validate(ROOT, record)

    def test_source_digests_are_provenance(self) -> None:
        """Changed source text or observer digests alone do not make a record stale."""
        record = copy.deepcopy(self.record)
        record["sources"] = dict.fromkeys(list(record["sources"])[1:], "0" * 64)
        record["observer_sha256"] = "0" * 64
        G.validate(ROOT, record)

    def test_missing_or_failed_workload_is_rejected(self) -> None:
        for change in ["status", "empty", "control", "program", "capture"]:
            with self.subTest(change=change):
                record = copy.deepcopy(self.record)
                if change == "status":
                    record["status"] = "failed"
                elif change == "empty":
                    record["routine_cases"]["bbc"] = 0
                elif change == "control":
                    record["mutants_rejected"].remove("nes")
                elif change == "program":
                    record["fixture_programs"].pop(min(record["fixture_programs"]))
                else:
                    record["captures"].pop("bbc.png")
                with self.assertRaises(ValueError):
                    G.validate(ROOT, record)


if __name__ == "__main__":
    unittest.main()
