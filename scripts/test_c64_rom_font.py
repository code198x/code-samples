"""Positive and deliberately corrupted ROM-font evidence."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-c64-rom-font.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        C.check()

    def test_falsifications(self):
        original = json.loads((C.V.V / "results.json").read_text())
        for fault in (
            "source",
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
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "configuration":
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


if __name__ == "__main__":
    unittest.main()
