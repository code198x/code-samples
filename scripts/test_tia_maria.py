"""Corruption must turn the retained-evidence gate red."""

from __future__ import annotations

import importlib.util
import shutil
import tempfile
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "records", Path(__file__).with_name("check-tia-maria-records.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class RetainedEvidence(unittest.TestCase):
    def test_real_records(self) -> None:
        self.assertEqual(C.validate(), 8)

    def test_each_bound_file_is_checked(self) -> None:
        import json

        bindings = json.loads((C.ROOT / C.SHARED / "bindings.json").read_text())
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for relative in bindings:
                dest = root / relative
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(C.ROOT / relative, dest)
            for machine, (name, _) in C.V.CONFIG.items():
                relative = (
                    Path(machine)
                    / "patterns/assembly/rendering"
                    / name
                    / "verification"
                )
                shutil.copytree(C.ROOT / relative, root / relative, dirs_exist_ok=True)
            shutil.copyfile(
                C.ROOT / C.SHARED / "bindings.json", root / C.SHARED / "bindings.json"
            )
            self.assertEqual(C.validate(root), 8)
            for relative in bindings:
                p = root / relative
                original = p.read_bytes()
                p.write_bytes(original + b"corrupt")
                with self.subTest(relative=relative), self.assertRaises(AssertionError):
                    C.validate(root)
                p.write_bytes(original)


if __name__ == "__main__":
    unittest.main()
