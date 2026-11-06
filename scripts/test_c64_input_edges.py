"""The C64 release evidence gate must reject false observations."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "check", ROOT / "scripts/check-c64-input-edges.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self) -> None:
        C.check()

    def test_falsifications(self) -> None:
        original = json.loads((C.V.V / "results.json").read_text())
        for fault in [
            "case",
            "producer",
            "firmware",
            "code",
            "input",
            "history",
            "row",
            "capture",
            "matrix",
            "wrong-control",
            "repair",
        ]:
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                r["emulator_sha256"] = "0" * 64
            elif fault == "firmware":
                r["firmware_sha256"]["chargen.rom"] = "0" * 64
            elif fault == "code":
                c["loaded_bytes"][0] ^= 1
            elif fault == "input":
                c["samples"][1]["state"]["joy2"] = 0
            elif fault == "history":
                c["samples"][2]["state"]["press_events2"] = 2
            elif fault == "row":
                c["samples"][1]["row"][0] = 0
            elif fault == "capture":
                c["image_sha256"] = "0" * 64
            elif fault == "matrix":
                r["cases"]["boundaries"]["bytes"][17] ^= 1
            elif fault == "wrong-control":
                r["cases"]["wrong-boundary"]["oracle_matches"] = True
            else:
                r["cases"]["repaired"]["loaded_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, IndexError, ValueError)),
            ):
                C.check(r)

    def test_pixels(self) -> None:
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["working"])
        c["capture"]["row"][1] = 49
        cfg = json.loads((C.V.V / "configuration.json").read_text())
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c, cfg["glyphs"])

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""
        r = json.loads((C.V.V / "results.json").read_text())
        c = r["cases"]["custom"]
        c["loaded_bytes"][0] ^= 1
        c["loaded_sha256"] = hashlib.sha256(bytes(c["loaded_bytes"])).hexdigest()
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            C.check(r)

    def test_source_digests_are_provenance(self) -> None:
        """Changed, added or removed source text alone does not make a record stale."""
        r = json.loads((C.V.V / "results.json").read_text())
        r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
        C.check(r)


if __name__ == "__main__":
    unittest.main()
