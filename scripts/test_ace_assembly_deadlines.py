"""Require both generic assembly evidence and Ace-specific gates to fail red."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "C", Path(__file__).with_name("check-ace-assembly-deadlines.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_generic_corruptions(self):
        generic = C.load("base_tests", "test_dragon_assembly_deadlines.py")
        generic.exercise(self, "jupiter-ace")

    def test_loader_and_stock_memory(self):
        C.check()
        folder = C.V.F / "verification"
        original = json.loads((folder / "results.json").read_text())
        reg = json.loads((folder / "loader-regression.json").read_text())
        for fault in range(8):
            r = copy.deepcopy(original)
            g = copy.deepcopy(reg)
            case = r["cases"]["working"]
            if fault == 0:
                case["loader_steps"].pop()
            elif fault == 1:
                case["loader_steps"][-1]["here"] += 1
            elif fault == 2:
                case["ram_top"] = 32768
            elif fault == 3:
                case["exit_workspace"][4] ^= 1
            elif fault == 4:
                g["early"] = g["completed"]
            elif fault == 5:
                g["completed"][0] ^= 1
            elif fault == 6:
                case["capture"]["video_hex"] = "00" + case["capture"]["video_hex"][2:]
            else:
                case["capture"]["glyphs"]["48"][0] ^= 128
            with self.subTest(fault=fault), self.assertRaises(AssertionError):
                C.check(r, g)


if __name__ == "__main__":
    unittest.main()
