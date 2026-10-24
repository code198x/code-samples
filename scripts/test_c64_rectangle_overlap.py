"""False evidence must fail the rectangle publication gate."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-c64-rectangle-overlap.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        C.check()

    def test_falsifications(self):
        original = json.loads((C.V.V / "results.json").read_text())
        for fault in (
            "source",
            "configuration",
            "case",
            "complete",
            "boolean",
            "oracle",
            "wrong",
            "grid",
            "code",
            "cost",
            "producer",
            "image",
            "repair",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["demo"]
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "configuration":
                r["configuration"]["emulator_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "complete":
                c["guards"][1] = 0
            elif fault == "boolean":
                c["bytes"][0] = 2
            elif fault == "oracle":
                c["bytes"][0] = 0
            elif fault == "wrong":
                r["cases"]["wrong"]["bytes"][1] = 0
            elif fault == "grid":
                c["row"][0] = 48
            elif fault == "code":
                c["loaded_bytes"][0] ^= 1
            elif fault == "cost":
                c["helper_code_bytes"] = 0
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            else:
                r["cases"]["repaired"]["loaded_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_table_include(self):
        with self.assertRaisesRegex(AssertionError, "table"):
            C.tables((C.V.F / "cases.inc").read_text(), "case_table:\n    !byte 0\n")

    def test_pixels(self):
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["demo"])
        c["row"][0] = 48
        cfg = json.loads((C.V.V / "configuration.json").read_text())
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c, cfg)


if __name__ == "__main__":
    unittest.main()
