"""Reject missing observations and rehashed corruption, not just bad checksums."""

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
    "geometry_check", ROOT / "scripts/check-geometry.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class GeometryEvidence(unittest.TestCase):
    def fixture(self, machine="spectrum"):
        cfg = next(
            c
            for c in json.loads((C.SHARED / "systems.json").read_text())
            if c["machine_id"] == machine
        )
        td = tempfile.TemporaryDirectory()
        self.addCleanup(td.cleanup)
        out = Path(td.name) / "verification"
        shutil.copytree(
            ROOT / cfg["folder"] / "patterns/assembly/rendering/geometry/verification",
            out,
        )
        return cfg, out, json.loads((out / "results.json").read_text())

    def reject(self, cfg, out, record):
        (out / "results.json").write_text(json.dumps(record))
        with self.assertRaises((AssertionError, KeyError, FileNotFoundError)):
            C.check_system(cfg, out)

    def test_no_empty_calls(self):
        cfg, out, r = self.fixture()
        r["positive"]["cases"] = []
        self.reject(cfg, out, r)

    def test_no_missing_source(self):
        cfg, out, r = self.fixture()
        r["sources"].pop(next(iter(r["sources"])))
        self.reject(cfg, out, r)

    def test_completed_receipt_required(self):
        cfg, out, r = self.fixture()
        r["positive"]["cases"][0]["mailbox"] = "01ef"
        self.reject(cfg, out, r)

    def test_rehashed_wrong_bitmap(self):
        cfg, out, r = self.fixture()
        name = r["positive"]["cases"][0]["memory"]
        data = bytearray(zlib.decompress((out / name).read_bytes()))
        data[0] ^= 1
        (out / name).write_bytes(zlib.compress(data))
        r["artifacts"][name] = hashlib.sha256((out / name).read_bytes()).hexdigest()
        self.reject(cfg, out, r)

    def test_removed_capture_cannot_hide_behind_matching_manifest(self):
        cfg, out, r = self.fixture()
        name = r["positive"]["cases"][0].pop("capture")
        r["artifacts"].pop(name)
        self.reject(cfg, out, r)

    def test_guard_damage(self):
        cfg, out, r = self.fixture()
        r["positive"]["cases"][0]["guards"][0] = "00" * 16
        self.reject(cfg, out, r)

    def test_missing_fault_control(self):
        cfg, out, r = self.fixture()
        r["faults"] = {}
        self.reject(cfg, out, r)

    def test_rehashed_correct_bitmap_is_not_a_fault(self):
        cfg, out, r = self.fixture()
        rec = r["faults"]["curve-fault"]
        grid = [bytearray(cfg["width"]) for _ in range(cfg["height"])]
        C.M.apply(cfg, grid, rec["request"])
        name = rec["memory"]
        (out / name).write_bytes(zlib.compress(C.M.packed(cfg, grid)))
        r["artifacts"][name] = hashlib.sha256((out / name).read_bytes()).hexdigest()
        self.reject(cfg, out, r)

    def test_cpc_unused_padding_is_owned(self):
        cfg, out, r = self.fixture("amstrad-cpc")
        name = r["positive"]["cases"][0]["memory"]
        data = bytearray(zlib.decompress((out / name).read_bytes()))
        data[2000] ^= 1  # First unused byte in the 2 KiB CRTC bank.
        (out / name).write_bytes(zlib.compress(data))
        r["artifacts"][name] = hashlib.sha256((out / name).read_bytes()).hexdigest()
        self.reject(cfg, out, r)


if __name__ == "__main__":
    unittest.main()
