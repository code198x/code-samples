"""Retained checks reject altered evidence even after its hashes are updated."""

from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-fixed-characters.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)

PET = "commodore-pet/patterns/assembly/rendering/fixed-characters"
ZX81 = "sinclair-zx81/patterns/assembly/rendering/fixed-characters"


def copy_root(root: Path) -> None:
    """Copy everything the checker reads and the recorder's build() needs.

    Rebuilds are cached by folder, so each test edits its own copy.
    """
    shutil.copytree(C.SHARED, root / C.SHARED.relative_to(C.ROOT))
    for c in json.loads((C.SHARED / "systems.json").read_text()):
        relative = Path(c["id"]) / "patterns/assembly/rendering/fixed-characters"
        shutil.copytree(
            C.ROOT / relative, root / relative, ignore=shutil.ignore_patterns("build")
        )
    (root / "scripts").mkdir()
    for name in [
        "verify-fixed-characters.py",
        "verify-game-loops.py",
        "verify-tilemaps.py",
    ]:
        shutil.copy(C.ROOT / "scripts" / name, root / "scripts")


def save(out: Path, variant: str, record: dict) -> None:
    """Write a variant record and its copy in results.json consistently."""
    (out / (variant + ".json")).write_text(json.dumps(record))
    summary = json.loads((out / "results.json").read_text())
    summary["records"][["positive", "wrong-stride", "unsafe-count"].index(variant)] = (
        record
    )
    (out / "results.json").write_text(json.dumps(summary))


class EvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.root = Path(temp.name)
        copy_root(self.root)

    def test_current(self):
        self.assertGreater(C.validate(), 0)

    def test_comment_only_change_still_matches(self):
        p = self.root / PET / "characters.inc"
        p.write_text(p.read_text() + "; a comment changes no program byte\n")
        self.assertGreater(C.validate(self.root), 0)

    def test_changed_operand_is_stale(self):
        p = self.root / PET / "characters.inc"
        text = p.read_text()
        self.assertEqual(text.count("adc #40"), 1)
        p.write_text(text.replace("adc #40", "adc #41"))
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.validate(self.root)

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        out = self.root / PET / "verification"
        record = json.loads((out / "wrong-stride.json").read_text())
        record["fixture_sha256"] = record["fixture_sha256"][::-1]
        save(out, "wrong-stride", record)
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.validate(self.root)

    def test_source_digests_are_provenance(self):
        """Changed assembly source or script digests alone do not make a record stale."""
        out = self.root / PET / "verification"
        record = json.loads((out / "positive.json").read_text())
        record["sources"] = dict.fromkeys(record["sources"], "0" * 64)
        save(out, "positive", record)
        self.assertGreater(C.validate(self.root), 0)

    def test_typed_caller_text_is_the_program(self):
        """The ZX81 caller is typed in, so even its text is the program (rule 2)."""
        p = self.root / ZX81 / "caller.bas"
        p.write_text(p.read_text() + "\n")
        with self.assertRaisesRegex(AssertionError, "Typed caller differs"):
            C.validate(self.root)

    def test_corruptions(self):
        for fault in ["destination", "completion", "capture", "missing-control"]:
            with self.subTest(fault=fault):
                root = self.root / fault
                copy_root(root)
                out = root / PET / "verification"
                record = json.loads((out / "positive.json").read_text())
                if fault == "destination":
                    p = out / "positive.bin"
                    b = bytearray(p.read_bytes())
                    b[85] ^= 1
                    p.write_bytes(b)
                    record["memory_sha256"] = C.sha(p)
                elif fault == "completion":
                    record["flags"][-1] = 0
                elif fault == "capture":
                    (out / "positive.png").write_bytes(b"not a PNG")
                else:
                    (out / "wrong-stride.json").unlink()
                save(out, "positive", record)
                with self.assertRaises((AssertionError, FileNotFoundError)):
                    C.validate(root)


if __name__ == "__main__":
    unittest.main()
