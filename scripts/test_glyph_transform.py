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
    "glyph_checker", ROOT / "scripts/check-glyph-transform.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
M = C.V.M


class Algebra(unittest.TestCase):
    def test_known_corner(self) -> None:
        rows = bytes([128] + [0] * 7)
        self.assertEqual(M.transform(rows, 1), bytes([1] + [0] * 7))
        self.assertEqual(M.transform(rows, 2), bytes([0] * 7 + [1]))
        self.assertEqual(M.transform(rows, 3), bytes([0] * 7 + [128]))
        self.assertEqual(M.transform(rows, 4), bytes([1] + [0] * 7))

    def test_inverse_and_population(self) -> None:
        for row in [bytes([231, 129, 160, 8, 4, 3, 64, 255])] + [
            bytes((128 >> (bit % 8)) if y == bit // 8 else 0 for y in range(8))
            for bit in range(64)
        ]:
            for flags in range(8):
                t = M.transform(row, flags)
                self.assertEqual(
                    sum(x.bit_count() for x in t), sum(x.bit_count() for x in row)
                )
                inverse = flags if flags & 4 else (-flags) & 3
                self.assertEqual(M.transform(t, inverse), row)

    def test_rejects_invalid(self) -> None:
        for rows, flags in [
            (bytes(7), 0),
            (bytes(9), 1),
            (bytes(8), 8),
            (bytes(8), -1),
        ]:
            with self.assertRaises(ValueError):
                M.transform(rows, flags)


class Retained(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.configs = json.loads((C.V.S / "systems.json").read_text())

    def test_all_machine_records(self) -> None:
        self.assertGreater(sum(C.check(c) for c in self.configs), 2000)

    def corrupt(self, change: Callable[[dict[str, Any], Path], Any]) -> None:
        c = self.configs[0]
        original = (
            ROOT
            / c["folder"]
            / "patterns/assembly/rendering/glyph-transform/verification"
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

    def retained(
        self, change: Callable[[dict[str, Any]], None], rejection: str | None = None
    ) -> None:
        """Check every machine's record after `change`, in a copy of its folder.

        With `rejection`, each check must fail with a message matching it.
        """
        for c in json.loads((C.V.S / "systems.json").read_text()):
            original = (
                ROOT
                / c["folder"]
                / "patterns/assembly/rendering/glyph-transform/verification"
            )
            with (
                self.subTest(system=c["machine_id"]),
                tempfile.TemporaryDirectory() as name,
            ):
                folder = Path(name)
                shutil.copytree(original, folder, dirs_exist_ok=True)
                result = json.loads((folder / "results.json").read_text())
                change(result)
                (folder / "results.json").write_text(json.dumps(result))
                if rejection is None:
                    C.check(c, folder)
                else:
                    with self.assertRaisesRegex(AssertionError, rejection):
                        C.check(c, folder)

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""

        def forge(r: dict[str, Any]) -> None:
            r["variants"]["customise"]["fixture_sha256"] = "0" * 64

        self.retained(forge, "^Program bytes differ")

    def test_source_digests_are_provenance(self) -> None:
        """Changed, added or removed source text alone does not make a record stale."""

        def rewrite(r: dict[str, Any]) -> None:
            r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)

        self.retained(rewrite)

    def test_missing_variant(self) -> None:
        self.corrupt(lambda r, f: r["variants"].pop("rotation-fixed"))

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
            good = r["variants"]["rotation-fixed"]["startup"]["capture"]
            bad = r["variants"]["rotation-fault"]["startup"]["capture"]
            shutil.copyfile(f / good, f / bad)
            r["artifacts"][bad] = C.V.V.T.sha(f / bad)

        self.corrupt(change)


if __name__ == "__main__":
    unittest.main()
