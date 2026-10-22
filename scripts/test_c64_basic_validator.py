"""Keep literal prose distinct from code, and require exact negative evidence."""

from __future__ import annotations

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "validator", ROOT / "scripts/validate-c64-basic.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)


class ValidatorControls(unittest.TestCase):
    def test_literals_and_executable_errors(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "case.bas"
            for source, expected in [
                ('10 PRINT "DO NOT COUNT ON IT"\n', True),
                ("10 DO\n", False),
                ('10 PRINT "POKE 53281,300"\n', True),
                ("10 POKE 53281,300\n", False),
                ('10 PRINT "RESTORE 100":DO\n', False),
            ]:
                with self.subTest(source=source):
                    path.write_text(source)
                    self.assertEqual(
                        V.C64BasicValidator(str(path)).validate(), expected
                    )

    def test_registered_negative_is_required_and_diagnostic_printed(self):
        fixture = ROOT / "commodore-64/basic/meet-c64-basic/unit-15/steps/step-02.bas"
        ordinary = subprocess.run(
            [sys.executable, str(ROOT / "scripts/validate-c64-basic.py"), str(fixture)],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(ordinary.returncode, 1)
        self.assertIn("POKE value 300 exceeds 255", ordinary.stdout)
        negative = subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/validate-c64-basic.py"),
                str(fixture),
                "--negative-fixture",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(negative.returncode, 0)
        self.assertIn("Expected negative diagnostic verified", negative.stdout)

    def test_tokenizer_failure_and_empty_output_fail_the_wrapper(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            tokenizer = folder / "petcat"
            for body in ["exit 37", "exit 0"]:
                tokenizer.write_text("#!/bin/sh\n" + body + "\n")
                tokenizer.chmod(0o755)
                result = subprocess.run(
                    [
                        "bash",
                        str(ROOT / "scripts/validate-bas.sh"),
                        str(
                            ROOT
                            / "commodore-64/patterns/basic/framework/command-loop/caller.bas"
                        ),
                    ],
                    env={
                        **os.environ,
                        "PATH": directory + os.pathsep + os.environ["PATH"],
                    },
                    capture_output=True,
                    text=True,
                    check=False,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(
                    "petcat failed"
                    if body == "exit 37"
                    else "petcat produced no program",
                    result.stderr,
                )

    def test_changed_or_missing_negative_cannot_pass(self):
        fixtures = json.loads(
            (ROOT / "scripts/c64-basic-negative-cases.json").read_text()
        )
        self.assertEqual(len(fixtures), 1)
        relative = next(iter(fixtures))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / relative
            path.parent.mkdir(parents=True)
            (root / "scripts").mkdir()
            (root / "scripts/c64-basic-negative-cases.json").write_text(
                json.dumps(fixtures)
            )
            self.assertFalse(V.negative_fixture_matches(str(path), [], root))
            for code in ["10 POKE 53281,0\n", "10 POKE 53281,301\n"]:
                path.write_text(code)
                validator = V.C64BasicValidator(str(path))
                validator.validate()
                self.assertFalse(
                    V.negative_fixture_matches(str(path), validator.errors, root)
                )


if __name__ == "__main__":
    unittest.main()
