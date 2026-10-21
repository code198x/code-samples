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


class EvidenceTests(unittest.TestCase):
    def test_current(self):
        self.assertGreater(C.validate(), 0)

    def test_corruptions(self):
        for fault in [
            "destination",
            "completion",
            "source",
            "capture",
            "missing-control",
        ]:
            with self.subTest(fault=fault), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                shutil.copytree(C.SHARED, root / C.SHARED.relative_to(C.ROOT))
                for c in json.loads((C.SHARED / "systems.json").read_text()):
                    relative = (
                        Path(c["id"]) / "patterns/assembly/rendering/fixed-characters"
                    )
                    shutil.copytree(
                        C.ROOT / relative,
                        root / relative,
                        ignore=shutil.ignore_patterns("build"),
                    )
                (root / "scripts").mkdir()
                shutil.copy(
                    C.ROOT / "scripts/verify-fixed-characters.py", root / "scripts"
                )
                out = (
                    root
                    / "commodore-pet/patterns/assembly/rendering/fixed-characters/verification"
                )
                record = json.loads((out / "positive.json").read_text())
                if fault == "destination":
                    p = out / "positive.bin"
                    b = bytearray(p.read_bytes())
                    b[85] ^= 1
                    p.write_bytes(b)
                    record["memory_sha256"] = C.sha(p)
                elif fault == "completion":
                    record["flags"][-1] = 0
                elif fault == "source":
                    (out.parent / "characters.inc").write_text("; wrong routine\n")
                elif fault == "capture":
                    (out / "positive.png").write_bytes(b"not a PNG")
                else:
                    (out / "wrong-stride.json").unlink()
                (out / "positive.json").write_text(json.dumps(record))
                summary = json.loads((out / "results.json").read_text())
                summary["records"][0] = record
                (out / "results.json").write_text(json.dumps(summary))
                with self.assertRaises((AssertionError, FileNotFoundError)):
                    C.validate(root)


if __name__ == "__main__":
    unittest.main()
