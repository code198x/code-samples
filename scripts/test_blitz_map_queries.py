"""Publication controls must reject incomplete or false original-runtime records."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-blitz-map-queries.py")
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
            "fixture",
            "program",
            "complete",
            "decode",
            "oracle",
            "guard",
            "wrong",
            "image",
            "allocation",
            "property",
            "producer",
            "small",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "configuration":
                r["configuration"]["runtime_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "fixture":
                r["fixture"]["program_sha256"]["working"] = "0" * 64
            elif fault == "program":
                c["program_sha256"] = "0" * 64
            elif fault == "complete":
                c["bytes"][-1] = 0
            elif fault == "decode":
                c["values"][0][0] = 0
            elif fault == "oracle":
                c["bytes"][7] = 3
                c["values"] = C.unpack(c["bytes"], 64)
            elif fault == "guard":
                c["bytes"][163] = 0
                c["values"] = C.unpack(c["bytes"], 64)
            elif fault == "wrong":
                r["cases"]["wrong"]["values"][7][1] = 3
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            elif fault == "allocation":
                c["allocation_bytes"] = 0
            elif fault == "property":
                r["cases"]["custom"]["exit_property"] = 2
            elif fault == "small":
                r["cases"]["small"]["outputs"][2] = 1
            else:
                c["server"]["version"] = "unknown"
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_pixels(self):
        r = json.loads((C.V.V / "results.json").read_text())
        r["cases"]["custom"]["image"] = r["cases"]["working"]["image"]
        r["cases"]["custom"]["image_sha256"] = r["cases"]["working"]["image_sha256"]
        with self.assertRaisesRegex(AssertionError, "Property customisation"):
            C.check(r)


if __name__ == "__main__":
    unittest.main()
