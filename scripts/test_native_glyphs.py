"""Evidence must reject corrupted observations, even with recomputed hashes."""

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

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "native_checker", ROOT / "scripts/check-native-glyphs.py"
)
if spec is None or spec.loader is None:
    raise ValueError("Cannot load checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class EvidenceControls(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="native-evidence-control-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.cfg = C.V.configs()[0]
        for path in C.V.paths(self.cfg):
            dest = self.root / path.relative_to(ROOT)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
        self.relative = (
            Path(self.cfg["folder"])
            / "patterns/assembly/rendering/custom-glyphs/verification"
        )
        shutil.copytree(ROOT / self.relative, self.root / self.relative)
        self.out = self.root / self.relative
        self.record = json.loads((self.out / "results.json").read_text())

    def save(self) -> None:
        (self.out / "results.json").write_text(json.dumps(self.record))

    def reject(self) -> None:
        self.save()
        with self.assertRaises(
            (AssertionError, FileNotFoundError, ValueError, KeyError)
        ):
            C.check(self.cfg, self.root)

    def test_all_four_real_records_pass(self) -> None:
        self.assertEqual(len(C.V.configs()), 4)
        for cfg in C.V.configs():
            C.check(cfg)

    def test_rehashed_full_font_still_fails_independent_model(self) -> None:
        name = "positive-0.dat.z"
        data = bytearray(zlib.decompress((self.out / name).read_bytes()))
        data[0] ^= 1
        (self.out / name).write_bytes(zlib.compress(data))
        self.record["artifacts"][name] = C.V.T.sha(self.out / name)
        self.reject()

    def test_rehashed_wrong_native_picture_fails(self) -> None:
        name = "positive-0.png"
        shutil.copy2(self.out / "wrong-slot-0.png", self.out / name)
        self.record["artifacts"][name] = C.V.T.sha(self.out / name)
        self.reject()

    def test_missing_call_fails(self) -> None:
        self.record["variants"]["positive"]["cases"].pop()
        self.reject()

    def test_missing_completed_variant_fails(self) -> None:
        del self.record["variants"]["wrong-name"]
        self.reject()

    def test_claimed_nonfailing_control_fails(self) -> None:
        self.record["variants"]["wrong-slot"]["memory_faults"] = 0
        self.reject()

    def test_changed_input_fails(self) -> None:
        case = self.record["variants"]["positive"]["cases"][0]
        context = bytearray.fromhex(case["context"])
        context[2] ^= 1
        case["context"] = context.hex()
        self.reject()

    def test_changed_guard_fails(self) -> None:
        self.record["variants"]["positive"]["cases"][0]["cpu_guards"][0] = "00" * 8
        self.reject()

    def test_wrong_tool_fails(self) -> None:
        self.record["variants"]["positive"]["emulator_sha256"] = "0" * 64
        self.reject()

    def test_unbound_source_fails(self) -> None:
        self.record["sources"].pop(next(iter(self.record["sources"])))
        self.reject()

    def test_unknown_machine_cannot_check_nothing(self) -> None:
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/check-native-glyphs.py"),
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


class CartridgeMastering(unittest.TestCase):
    def test_explicit_chr_ram_image_has_no_chr_rom(self) -> None:
        raw = b"NES\x1a" + bytes([2, 0, 1, 0]) + bytes(32776)
        self.assertEqual(C.V.B.master_nes(raw), raw)
        self.assertEqual(C.V.B.master_nes(raw + bytes(8192)), raw)

    def test_undeclared_assets_are_not_discarded(self) -> None:
        raw = b"NES\x1a" + bytes([2, 0, 1, 0]) + bytes(32776)
        with self.assertRaises(ValueError):
            C.V.B.master_nes(raw + bytes(8191) + b"x")
        with self.assertRaises(ValueError):
            C.V.B.master_nes(raw + bytes(1))

    def test_chr_rom_header_is_not_claimed_as_ram(self) -> None:
        raw = b"NES\x1a" + bytes([2, 1, 1, 0]) + bytes(32776)
        with self.assertRaises(ValueError):
            C.V.B.master_nes(raw)


if __name__ == "__main__":
    unittest.main()
