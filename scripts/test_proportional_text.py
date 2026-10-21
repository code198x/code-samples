"""Corruption controls for retained layout records, including rehashed bad data."""

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
    "layout_check", ROOT / "scripts/check-proportional-text.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class TextLayout(unittest.TestCase):
    def fixture(self) -> tuple[dict, Path, dict]:
        c = json.loads((C.S / "systems.json").read_text())[0]
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        folder = Path(tmp.name) / "verification"
        shutil.copytree(
            ROOT
            / c["folder"]
            / "patterns/assembly/rendering/proportional-text/verification",
            folder,
        )
        return c, folder, json.loads((folder / "results.json").read_text())

    def reject(self, c: dict, folder: Path, result: dict) -> None:
        (folder / "results.json").write_text(json.dumps(result))
        with self.assertRaises((AssertionError, KeyError, FileNotFoundError)):
            C.check(c, folder)

    def test_advance_sums(self) -> None:
        c = json.loads((C.S / "systems.json").read_text())[0]
        for text, spacing, width in [
            (b"IIIIII", 1, 24),
            (b"WWWWWW", 1, 36),
            (b"I! WIDE", 1, 32),
            (b"I! WIDE", 2, 39),
            (b"", 1, 0),
        ]:
            r = {
                "kind": "measure",
                "bytes": list(text),
                "source_ptr": c["data"],
                "font_ptr": 1024,
                "metric_ptr": 2048,
                "spacing": spacing,
            }
            out = C.M.evaluate(
                c, [bytearray(c["width"]) for _ in range(c["height"])], r
            )
            self.assertTrue(out["accepted"])
            self.assertEqual(out["measured"], width)

    def test_metrics_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["ram_metrics"] = "00" * 64
        self.reject(c, f, r)

    def test_real_records(self) -> None:
        for c in json.loads((C.S / "systems.json").read_text()):
            self.assertGreater(C.check(c), 40)

    def test_missing_variant(self) -> None:
        c, f, r = self.fixture()
        r["variants"].pop("advance-fixed")
        self.reject(c, f, r)

    def test_rehashed_word_fault_cannot_be_good(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["advance-fault"]["cases"][0]
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        C.M.evaluate(c, grid, o["request"])
        name = o["memory"]
        (f / name).write_bytes(zlib.compress(C.M.TEXT.P.packed(c, grid)))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_empty_cases(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"] = []
        self.reject(c, f, r)

    def test_missing_source(self) -> None:
        c, f, r = self.fixture()
        r["sources"].pop(next(iter(r["sources"])))
        self.reject(c, f, r)

    def test_incomplete_call(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["mailbox"] = "0400"
        self.reject(c, f, r)

    def test_missing_capture_even_when_manifest_removed(self) -> None:
        c, f, r = self.fixture()
        name = r["variants"]["positive"]["startup"].pop("capture")
        r["artifacts"].pop(name)
        self.reject(c, f, r)

    def test_rehashed_bitmap(self) -> None:
        c, f, r = self.fixture()
        name = r["variants"]["positive"]["cases"][0]["memory"]
        data = bytearray(zlib.decompress((f / name).read_bytes()))
        data[0] ^= 1
        (f / name).write_bytes(zlib.compress(data))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_fake_measurement(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["positive"]["cases"][0]
        data = bytearray.fromhex(o["context"])
        data[18] ^= 8
        o["context"] = data.hex()
        self.reject(c, f, r)

    def test_rehashed_fault_cannot_be_good_picture(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["advance-fault"]["cases"][0]
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        C.M.evaluate(c, grid, o["request"])
        name = o["memory"]
        (f / name).write_bytes(zlib.compress(C.M.TEXT.P.packed(c, grid)))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_font_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["rom_font"] = "00" * 512
        self.reject(c, f, r)

    def test_repair_hash_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["advance-fixed"]["fixture_sha256"] = "00" * 32
        self.reject(c, f, r)


if __name__ == "__main__":
    unittest.main()
