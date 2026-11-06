"""False evidence must fail the rectangle publication gate."""

import copy
import hashlib
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
            if fault == "configuration":
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

    def test_forged_program_is_rebuilt(self):
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["wrong"]
        c["loaded_bytes"][0] ^= 1
        c["loaded_sha256"] = hashlib.sha256(
            bytes([1, 8] + c["loaded_bytes"])
        ).hexdigest()
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self):
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
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
