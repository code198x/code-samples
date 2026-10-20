"""Prove retained cell-region checks reject changed or incomplete evidence."""

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
    "guard", ROOT / "scripts/check-character-regions.py"
)
assert spec and spec.loader
G = importlib.util.module_from_spec(spec)
spec.loader.exec_module(G)


class CellEvidenceFailures(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        paths = {
            "scripts/check-character-regions.py",
            "docs/tilemaps/coverage.json",
            "docs/capability-coverage.json",
        }
        configs = json.loads(
            (
                ROOT
                / "cross-platform/patterns/rendering/character-regions/systems.json"
            ).read_text()
        )
        for c in configs:
            v = (
                ROOT
                / c["folder"]
                / "patterns/assembly/rendering/tile-region/verification"
            )
            paths.update(str(p.relative_to(ROOT)) for p in v.iterdir() if p.is_file())
            paths.update(json.loads((v / "results.json").read_text())["sources"])
        for path in paths:
            p = self.root / path
            p.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / path, p)

    def tearDown(self):
        self.temp.cleanup()

    def folder(self, system="commodore-vic-20"):
        return (
            self.root / system / "patterns/assembly/rendering/tile-region/verification"
        )

    def save(self, name, data, system="commodore-vic-20"):
        (self.folder(system) / name).write_text(json.dumps(data))

    def refresh(self, system="commodore-vic-20"):
        v = self.folder(system)
        r = json.loads((v / "results.json").read_text())
        r["files"] = {
            p: hashlib.sha256((v / p).read_bytes()).hexdigest() for p in r["files"]
        }
        self.save("results.json", r, system)

    def test_unchanged_passes(self):
        self.assertEqual(G.verify(self.root), 4)

    def test_changed_shared_source_fails(self):
        p = self.root / "cross-platform/patterns/rendering/character-regions/6502.inc"
        p.write_text(p.read_text() + "; changed\n")
        with self.assertRaisesRegex(AssertionError, "Changed source"):
            G.verify(self.root)

    def test_missing_source_identity_fails(self):
        r = json.loads((self.folder() / "results.json").read_text())
        r["sources"].pop(next(iter(r["sources"])))
        self.save("results.json", r)
        with self.assertRaisesRegex(AssertionError, "Missing source"):
            G.verify(self.root)

    def test_missing_rejection_fails(self):
        r = json.loads((self.folder() / "results.json").read_text())
        r["files"].pop("reject-3.bin")
        self.save("results.json", r)
        with self.assertRaisesRegex(AssertionError, "Missing retained"):
            G.verify(self.root)

    def test_unfinished_rejection_fails_after_refresh(self):
        r = json.loads((self.folder() / "reject-3.json").read_text())
        r["flags"][4] = 0
        self.save("reject-3.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "call acceptance"):
            G.verify(self.root)

    def test_colour_corruption_fails_after_refresh(self):
        v = self.folder()
        p = v / "positive.bin"
        raw = bytearray(p.read_bytes())
        raw[512 + 4 * 22 + 5] ^= 1
        p.write_bytes(raw)
        r = json.loads((v / "positive.json").read_text())
        r["memory_sha256"] = hashlib.sha256(raw).hexdigest()
        self.save("positive.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "destination/guards"):
            G.verify(self.root)

    def test_guard_corruption_fails_after_refresh(self):
        v = self.folder()
        p = v / "reject-3.bin"
        raw = bytearray(p.read_bytes())
        raw[-1] ^= 1
        p.write_bytes(raw)
        r = json.loads((v / "reject-3.json").read_text())
        r["memory_sha256"] = hashlib.sha256(raw).hexdigest()
        self.save("reject-3.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "destination/guards"):
            G.verify(self.root)

    def test_wrong_pixels_fail_after_refresh(self):
        v = self.folder()
        shutil.copyfile(v / "wrong-layout.png", v / "positive.png")
        r = json.loads((v / "positive.json").read_text())
        r["capture_sha256"] = hashlib.sha256(
            (v / "positive.png").read_bytes()
        ).hexdigest()
        self.save("positive.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "Native pixels"):
            G.verify(self.root)

    def test_nonfailing_control_fails_after_refresh(self):
        v = self.folder()
        shutil.copyfile(v / "positive.bin", v / "wrong-layout.bin")
        r = json.loads((v / "wrong-layout.json").read_text())
        r["memory_sha256"] = hashlib.sha256(
            (v / "wrong-layout.bin").read_bytes()
        ).hexdigest()
        self.save("wrong-layout.json", r)
        self.refresh()
        with self.assertRaisesRegex(AssertionError, "destination/guards"):
            G.verify(self.root)

    def test_unexecuted_machine_cannot_be_promoted(self):
        p = self.root / "docs/tilemaps/coverage.json"
        r = json.loads(p.read_text())
        next(
            x
            for x in r["systems"]
            if x["region_drawing"]["status"] == "not-yet-qualified"
        )["region_drawing"]["status"] = "executed-cell-region"
        p.write_text(json.dumps(r))
        with self.assertRaisesRegex(AssertionError, "qualification differs"):
            G.verify(self.root)


if __name__ == "__main__":
    unittest.main()
