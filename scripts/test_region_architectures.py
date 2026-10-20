"""Failure controls for retained native adapter and CPU/blitter evidence."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
s = importlib.util.spec_from_file_location(
    "adapter_guard", ROOT / "scripts/check-region-architectures.py"
)
assert s and s.loader
G = importlib.util.module_from_spec(s)
s.loader.exec_module(G)


class AdapterEvidenceFailures(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        files = {
            "docs/tilemaps/coverage.json",
            "docs/capability-coverage.json",
            "scripts/check-region-architectures.py",
        }
        cs = json.loads(
            (
                ROOT
                / "cross-platform/patterns/rendering/region-architectures/systems.json"
            ).read_text()
        )
        for c in cs:
            v = (
                ROOT
                / c["folder"]
                / "patterns/assembly/rendering/tile-region/verification"
            )
            files.update(str(p.relative_to(ROOT)) for p in v.iterdir() if p.is_file())
            files.update(json.loads((v / "results.json").read_text())["sources"])
        for path in files:
            p = self.root / path
            p.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / path, p)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def folder(self, system: str = "oric-atmos") -> Path:
        return (
            self.root / system / "patterns/assembly/rendering/tile-region/verification"
        )

    def save(self, name: str, data: dict, system: str = "oric-atmos") -> None:
        (self.folder(system) / name).write_text(json.dumps(data))

    def refresh(self, system: str = "oric-atmos") -> None:
        v = self.folder(system)
        r = json.loads((v / "results.json").read_text())
        r["files"] = {
            name: hashlib.sha256((v / name).read_bytes()).hexdigest()
            for name in r["files"]
        }
        self.save("results.json", r, system)

    def test_unchanged_evidence_passes(self) -> None:
        self.assertEqual(G.verify(self.root), 4)

    def test_changed_shared_kernel_fails(self) -> None:
        p = self.root / "cross-platform/patterns/rendering/bitmap-regions/6502.inc"
        p.write_text(p.read_text() + "; changed\n")
        with self.assertRaisesRegex(AssertionError, "Changed source"):
            G.verify(self.root)

    def test_missing_blitter_source_identity_fails(self) -> None:
        r = json.loads((self.folder("commodore-amiga") / "results.json").read_text())
        r["sources"].pop(
            "cross-platform/patterns/rendering/region-architectures/blit-plane.inc"
        )
        self.save("results.json", r, "commodore-amiga")
        with self.assertRaisesRegex(AssertionError, "Missing source identity"):
            G.verify(self.root)

    def test_missing_retained_rejection_fails(self) -> None:
        r = json.loads((self.folder() / "results.json").read_text())
        r["files"].pop("reject-3.bin")
        self.save("results.json", r)
        with self.assertRaisesRegex(AssertionError, "Missing retained evidence"):
            G.verify(self.root)

    def test_unexecuted_isolated_rejection_fails(self) -> None:
        r = json.loads((self.folder() / "reject-3.json").read_text())
        r["flags"][4] = 0
        self.save("reject-3.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "call acceptance"):
            G.verify(self.root)

    def test_rejected_call_guard_corruption_fails_after_refresh(self) -> None:
        p = self.folder() / "reject-3.bin"
        raw = bytearray(p.read_bytes())
        raw[0] ^= 1
        p.write_bytes(raw)
        r = json.loads((self.folder() / "reject-3.json").read_text())
        r["memory_sha256"] = hashlib.sha256(raw).hexdigest()
        self.save("reject-3.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "memory/guards"):
            G.verify(self.root)

    def test_lcd_on_acceptance_cannot_pass(self) -> None:
        sys = "nintendo-game-boy"
        r = json.loads((self.folder(sys) / "positive.json").read_text())
        r["flags"][19] = 129
        self.save("positive.json", r, sys)
        self.refresh(sys)
        with self.assertRaisesRegex(AssertionError, "call acceptance"):
            G.verify(self.root)

    def test_misaligned_amiga_pointer_acceptance_cannot_pass(self) -> None:
        sys = "commodore-amiga"
        r = json.loads((self.folder(sys) / "positive.json").read_text())
        r["flags"][20] = 129
        self.save("positive.json", r, sys)
        self.refresh(sys)
        with self.assertRaisesRegex(AssertionError, "call acceptance"):
            G.verify(self.root)

    def test_short_blit_must_fail_even_after_checksum_refresh(self) -> None:
        sys = "commodore-amiga"
        v = self.folder(sys)
        shutil.copyfile(v / "blitter.bin", v / "blitter-short.bin")
        r = json.loads((v / "blitter-short.json").read_text())
        r["memory_sha256"] = hashlib.sha256(
            (v / "blitter-short.bin").read_bytes()
        ).hexdigest()
        self.save("blitter-short.json", r, sys)
        self.refresh(sys)
        with self.assertRaisesRegex(AssertionError, "Broken control passed memory"):
            G.verify(self.root)

    def test_wrong_pixels_cannot_pass_with_refreshed_hashes(self) -> None:
        v = self.folder()
        shutil.copyfile(v / "wrong-layout.png", v / "positive.png")
        r = json.loads((v / "positive.json").read_text())
        r["capture_sha256"] = hashlib.sha256(
            (v / "positive.png").read_bytes()
        ).hexdigest()
        self.save("positive.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "native pixels"):
            G.verify(self.root)

    def test_unexecuted_machine_cannot_be_promoted(self) -> None:
        p = self.root / "docs/tilemaps/coverage.json"
        r = json.loads(p.read_text())
        next(
            x
            for x in r["systems"]
            if x["region_drawing"]["status"] == "not-yet-qualified"
        )["region_drawing"]["status"] = "executed-native-adapter"
        p.write_text(json.dumps(r))
        with self.assertRaisesRegex(AssertionError, "qualification differs"):
            G.verify(self.root)


if __name__ == "__main__":
    unittest.main()
