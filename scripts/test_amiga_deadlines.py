"""Native timer evidence must reject missing, altered and coupled wrong claims."""

import copy
import hashlib
import importlib.util
import json
import unittest
import zlib
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-amiga-deadlines.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


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
            "hunk",
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
            "lifecycle",
            "stop",
            "ratio",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["demo"]
            by = {v["stage"]: v for v in c["samples"]}
            if fault == "configuration":
                r["configuration"]["emulator_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "code":
                c["segments"][0]["bytes"][0] ^= 1
            elif fault == "hunk":
                c["executable_sha256"] = "0" * 64
            elif fault == "input":
                by["first-action"]["controls"] = 0
            elif fault == "hold":
                by["held-action"]["turns"] = 2
            elif fault == "untimed":
                by["untimed-idle"]["turns"] = 1
            elif fault == "toggle":
                by["held-toggle"]["deadline"][2] = 0
            elif fault == "slow":
                c["slow_ticks"] = 0
            elif fault == "disabled":
                by["disabled-idle"]["expiries"] += 1
            elif fault == "reenable":
                by["second-expiry"]["expiries"] = by["disabled-idle"]["expiries"]
            elif fault == "freeze":
                c["frozen_clock_after"] = c["capture"]["clock"]
            elif fault == "cost":
                c["clock_state_bytes"] = 0
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            elif fault == "math":
                r["cases"]["boundaries"]["words"][1] ^= 1
            elif fault == "policy":
                r["cases"]["boundaries"]["words"][61] ^= 1
            elif fault == "wrong":
                r["cases"]["wrong-boundary"]["math_matches"] = True
            elif fault == "repair":
                r["cases"]["repaired"]["executable_sha256"] = "0" * 64
            elif fault == "lifecycle":
                r["cases"]["lifecycle"]["words"][3] = 0
            elif fault == "stop":
                r["cases"]["lifecycle"]["stopped_after"] += 1
            else:
                c["tick_interval"][1] += 1
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["custom"]
        raw = bytearray(zlib.decompress(bytes.fromhex(c["hunk_zlib"])))
        _, relocs = C.V.H.hunk(bytes(raw))
        moved = {i + k for i in relocs for k in range(4)}
        i = next(i for i in range(len(raw) - 32) if i not in moved)
        raw[32 + i] ^= 1  # the code hunk's body starts 32 bytes in
        c["hunk_zlib"] = zlib.compress(bytes(raw)).hex()
        c["executable_sha256"] = hashlib.sha256(raw).hexdigest()
        for seg in c["segments"]:
            if seg["first"] <= i < seg["last"]:
                seg["bytes"][i - seg["first"]] ^= 1
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self):
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        for c in r["cases"].values():
            c["source_sha256"] = "0" * 64
        C.check(r)

    def test_coupled_pixels(self):
        c = copy.deepcopy(
            json.loads((C.V.V / "results.json").read_text())["cases"]["demo"]
        )
        c["display"][0] ^= 1
        with self.assertRaisesRegex(AssertionError, "Bitplane"):
            C.pixels(c)


if __name__ == "__main__":
    unittest.main()
