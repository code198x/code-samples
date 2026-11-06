"""Prove the Atari BASIC evidence gate rejects damaged records."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checker", ROOT / "scripts/check-atari-xl-basic-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self) -> None:
        C.check()

    def test_corruptions(self) -> None:
        original = json.loads((C.F / "verification/results.json").read_text())
        for fault in [
            "forged",
            "case",
            "producer",
            "firmware",
            "state",
            "capture",
            "boundary",
            "oracle",
            "return",
            "reservation",
            "line",
            "variables",
            "pixels",
        ]:
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "forged":
                c["source_sha256"] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                r["emulator_sha256"] = "0" * 64
            elif fault == "firmware":
                r["firmware_sha256"][next(iter(r["firmware_sha256"]))] = "0" * 64
            elif fault == "state":
                c["samples"][2]["turn"] = 9
            elif fault == "capture":
                c["image_sha256"] = "0" * 64
            elif fault == "boundary":
                r["cases"]["boundaries"]["bytes"][-1] = 0
            elif fault == "oracle":
                r["cases"]["wrong-boundary"]["oracle_matches"] = True
            elif fault == "return":
                c["return_screen"]["bytes"] = [0] * 960
            elif fault == "reservation":
                c["layout"]["ramtop"] = [128]
            elif fault == "line":
                c["layout"]["program_bytes"][0] ^= 1
            elif fault == "variables":
                c["layout"]["value_bytes"][0] = 3
            else:
                c["capture"]["glyphs"]["16"][0] ^= 128
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, IndexError, ValueError)),
            ):
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
