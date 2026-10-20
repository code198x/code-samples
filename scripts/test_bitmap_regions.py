"""Prove malformed or unexecuted bitmap evidence cannot pass the retained gate."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "bitmap_guard", ROOT / "scripts/check-bitmap-regions.py"
)
assert spec and spec.loader
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)


class BitmapEvidenceFailures(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        files = {
            "scripts/check-bitmap-regions.py",
            "docs/tilemaps/coverage.json",
            "docs/capability-coverage.json",
        }
        configs = json.loads(
            (
                ROOT / "cross-platform/patterns/rendering/bitmap-regions/systems.json"
            ).read_text()
        )
        self.first = configs[0]
        for c in configs:
            v = (
                ROOT
                / c["folder"]
                / "patterns/assembly/rendering/tile-region/verification"
            )
            files.update(str(p.relative_to(ROOT)) for p in v.iterdir() if p.is_file())
            files.update(json.loads((v / "results.json").read_text())["sources"])
        for f in files:
            p = self.root / f
            p.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / f, p)
        self.v = (
            self.root
            / self.first["folder"]
            / "patterns/assembly/rendering/tile-region/verification"
        )

    def tearDown(self) -> None:
        self.temp.cleanup()

    def save(self, name: str, d: dict) -> None:
        (self.v / name).write_text(json.dumps(d))

    def refresh(self) -> None:
        record = json.loads((self.v / "results.json").read_text())
        record["files"] = {
            name: hashlib.sha256((self.v / name).read_bytes()).hexdigest()
            for name in record["files"]
        }
        self.save("results.json", record)

    def test_unchanged_evidence_passes(self) -> None:
        self.assertEqual(G.verify(self.root), 4)

    def test_changed_kernel_fails(self) -> None:
        p = self.root / "cross-platform/patterns/rendering/bitmap-regions/6502.inc"
        p.write_text(p.read_text() + "; changed\n")
        with self.assertRaisesRegex(AssertionError, "Changed source"):
            G.verify(self.root)

    def test_missing_evidence_file_fails(self) -> None:
        r = json.loads((self.v / "results.json").read_text())
        r["files"].pop("reject-3.bin")
        self.save("results.json", r)
        with self.assertRaisesRegex(AssertionError, "Missing evidence"):
            G.verify(self.root)

    def test_zero_rejection_marker_fails(self) -> None:
        r = json.loads((self.v / "reject-3.json").read_text())
        r["flags"][4] = 0
        self.save("reject-3.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "Isolated rejection"):
            G.verify(self.root)

    def test_guard_corruption_with_updated_hashes_fails(self) -> None:
        p = self.v / "reject-3.bin"
        d = bytearray(p.read_bytes())
        d[0] ^= 1
        p.write_bytes(d)
        r = json.loads((self.v / "reject-3.json").read_text())
        r["memory_sha256"] = hashlib.sha256(d).hexdigest()
        self.save("reject-3.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "Rejected call changed"):
            G.verify(self.root)

    def test_unfinished_control_fails(self) -> None:
        r = json.loads((self.v / "unsafe-destination.json").read_text())
        r["flags"][0] = 0
        self.save("unsafe-destination.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "Unfinished"):
            G.verify(self.root)

    def test_nonfailing_control_fails(self) -> None:
        shutil.copyfile(self.v / "positive.bin", self.v / "unsafe-destination.bin")
        r = json.loads((self.v / "unsafe-destination.json").read_text())
        r["memory_sha256"] = hashlib.sha256(
            (self.v / "positive.bin").read_bytes()
        ).hexdigest()
        self.save("unsafe-destination.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "Broken control passed"):
            G.verify(self.root)

    def test_wrong_pixels_with_updated_hashes_fail(self) -> None:
        shutil.copyfile(self.v / "wrong-layout.png", self.v / "positive.png")
        r = json.loads((self.v / "positive.json").read_text())
        r["capture_sha256"] = hashlib.sha256(
            (self.v / "positive.png").read_bytes()
        ).hexdigest()
        self.save("positive.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "Wrong native pixels"):
            G.verify(self.root)

    def test_unexecuted_machine_cannot_be_promoted(self) -> None:
        p = self.root / "docs/tilemaps/coverage.json"
        r = json.loads(p.read_text())
        next(
            x
            for x in r["systems"]
            if x["region_drawing"]["status"] == "not-yet-qualified"
        )["region_drawing"]["status"] = "executed-cpu-bitmap"
        p.write_text(json.dumps(r))
        with self.assertRaisesRegex(AssertionError, "qualification differs"):
            G.verify(self.root)


if __name__ == "__main__":
    unittest.main()
