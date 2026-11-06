"""Falsify native timer, policy, input and visible-output claims."""

import copy
import hashlib
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
            if fault == "configuration":
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

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["custom"]
        c["loaded_prg_bytes"][0] ^= 1
        prg = bytes(c["loaded_prg_bytes"])
        c["loaded_prg_sha256"] = hashlib.sha256(prg).hexdigest()
        f = bytes(C.font())
        cart = b"NES\x1a" + bytes([2, 1]) + bytes(10) + prg + f + bytes(8192 - len(f))
        c["cartridge_sha256"] = hashlib.sha256(cart).hexdigest()
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self) -> None:
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        C.check(r)


if __name__ == "__main__":
    unittest.main()
