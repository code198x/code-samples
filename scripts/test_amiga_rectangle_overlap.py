"""Falsify each layer of the native word-rectangle gate."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-amiga-rectangle-overlap.py")
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
            "oracle",
            "wrong",
            "result",
            "code",
            "segments",
            "plane",
            "producer",
            "image",
            "repair",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["demo"]
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "configuration":
                r["configuration"]["kickstart_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "complete":
                c["guards"][1] = 0
            elif fault == "oracle":
                c["bytes"][0] ^= 1
            elif fault == "wrong":
                r["cases"]["wrong"]["bytes"][1] = 0
            elif fault == "result":
                c["result"] = 0
            elif fault == "code":
                c["executable_sha256"] = "0" * 64
            elif fault == "segments":
                c["segments"][0]["bytes"][0] ^= 1
            elif fault == "plane":
                c["plane_zlib"] = "789c030000000001"
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            else:
                r["cases"]["repaired"]["executable_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_table_include(self):
        with self.assertRaisesRegex(AssertionError, "table"):
            C.tables((C.V.F / "cases.inc").read_text(), "case_table:\n    dc.w 0\n")

    def test_pixels(self):
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["demo"])
        c["result"] = 0
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c)


if __name__ == "__main__":
    unittest.main()
