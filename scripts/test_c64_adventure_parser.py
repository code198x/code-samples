"""Reject falsified native parser, vocabulary, storage and visible-output claims."""

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-c64-adventure-parser.py")
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
            "load",
            "command",
            "marker",
            "typed",
            "vocabulary",
            "no-nouns",
            "prefix",
            "repair",
            "tokens",
            "scalar",
            "array",
            "image",
            "screen",
            "clock",
            "uninitialised",
        ):
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "configuration":
                r["configuration"]["emulator_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                c["server"]["version"] = "unknown"
            elif fault == "code":
                c["prg_bytes"][2] ^= 1
            elif fault == "load":
                c["loaded_bytes"][0] ^= 1
            elif fault == "command":
                c["bytes"][0] ^= 1
            elif fault == "marker":
                c["bytes"][3] = 0
            elif fault == "typed":
                r["cases"]["typed"]["samples"][0]["result"][1] = 1
            elif fault == "vocabulary":
                r["cases"]["duplicate"]["bytes"] = [0, 1]
            elif fault == "no-nouns":
                r["cases"]["no-nouns"]["bytes"][4] = 0
            elif fault == "prefix":
                r["cases"]["wrong"]["bytes"] = c["bytes"][:]
            elif fault == "repair":
                r["cases"]["repaired"]["program_sha256"] = "0" * 64
            elif fault == "tokens":
                c["layout"]["lines"][0][1] += 1
            elif fault == "scalar":
                c["layout"]["scalar_bytes"] += 7
            elif fault == "array":
                c["layout"]["array_bytes"] = 0
            elif fault == "image":
                c["image_sha256"] = "0" * 64
            elif fault == "clock":
                c["layout"]["scalars"]["JT"] = 0
            elif fault == "uninitialised":
                r["cases"]["uninitialised"]["bytes"][0] = 0
            else:
                c["screen"][0] ^= 1
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["custom"]
        c["prg_bytes"][-3] ^= 1
        c["loaded_bytes"] = c["prg_bytes"][2:]
        c["program_sha256"] = hashlib.sha256(bytes(c["prg_bytes"])).hexdigest()
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self):
        """Changed source or listing text digests alone do not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        for c in r["cases"].values():
            c["source_sha256"] = "0" * 64
        C.check(r)

    def test_coupled_pixels(self):
        c = copy.deepcopy(
            json.loads((C.V.V / "results.json").read_text())["cases"]["working"]
        )
        key = str(c["screen"][0])
        c["visible_glyphs"][key][0] ^= 1
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c, "working")


if __name__ == "__main__":
    unittest.main()
