"""Failure controls for VDP evidence; no emulator or firmware needed."""

from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
s = importlib.util.spec_from_file_location(
    "region_guard", ROOT / "scripts/check-tile-regions.py"
)
assert s and s.loader
G = importlib.util.module_from_spec(s)
s.loader.exec_module(G)


class RegionEvidenceFailures(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        files = {
            "docs/tilemaps/coverage.json",
            "docs/capability-coverage.json",
            "scripts/verify-tile-regions.py",
            "scripts/verify-tilemaps.py",
            "scripts/verify-game-loops.py",
            "cross-platform/patterns/rendering/tile-region/systems.json",
            "cross-platform/patterns/rendering/tile-region/build.py",
        }
        configs = json.loads(
            (
                ROOT / "cross-platform/patterns/rendering/tile-region/systems.json"
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

    def test_changed_kernel_fails(self) -> None:
        p = self.root / "cross-platform/patterns/rendering/tile-region/region.inc"
        p.write_text(p.read_text() + "; changed\n")
        with self.assertRaisesRegex(AssertionError, "Changed source"):
            G.verify(self.root)

    def test_missing_kernel_identity_fails(self) -> None:
        p = self.v / "results.json"
        d = json.loads(p.read_text())
        d["sources"].pop("cross-platform/patterns/rendering/tile-region/region.inc")
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "Missing source identities"):
            G.verify(self.root)

    def test_zero_is_not_evidence_of_a_completed_rejection(self) -> None:
        p = self.v / "positive.json"
        d = json.loads(p.read_text())
        d["flags"][2] = 0
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "Wrong acceptance flags"):
            G.verify(self.root)

    def test_video_guard_corruption_fails(self) -> None:
        p = self.v / "positive.json"
        d = json.loads(p.read_text())
        d["vram"][-1] = 1
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "VDP readback/guard"):
            G.verify(self.root)

    def test_unfinished_control_fails(self) -> None:
        p = self.v / "wrong-stride.json"
        d = json.loads(p.read_text())
        d["flags"][0] = 0
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "Unfinished"):
            G.verify(self.root)

    def test_nonfailing_control_fails(self) -> None:
        oracle = G.load(self.root / "scripts/verify-tile-regions.py")
        p = self.v / "unsafe-destination.json"
        d = json.loads(p.read_text())
        d["vram"] = oracle.expected_vram(self.first)
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "Negative control passed"):
            G.verify(self.root)

    def test_wrong_pixels_fail_after_checksum_is_updated(self) -> None:
        # Same-size screenshot, wrong palette/descriptor flip. Updating the hash
        # must not make an incorrect picture count as execution evidence.
        donor = (
            self.root
            / "sega-master-system/patterns/assembly/rendering/tile-region/verification/positive.png"
        )
        shutil.copyfile(donor, self.v / "positive.png")
        oracle = G.load(self.root / "scripts/verify-tile-regions.py")
        p = self.v / "positive.json"
        d = json.loads(p.read_text())
        d["capture_sha256"] = oracle.T.sha(self.v / "positive.png")
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "Wrong rendered pixels"):
            G.verify(self.root)

    def test_unexecuted_machine_cannot_be_promoted(self) -> None:
        p = self.root / "docs/tilemaps/coverage.json"
        d = json.loads(p.read_text())
        r = next(
            r
            for r in d["systems"]
            if r["region_drawing"]["status"] == "not-yet-qualified"
        )
        r["region_drawing"]["status"] = "executed-native-vdp"
        p.write_text(json.dumps(d))
        with self.assertRaisesRegex(AssertionError, "qualification inventory"):
            G.verify(self.root)


if __name__ == "__main__":
    unittest.main()
