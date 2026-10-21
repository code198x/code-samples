"""Independent geometry and corruption controls for enlarged glyph evidence."""

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
    "scaled_checker", ROOT / "scripts/check-scaled-text.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class ScaledText(unittest.TestCase):
    def fixture(self) -> tuple[dict, Path, dict]:
        c = json.loads((C.S / "systems.json").read_text())[0]
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        folder = Path(temp.name) / "verification"
        shutil.copytree(
            ROOT / c["folder"] / "patterns/assembly/rendering/scaled-text/verification",
            folder,
        )
        return c, folder, json.loads((folder / "results.json").read_text())

    def reject(self, c: dict, folder: Path, result: dict) -> None:
        (folder / "results.json").write_text(json.dumps(result))
        with self.assertRaises((AssertionError, KeyError, FileNotFoundError)):
            C.check(c, folder)

    def test_known_underscore_geometry(self) -> None:
        c = json.loads((C.S / "systems.json").read_text())[0]
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        out = C.M.evaluate(
            c,
            grid,
            {
                "kind": "char",
                "code": 95,
                "xy": [21, 37],
                "font_ptr": 1024,
                "source_ptr": 2048,
                "scale": [2, 3],
            },
        )
        self.assertTrue(out["accepted"])
        self.assertEqual(out["next_x"], 37)
        self.assertEqual(
            {(x, y) for y, row in enumerate(grid) for x, v in enumerate(row) if v},
            {(x, y) for x in range(23, 33) for y in range(55, 58)},
        )

    def test_real_records(self) -> None:
        for c in json.loads((C.S / "systems.json").read_text()):
            self.assertGreater(C.check(c), 140)

    def test_missing_variant(self) -> None:
        c, f, r = self.fixture()
        r["variants"].pop("advance-fixed")
        self.reject(c, f, r)

    def test_missing_case(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"].pop()
        self.reject(c, f, r)

    def test_missing_source(self) -> None:
        c, f, r = self.fixture()
        r["sources"].pop(next(iter(r["sources"])))
        self.reject(c, f, r)

    def test_incomplete_call(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["mailbox"] = "0200"
        self.reject(c, f, r)

    def test_scale_input_changed(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["positive"]["cases"][0]
        b = bytearray.fromhex(o["context"])
        b[68] ^= 1
        o["context"] = b.hex()
        self.reject(c, f, r)

    def test_fake_advance(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["positive"]["cases"][0]
        b = bytearray.fromhex(o["context"])
        b[26] ^= 8
        o["context"] = b.hex()
        self.reject(c, f, r)

    def test_rehashed_bitmap(self) -> None:
        c, f, r = self.fixture()
        name = r["variants"]["positive"]["cases"][0]["memory"]
        b = bytearray(zlib.decompress((f / name).read_bytes()))
        b[0] ^= 1
        (f / name).write_bytes(zlib.compress(b))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_rehashed_good_picture_as_fault(self) -> None:
        c, f, r = self.fixture()
        bad = r["variants"]["advance-fault"]["cases"][0]["capture"]
        good = r["variants"]["advance-fixed"]["cases"][0]["capture"]
        (f / bad).write_bytes((f / good).read_bytes())
        r["artifacts"][bad] = hashlib.sha256((f / bad).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_missing_capture_manifest_also_removed(self) -> None:
        c, f, r = self.fixture()
        name = r["variants"]["positive"]["startup"].pop("capture")
        r["artifacts"].pop(name)
        self.reject(c, f, r)

    def test_font_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["rom_font"] = "00" * 512
        self.reject(c, f, r)

    def test_repair_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["advance-fixed"]["fixture_sha256"] = "00" * 32
        self.reject(c, f, r)


if __name__ == "__main__":
    unittest.main()
