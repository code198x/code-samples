"""Require positive native records and falsification-sensitive evidence gates."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-dragon-basic-deadlines.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        C.check()

    def test_corruptions(self):
        original = json.loads((C.F / "verification/results.json").read_text())
        for fault in range(10):
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == 0:
                c["source_sha256"] = "0" * 64
            elif fault == 1:
                r["cases"].pop("repaired")
            elif fault == 2:
                c["samples"][0]["turn"] ^= 1
            elif fault == 3:
                c["samples"][4]["remaining"] ^= 1
            elif fault == 4:
                c["memory"]["program_bytes"][0] ^= 1
            elif fault == 5:
                c["memory"]["variable_extent"] += 1
            elif fault == 6:
                r["cases"]["boundaries"]["bytes"][2] ^= 1
            elif fault == 7:
                r["cases"]["wrong-boundary"]["oracle_matches"] = True
            elif fault == 8:
                c["image_sha256"] = "0" * 64
            else:
                r["firmware_sha256"] = {}
            with self.subTest(fault=fault), self.assertRaises(AssertionError):
                C.check(r)

    def test_forged_typed_program_is_rejected(self) -> None:
        """A record claiming another typed listing is caught by the typed-text check."""
        r = json.loads((C.F / "verification/results.json").read_text())
        r["cases"]["custom"]["source_sha256"] = "0" * 64
        with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
            C.check(r)

    def test_source_digests_are_provenance(self) -> None:
        """Changed source or script digests alone do not make a record stale."""
        r = json.loads((C.F / "verification/results.json").read_text())
        r["sources"] = dict.fromkeys(r["sources"], "0" * 64)
        C.check(r)


if __name__ == "__main__":
    unittest.main()
