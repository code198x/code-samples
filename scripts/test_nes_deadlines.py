"""Falsify native timer, policy, input and visible-output claims."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-nes-deadlines.py")
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
            "producer",
            "code",
            "cartridge",
            "input",
            "hold",
            "untimed",
            "toggle",
            "slow",
            "disabled",
            "reenable",
            "freeze",
            "cost",
            "image",
            "math",
            "policy",
            "wrong",
            "repair",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["demo"]
            by = {s["stage"]: s for s in c["samples"]}
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "configuration":
                r["configuration"]["emulator_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "code":
                c["loaded_prg_bytes"][0] ^= 1
            elif fault == "cartridge":
                c["cartridge_sha256"] = "0" * 64
            elif fault == "input":
                by["first-action"]["controls"] = 0
            elif fault == "hold":
                by["held-action"]["state"][4] = 2
            elif fault == "untimed":
                by["untimed-idle"]["state"][4] = 1
            elif fault == "toggle":
                by["held-select"]["deadline"][4] = 0
            elif fault == "slow":
                c["slow_ticks"] = 0
            elif fault == "disabled":
                by["disabled-idle"]["state"][6] += 1
            elif fault == "reenable":
                by["second-expiry"]["state"][6] = by["disabled-idle"]["state"][6]
            elif fault == "freeze":
                c["frozen_clock_after"] = c["capture"]["clock"]
            elif fault == "cost":
                c["clock_state_bytes"] = 0
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            elif fault == "math":
                r["cases"]["boundaries"]["bytes"][1] ^= 1
            elif fault == "policy":
                r["cases"]["boundaries"]["bytes"][1 + len(C.V.expected_math())] ^= 1
            elif fault == "wrong":
                r["cases"]["wrong-boundary"]["math_matches"] = True
            else:
                r["cases"]["repaired"]["cartridge_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_pixels(self):
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["demo"])
        c["display"][0] ^= 1
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c)


if __name__ == "__main__":
    unittest.main()
