"""Retained text checks reject missing records and rehashed incorrect outcomes."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "extended_check", ROOT / "scripts/check-extended-primitives.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class ExtendedPrimitives(unittest.TestCase):
    def fixture(self):
        cfg = json.loads((C.S / "systems.json").read_text())[0]
        td = tempfile.TemporaryDirectory()
        self.addCleanup(td.cleanup)
        folder = Path(td.name) / "verification"
        shutil.copytree(
            ROOT
            / cfg["folder"]
            / "patterns/assembly/rendering/pixels-and-boxes/verification",
            folder,
        )
        return cfg, folder, json.loads((folder / "results.json").read_text())

    def reject(self, c, folder, r):
        (folder / "results.json").write_text(json.dumps(r))
        with self.assertRaises((AssertionError, KeyError, FileNotFoundError)):
            C.check(c, folder)

    def test_empty_cases(self):
        c, f, r = self.fixture()
        r["positive"]["cases"] = []
        self.reject(c, f, r)

    def test_missing_source(self):
        c, f, r = self.fixture()
        r["sources"].pop(next(iter(r["sources"])))
        self.reject(c, f, r)

    def test_missing_completion(self):
        c, f, r = self.fixture()
        r["positive"]["cases"][0]["mailbox"] = "0100"
        self.reject(c, f, r)

    def test_missing_capture_and_manifest_entry(self):
        c, f, r = self.fixture()
        name = r["positive"]["cases"][0].pop("capture")
        r["artifacts"].pop(name)
        self.reject(c, f, r)

    def test_rehashed_bitmap_damage(self):
        c, f, r = self.fixture()
        name = r["positive"]["cases"][0]["memory"]
        data = bytearray(zlib.decompress((f / name).read_bytes()))
        data[0] ^= 1
        (f / name).write_bytes(zlib.compress(data))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_display_allocation_identity(self):
        c, f, r = self.fixture()
        r["machine_id"] = "atari-800xl"
        self.reject(c, f, r)

    def test_missing_fault(self):
        c, f, r = self.fixture()
        r["faults"].pop("row-fault")
        self.reject(c, f, r)

    def test_correct_bitmap_cannot_count_as_failed_control(self):
        c, f, r = self.fixture()
        o = r["faults"]["mask-fault"]
        grid = C.M.baseline(c)
        C.M.evaluate(c, grid, o["request"])
        name = o["memory"]
        (f / name).write_bytes(zlib.compress(grid))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)


if __name__ == "__main__":
    unittest.main()
