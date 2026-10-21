"""Independent asset properties and adversarial retained-evidence controls."""

from __future__ import annotations

import importlib.util
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
import zlib
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ValueError(path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


C = load("quad_checker", ROOT / "scripts/check-character-quads.py")
P = load("quad_prepare", C.V.S / "prepare.py")


class Preparation(unittest.TestCase):
    def test_every_source_pixel_maps_to_four_dots(self) -> None:
        for bit in range(64):
            source = bytearray(8)
            source[bit // 8] = 128 >> (bit % 8)
            actual = P.enlarge(bytes(source))
            self.assertEqual(actual, C.V.M.tiles(bytes(source)))
            self.assertEqual(sum(b.bit_count() for b in actual), 4)

    def test_every_possible_row_and_all_its_positions(self) -> None:
        for row in range(8):
            for value in range(256):
                source = bytearray(8)
                source[row] = value
                self.assertEqual(P.enlarge(bytes(source)), C.V.M.tiles(bytes(source)))

    def test_bad_lengths_reject(self) -> None:
        for size in [0, 7, 9, 32]:
            with self.assertRaises(ValueError):
                P.enlarge(bytes(size))

    def test_prepared_assets_match_source_rows(self) -> None:
        import re

        for c in C.V.configs():
            text = (
                ROOT
                / c["folder"]
                / "patterns/assembly/rendering/character-quads/assets.inc"
            ).read_text()
            for name, source in [("f", C.V.M.NORMAL), ("arrow", C.V.M.CUSTOM)]:
                part = text.split("large_" + name + ":\n")[1].split("large_")[0]
                values = bytes(
                    int(v)
                    for line in part.splitlines()
                    if line.strip().startswith("db ")
                    for v in re.sub(r"^\s*db ", "", line).split(",")
                )
                self.assertEqual(values, P.enlarge(source))
                self.assertEqual((C.V.S / (name + ".bin")).read_bytes(), source)


class EvidenceControls(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix="quad-evidence-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.c = C.V.configs()[0]
        for path in C.V.paths(self.c):
            dest = self.root / path.relative_to(ROOT)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
        relative = (
            Path(self.c["folder"])
            / "patterns/assembly/rendering/character-quads/verification"
        )
        shutil.copytree(ROOT / relative, self.root / relative)
        self.out = self.root / relative
        self.record = json.loads((self.out / "results.json").read_text())

    def reject(self) -> None:
        (self.out / "results.json").write_text(json.dumps(self.record))
        with self.assertRaises(
            (AssertionError, ValueError, FileNotFoundError, KeyError)
        ):
            C.check(self.c, self.root)

    def change(self, field: str, value: str | list[str]) -> None:
        name = "positive.json.z"
        data = json.loads(zlib.decompress((self.out / name).read_bytes()))
        data["cases"][0][field] = value
        (self.out / name).write_bytes(zlib.compress(json.dumps(data).encode()))
        self.record["artifacts"][name] = C.V.V.T.sha(self.out / name)

    def test_all_six_records(self) -> None:
        self.assertEqual(len(C.V.configs()), 6)
        for c in C.V.configs():
            C.check(c)

    def test_rehashed_wrong_names_reject(self) -> None:
        self.change("names", "00" * 768)
        self.reject()

    def test_rehashed_wrong_vram_reject(self) -> None:
        self.change("vram", "00" * 16384)
        self.reject()

    def test_changed_guard_rejects(self) -> None:
        self.change("guards", ["00" * 8, "5a" * 8])
        self.reject()

    def test_rehashed_wrong_picture_rejects(self) -> None:
        name = "positive-startup.png"
        shutil.copy2(self.out / "stride-fault-startup.png", self.out / name)
        self.record["artifacts"][name] = C.V.V.T.sha(self.out / name)
        self.reject()

    def test_missing_completed_variant_rejects(self) -> None:
        del self.record["variants"]["stride-fixed"]
        self.reject()

    def test_missing_source_rejects(self) -> None:
        self.record["sources"].pop(next(iter(self.record["sources"])))
        self.reject()

    def test_missing_call_rejects(self) -> None:
        name = "positive.json.z"
        data = json.loads(zlib.decompress((self.out / name).read_bytes()))
        data["cases"].pop()
        (self.out / name).write_bytes(zlib.compress(json.dumps(data).encode()))
        self.record["artifacts"][name] = C.V.V.T.sha(self.out / name)
        self.reject()

    def test_unknown_machine_rejects(self) -> None:
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/check-character-quads.py"),
                "--system",
                "absent-machine",
            ],
            check=False,
            capture_output=True,
            text=True,
            timeout=15,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No matching system", result.stderr)


if __name__ == "__main__":
    unittest.main()
