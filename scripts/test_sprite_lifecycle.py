"""A stale or incomplete workload cannot keep a passing lifecycle record."""

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
    "guard", ROOT / "scripts/check-sprite-lifecycle.py"
)
assert spec and spec.loader
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)


class LifecycleEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.record = json.loads(
            (ROOT / "docs/sprite-lifecycle/verification/results.json").read_text()
        )
        paths = (
            G.REQUIRED
            | {"scripts/verify-sprite-lifecycle.py"}
            | {
                "docs/sprite-lifecycle/verification/" + name
                for name in self.record["captures"]
            }
        )
        for name in paths:
            target = self.root / name
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, target)

    def test_unchanged_evidence_passes(self) -> None:
        G.validate(self.root, self.record)

    def test_changed_code_or_shared_renderer_is_stale(self) -> None:
        for name in [
            "commodore-amiga/patterns/assembly/rendering/sprite-lifecycle/bob.inc",
            "sinclair-zx-spectrum/patterns/assembly/rendering/masked-sprites/masked.inc",
        ]:
            with self.subTest(name=name):
                p = self.root / name
                old = p.read_bytes()
                p.write_bytes(old + b"; changed\n")
                with self.assertRaisesRegex(ValueError, "Changed lifecycle source"):
                    G.validate(self.root, self.record)
                p.write_bytes(old)

    def test_changed_observer_or_capture_is_stale(self) -> None:
        for name in [
            "scripts/verify-sprite-lifecycle.py",
            "docs/sprite-lifecycle/verification/amiga.png",
        ]:
            with self.subTest(name=name):
                p = self.root / name
                old = p.read_bytes()
                p.write_bytes(old + b"changed")
                with self.assertRaisesRegex(ValueError, "Changed lifecycle"):
                    G.validate(self.root, self.record)
                p.write_bytes(old)

    def test_missing_or_failed_workload_is_rejected(self) -> None:
        for change in ["status", "empty", "control", "source", "capture"]:
            with self.subTest(change=change):
                record = copy.deepcopy(self.record)
                if change == "status":
                    record["status"] = "failed"
                elif change == "empty":
                    record["cases"]["amiga"]["overlaps"] = 0
                elif change == "control":
                    record["rejected_controls"].pop("bbc-order")
                elif change == "source":
                    record["sources"].pop(next(iter(G.REQUIRED)))
                else:
                    record["captures"].pop("amiga.png")
                with self.assertRaises(ValueError):
                    G.validate(self.root, record)


if __name__ == "__main__":
    unittest.main()
