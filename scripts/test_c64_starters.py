"""Check the public starter validator against an independent tokeniser fixture."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHECKER = ROOT / "scripts/check-c64-starters.py"
PREFIX = bytes.fromhex((ROOT / "scripts/fixtures/c64-sys-2061.hex").read_text())
CODE = bytes.fromhex("a9028d20d04c1208")


class StarterTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="198x-c64-starter-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        unit = self.root / "unit-01"
        unit.mkdir()
        (unit / "border.asm").write_text("; independently assembled fixture\n")
        self.program = unit / "border.prg"

    def run_check(
        self, data: bytes | None, success: bool, diagnostic: str = ""
    ) -> dict:
        if data is not None:
            self.program.write_bytes(data)
        result = subprocess.run(
            [sys.executable, str(CHECKER), "--root", str(self.root)],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        self.assertEqual(result.returncode, 0 if success else 1, result.stderr)
        report = json.loads(result.stdout)
        if success:
            self.assertEqual(len(report["checked"]), 1)
            self.assertEqual(report["errors"], [])
        else:
            self.assertEqual(len(report["errors"]), 1)
            self.assertIn(diagnostic, report["errors"][0]["error"])
        return report

    def test_independent_petcat_prefix_reaches_actual_code(self) -> None:
        report = self.run_check(PREFIX + CODE, True)
        self.assertEqual(report["checked"][0]["entry"], int(PREFIX[7:11]))

    def test_original_pointer_is_rejected(self) -> None:
        damaged = bytearray(PREFIX + CODE)
        damaged[2] += 1
        self.run_check(bytes(damaged), False, "does not reach end marker")

    def test_sys_target_must_match_code_placement(self) -> None:
        self.run_check(
            (PREFIX + CODE).replace(b"2061", b"2062"), False, "first machine-code byte"
        )

    def test_missing_end_marker_is_rejected(self) -> None:
        self.run_check(PREFIX[:-1], False, "missing BASIC end marker")

    def test_missing_code_is_rejected(self) -> None:
        self.run_check(PREFIX, False, "missing machine code")

    def test_missing_output_is_rejected(self) -> None:
        self.run_check(None, False, "border.prg")

    def test_truncated_load_address_is_rejected(self) -> None:
        self.run_check(PREFIX[:1], False, "missing PRG load address")

    def test_empty_discovery_fails(self) -> None:
        result = subprocess.run(
            [sys.executable, str(CHECKER), "--root", str(self.root / "absent")],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No primer sources", result.stderr)


if __name__ == "__main__":
    unittest.main()
