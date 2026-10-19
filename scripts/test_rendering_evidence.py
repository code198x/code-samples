"""A changed source, capture or missing workload must not retain a green claim."""

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


class RenderingEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.record = json.loads(
            (ROOT / "docs/rendering-families/verification/results.json").read_text()
        )
        paths = (
            G.REQUIRED
            | {"scripts/verify-rendering-families.py"}
            | {
                "docs/rendering-families/verification/" + n
                for n in self.record["captures"]
            }
        )
        for path in paths:
            target = self.root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / path, target)

    def test_current_bindings_pass(self) -> None:
        G.validate(self.root, self.record)

    def test_changed_implementation_or_shared_dependency_fails(self) -> None:
        for path in [
            G.PREFIXES["sp"] + "scroll.inc",
            "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
        ]:
            with self.subTest(path=path):
                p = self.root / path
                old = p.read_bytes()
                p.write_bytes(old + b"; changed\n")
                with self.assertRaisesRegex(ValueError, "Changed rendering source"):
                    G.validate(self.root, self.record)
                p.write_bytes(old)

    def test_changed_observer_or_capture_fails(self) -> None:
        for path in [
            "scripts/verify-rendering-families.py",
            "docs/rendering-families/verification/nes.png",
        ]:
            with self.subTest(path=path):
                p = self.root / path
                old = p.read_bytes()
                p.write_bytes(old + b"changed")
                with self.assertRaisesRegex(ValueError, "Changed"):
                    G.validate(self.root, self.record)
                p.write_bytes(old)

    def test_missing_or_failed_workload_cannot_stay_green(self) -> None:
        for change in ["failed", "empty", "control", "source", "capture"]:
            with self.subTest(change=change):
                record = copy.deepcopy(self.record)
                if change == "failed":
                    record["status"] = "failed"
                elif change == "empty":
                    record["routine_cases"]["bbc"] = 0
                elif change == "control":
                    record["mutants_rejected"].remove("nes")
                elif change == "source":
                    record["sources"].pop(next(iter(G.REQUIRED)))
                else:
                    record["captures"].pop("bbc.png")
                with self.assertRaises(ValueError):
                    G.validate(self.root, record)


if __name__ == "__main__":
    unittest.main()
