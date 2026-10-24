"""A retained-evidence gate must reject changed native outcomes, not just go green."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checks", ROOT / "scripts/check-spectrum-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self):
        C.check_assembly()
        C.check_basic()

    def test_corruptions_are_rejected(self):
        for language, V, check in [
            ("assembly", C.A, C.check_assembly),
            ("basic", C.B, C.check_basic),
        ]:
            original = json.loads((V.F / "verification/results.json").read_text())
            for fault in [
                "source",
                "case",
                "producer",
                "firmware",
                "state",
                "capture",
                "boundary",
                "wrong-oracle",
                "return",
                "repair",
                "pixels",
            ]:
                r = copy.deepcopy(original)
                if fault == "source":
                    r["sources"][next(iter(r["sources"]))] = "0" * 64
                elif fault == "case":
                    r["cases"].pop("custom")
                elif fault == "producer":
                    r["emulator_sha256"] = "0" * 64
                elif fault == "firmware":
                    r["firmware_sha256"][next(iter(r["firmware_sha256"]))] = "0" * 64
                elif fault == "state":
                    r["cases"]["working"]["samples"][2]["turn"] = 9
                elif fault == "capture":
                    r["cases"]["working"]["image_sha256"] = "0" * 64
                elif fault == "boundary":
                    r["cases"]["boundaries"]["bytes"][-1] = 0
                elif fault == "wrong-oracle":
                    r["cases"]["wrong-boundary"]["oracle_matches"] = True
                elif fault == "return":
                    r["cases"]["working"]["return_screen"] = list(b"NOT RETURNED")
                elif fault == "repair":
                    r["cases"]["repaired"][
                        "loaded_bytes" if language == "assembly" else "program_sha256"
                    ] = [0] if language == "assembly" else "0" * 64
                elif fault == "pixels":
                    r["cases"]["working"]["pixels"]["scanlines"][0][0] ^= 1
                with (
                    self.subTest(language=language, fault=fault),
                    self.assertRaises(
                        (AssertionError, KeyError, ValueError, IndexError)
                    ),
                ):
                    check(r)

    def test_specific_spectrum_controls(self):
        original = json.loads((C.A.F / "verification/results.json").read_text())
        for fault in ["entry", "entry-control", "code"]:
            r = copy.deepcopy(original)
            if fault == "entry":
                r["cases"]["working"]["startup"][-1]["pc"] = 0
            elif fault == "entry-control":
                r["cases"]["no-entry"]["ready"] = [254, 202]
            else:
                r["cases"]["working"]["loaded_bytes"][0] ^= 1
            with self.subTest(fault=fault), self.assertRaises(AssertionError):
                C.check_assembly(r)
        original = json.loads((C.B.F / "verification/results.json").read_text())
        for fault in ["line", "variable", "observer", "program"]:
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "line":
                c["layout"]["lines"][0]["number"] = 99
            elif fault == "variable":
                c["layout"]["variable_bytes"][0] = 128
            elif fault == "observer":
                c["samples"][0]["raw"][18] = 0
            else:
                c["layout"]["program_bytes"][0] ^= 1
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, IndexError)),
            ):
                C.check_basic(r)

    def test_png_bytes_are_checked(self):
        for language, V, check in [
            ("assembly", C.A, C.check_assembly),
            ("basic", C.B, C.check_basic),
        ]:
            record = json.loads((V.F / "verification/results.json").read_text())
            p = record["cases"]["working"]["pixels"]
            p["glyphs"][str(ord(p["text"][0]))][0] ^= 128
            p["scanlines"] = [
                [p["glyphs"][str(ord(c))][y] for c in p["text"]] for y in range(8)
            ]
            with (
                self.subTest(language=language),
                self.assertRaisesRegex(AssertionError, "PNG differs"),
            ):
                check(record)


if __name__ == "__main__":
    unittest.main()
