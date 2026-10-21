"""Independent algebra checks and adversarial retained-record controls."""

from __future__ import annotations

import importlib.util
import json
import shutil
import tempfile
import unittest
import zlib
from collections.abc import Callable
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "glyph_checker", ROOT / "scripts/check-glyph-resize.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
M = C.V.M


class Sampling(unittest.TestCase):
    def test_known_sample_coordinates(self) -> None:
        rows = bytes([128, 64, 32, 16, 8, 4, 2, 1])
        self.assertEqual(M.resize(rows, 4, 4), bytes([128, 64, 32, 16, 0, 0, 0, 0]))
        self.assertEqual(M.resize(bytes([255] * 8), 5, 7), bytes([248] * 7 + [0]))
        self.assertEqual(M.resize(rows, 8, 8), rows)

    def test_every_identity_and_padding(self) -> None:
        for bit in range(64):
            rows = bytes((128 >> (bit % 8)) if y == bit // 8 else 0 for y in range(8))
            self.assertEqual(M.resize(rows, 8, 8), rows)
        for w in range(1, 9):
            for h in range(1, 9):
                out = M.resize(bytes([255] * 8), w, h)
                self.assertEqual(out, bytes([255 << (8 - w) & 255] * h + [0] * (8 - h)))

    def test_loss_is_explicit(self) -> None:
        rows = bytes([64] * 8)  # source column one is never sampled at width four
        self.assertEqual(M.resize(rows, 4, 8), bytes(8))
        self.assertNotEqual(M.resize(rows, 4, 8, crop_fault=True), bytes(8))

    def test_rejects_invalid(self) -> None:
        for rows, w, h in [
            (bytes(7), 8, 8),
            (bytes(9), 8, 8),
            (bytes(8), 0, 1),
            (bytes(8), 1, 9),
        ]:
            with self.assertRaises(ValueError):
                M.resize(rows, w, h)


class Retained(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.configs = json.loads((C.V.S / "systems.json").read_text())

    def test_all_machine_records(self) -> None:
        self.assertGreater(sum(C.check(c) for c in self.configs), 2000)

    def corrupt(self, change: Callable[[dict[str, Any], Path], Any]) -> None:
        c = self.configs[0]
        original = (
            ROOT / c["folder"] / "patterns/assembly/rendering/glyph-resize/verification"
        )
        with tempfile.TemporaryDirectory(prefix="glyph-control-") as name:
            folder = Path(name)
            shutil.copytree(original, folder, dirs_exist_ok=True)
            result = json.loads((folder / "results.json").read_text())
            change(result, folder)
            (folder / "results.json").write_text(json.dumps(result))
            with self.assertRaises(
                (AssertionError, ValueError, KeyError, FileNotFoundError)
            ):
                C.check(c, folder)

    def test_missing_case(self) -> None:
        self.corrupt(lambda r, f: r["variants"]["positive"]["cases"].pop())

    def test_wrong_guard(self) -> None:
        self.corrupt(
            lambda r, f: r["variants"]["positive"]["cases"][0].update(guards=[])
        )

    def test_incomplete_call(self) -> None:
        self.corrupt(
            lambda r, f: r["variants"]["positive"]["cases"][0].update(mailbox="04ef")
        )

    def test_wrong_output(self) -> None:
        self.corrupt(
            lambda r, f: r["variants"]["positive"]["cases"][0].update(
                after=r["variants"]["positive"]["cases"][0]["before"]
            )
        )

    def test_stale_source(self) -> None:
        self.corrupt(lambda r, f: r["sources"].update({"bogus": "0" * 64}))

    def test_missing_variant(self) -> None:
        self.corrupt(lambda r, f: r["variants"].pop("sampling-fixed"))

    def test_rehashed_bad_raster(self) -> None:
        def change(r: dict[str, Any], f: Path) -> None:
            rec = r["variants"]["positive"]["startup"]
            p = f / rec["memory"]
            data = bytearray(zlib.decompress(p.read_bytes()))
            data[0] ^= 1
            p.write_bytes(zlib.compress(data))
            r["artifacts"][p.name] = C.V.V.T.sha(p)

        self.corrupt(change)

    def test_good_capture_cannot_prove_fault(self) -> None:
        def change(r: dict[str, Any], f: Path) -> None:
            good = r["variants"]["sampling-fixed"]["startup"]["capture"]
            bad = r["variants"]["sampling-fault"]["startup"]["capture"]
            shutil.copyfile(f / good, f / bad)
            r["artifacts"][bad] = C.V.V.T.sha(f / bad)

        self.corrupt(change)


if __name__ == "__main__":
    unittest.main()
