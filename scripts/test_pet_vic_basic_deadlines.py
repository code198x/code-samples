"""Require the BASIC evidence gate to reject changed observations and RAM maps."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-pet-vic-basic-deadlines.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing BASIC checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        for system in C.V.SYSTEMS:
            C.check(system)

    def test_falsifications_fail(self) -> None:
        for system in C.V.SYSTEMS:
            original = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            for fault in range(14):
                r = copy.deepcopy(original)
                case = r["cases"]["working"]
                if fault == 0:
                    r["machine"] = "other"
                elif fault == 1:
                    r["sources"].pop(next(iter(r["sources"])))
                elif fault == 2:
                    r["cases"].pop("repaired")
                elif fault == 3:
                    case["samples"][0]["turn"] = 1
                elif fault == 4:
                    case["samples"][4]["remaining"] += 1
                elif fault == 5:
                    case["samples"][-3]["expiries"] = 0
                elif fault == 6:
                    case["memory"]["free_gap"] += 1
                elif fault == 7:
                    r["cases"]["boundaries"]["bytes"][2] ^= 1
                elif fault == 8:
                    r["cases"]["wrong-boundary"]["oracle_matches"] = True
                elif fault == 9:
                    case["image_sha256"] = "0" * 64
                elif fault == 10:
                    r["firmware_sha256"] = {}
                elif fault == 11:
                    case["memory"]["program_bytes"][0] ^= 1
                elif fault == 12:
                    case["memory"]["variable_names"][0] = "OTHER"
                else:
                    case["samples"][-1]["active"] = 1
                with (
                    self.subTest(system=system, fault=fault),
                    self.assertRaises((AssertionError, ValueError)),
                ):
                    C.check(system, r)


if __name__ == "__main__":
    unittest.main()
