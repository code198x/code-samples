"""The NES release evidence gate must reject false observations."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "check", ROOT / "scripts/check-nes-input-edges.py"
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
            "source",
            "case",
            "producer",
            "guard",
            "code",
            "input",
            "history",
            "rows",
            "capture",
            "matrix",
            "wrong-control",
            "repair",
        ]:
            r = copy.deepcopy(original)
            c = r["cases"]["working"]
            if fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "case":
                r["cases"].pop("custom")
            elif fault == "producer":
                r["emulator_sha256"] = "0" * 64
            elif fault == "guard":
                r["cases"]["boundaries"]["end_guard"] = 0
            elif fault == "code":
                c["native_prg_sha256"] = "0" * 64
            elif fault == "input":
                c["samples"][1]["state"]["controls"] = 0
            elif fault == "history":
                c["samples"][2]["state"]["press_events"] = 2
            elif fault == "rows":
                r["cases"]["boundaries"]["row_count"] = 0
            elif fault == "capture":
                c["image_sha256"] = "0" * 64
            elif fault == "matrix":
                r["cases"]["boundaries"]["mismatches"] = 1
            elif fault == "wrong-control":
                r["cases"]["wrong-boundary"]["oracle_matches"] = True
            else:
                r["cases"]["repaired"]["cart_sha256"] = "0" * 64
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, IndexError, ValueError)),
            ):
                C.check(r)

    def test_pixels(self) -> None:
        r = json.loads((C.V.V / "results.json").read_text())
        c = copy.deepcopy(r["cases"]["working"])
        c["capture"]["state"]["actions"] = 4
        with self.assertRaisesRegex(AssertionError, "PNG"):
            C.pixels(c)


if __name__ == "__main__":
    unittest.main()
