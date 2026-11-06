"""Positive and deliberately corrupted ROM-font evidence."""

import copy
import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-c64-rom-font.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class BuildFailure(unittest.TestCase):
    def check_failure(self, override):
        makefile = (
            C.V.ROOT / "commodore-64/patterns/assembly/rendering/custom-glyphs/Makefile"
        )
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [
                    "make",
                    "--no-print-directory",
                    "-f",
                    str(makefile),
                    "rom-font",
                    override,
                ],
                cwd=directory,
                text=True,
                capture_output=True,
                check=False,
            )
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("(ignored)", result.stderr)

    def test_legacy_assembler_failure_propagates(self):
        self.check_failure("ASM=/usr/bin/false")

    def test_empty_assembler_failure_propagates(self):
        self.check_failure("ASM198X=")


class Evidence(unittest.TestCase):
    def test_native(self):
        C.check()

    def test_falsifications(self):
        original = json.loads((C.V.V / "results.json").read_text())
        for fault in (
            "configuration",
            "case",
            "producer",
            "code",
            "load",
            "rom",
            "copy",
            "patch",
            "hold",
            "guard",
            "input",
            "cost",
            "image",
            "reject",
            "flags",
            "mapping",
            "repair",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["rom-demo"]
            if fault == "configuration":
                r["configuration"]["emulator_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("rom-custom")
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "code":
                c["prg_bytes"][2] ^= 1
            elif fault == "load":
                c["loaded_bytes"][0] ^= 1
            elif fault == "rom":
                c["expected_initial_sha256"] = "0" * 64
            elif fault == "copy":
                c["initial"]["font_sha256"] = "0" * 64
            elif fault == "patch":
                c["patched_sha256"] = "0" * 64
            elif fault == "hold":
                c["changes"] = 2
            elif fault == "guard":
                c["guards"][0][0] ^= 1
            elif fault == "input":
                c["inputs"][2] = 2
            elif fault == "cost":
                c["wrapper_code_bytes"] = 0
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            elif fault == "reject":
                r["cases"]["rom-boundaries"]["boundaries"][0]["font_sha256"] = "0" * 64
            elif fault == "flags":
                r["cases"]["rom-boundaries"]["boundaries"][0]["row"][4] &= ~8
            elif fault == "mapping":
                r["cases"]["rom-boundaries"]["boundaries"][4]["row"][3] ^= 1
            else:
                r["cases"]["rom-repaired"]["program_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_coupled_wrong_glyph(self):
        c = copy.deepcopy(
            json.loads((C.V.V / "results.json").read_text())["cases"]["rom-demo"]
        )
        c["visible_glyphs"]["18"][0] ^= 1
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c)

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["rom-wrong"]
        c["prg_bytes"][2] ^= 1
        c["loaded_bytes"][0] ^= 1
        c["program_sha256"] = C.V.digest(bytes(c["prg_bytes"]))
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self):
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        for c in r["cases"].values():
            c["source_sha256"] = "0" * 64
        C.check(r)


if __name__ == "__main__":
    unittest.main()
