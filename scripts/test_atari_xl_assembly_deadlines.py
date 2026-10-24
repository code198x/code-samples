"""Require corrupted Atari native observations to fail their retained gate."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checks", ROOT / "scripts/check-atari-xl-assembly-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self) -> None:
        C.check()

    def test_corruptions(self) -> None:
        original = json.loads((C.V.F / "verification/results.json").read_text())
        for fault in [
            "source",
            "case",
            "producer",
            "firmware",
            "state",
            "code",
            "capture",
            "boundary",
            "wrong-oracle",
            "return",
            "reservation",
            "snapshot",
            "pixels",
            "ready",
        ]:
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                r["emulator_sha256"] = "0" * 64
            elif fault == "firmware":
                r["firmware_sha256"][next(iter(r["firmware_sha256"]))] = "0" * 64
            elif fault == "state":
                c["samples"][2]["turn"] = 9
            elif fault == "code":
                c["loaded_bytes"][0] ^= 1
            elif fault == "capture":
                c["image_sha256"] = "0" * 64
            elif fault == "boundary":
                r["cases"]["boundaries"]["bytes"][-1] = 0
            elif fault == "wrong-oracle":
                r["cases"]["wrong-boundary"]["oracle_matches"] = True
            elif fault == "return":
                c["return_screen"]["bytes"] = [0] * 960
            elif fault == "reservation":
                c["reservation"]["ramtop"] = [128]
            elif fault == "snapshot":
                c["samples"][0]["stop"]["pc"] = 0
            elif fault == "ready":
                c["loader_ready"]["bytes"] = [0] * 960
            else:
                c["capture"]["glyphs"]["16"][0] ^= 128
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, IndexError, ValueError)),
            ):
                C.check(r)


if __name__ == "__main__":
    unittest.main()
