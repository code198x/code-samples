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
    "character_checker", ROOT / "scripts/check-character-ram-ports.py"
)
if spec is None or spec.loader is None:
    raise ValueError("Cannot load checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class EvidenceControls(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="character-ram-evidence-")
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

    def test_all_three_real_records_pass(self) -> None:
        self.assertEqual(len(C.V.configs()), 3)
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

    def use_machine(self, index: int) -> None:
        self.cfg = C.V.configs()[index]
        for path in C.V.paths(self.cfg):
            dest = self.root / path.relative_to(ROOT)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, dest)
        self.out = (
            self.root
            / self.cfg["folder"]
            / "patterns/assembly/rendering/custom-glyphs/verification"
        )
        shutil.copytree(ROOT / self.out.relative_to(self.root), self.out)
        self.record = json.loads((self.out / "results.json").read_text())

    def test_rehashed_oric_attribute_corruption_is_not_a_glyph(self) -> None:
        self.use_machine(1)
        name = "positive-0.dat.z"
        data = bytearray(zlib.decompress((self.out / name).read_bytes()))
        data[1024] ^= 1  # Reserved paper attribute, not a drawable name.
        (self.out / name).write_bytes(zlib.compress(data))
        self.record["artifacts"][name] = C.V.T.sha(self.out / name)
        self.reject()

    def test_rehashed_atari_display_list_corruption_fails(self) -> None:
        self.use_machine(2)
        name = "positive-0.dat.z"
        data = bytearray(zlib.decompress((self.out / name).read_bytes()))
        data[-29] ^= 0x40  # Drop the list's first LMS bit.
        (self.out / name).write_bytes(zlib.compress(data))
        self.record["artifacts"][name] = C.V.T.sha(self.out / name)
        self.reject()

    def test_unknown_machine_cannot_check_nothing(self) -> None:
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/check-character-ram-ports.py"),
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
