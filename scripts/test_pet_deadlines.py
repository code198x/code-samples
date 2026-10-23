"""Make the retained-evidence gate reject falsified successful observations."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-pet-deadlines.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        for system in C.V.SYSTEMS:
            C.check(system)

    def test_falsifications_fail(self) -> None:
        for system in C.V.SYSTEMS:
            original = json.loads(
                (
                    C.ROOT
                    / system
                    / "patterns/assembly/framework/turn-deadline/verification/results.json"
                ).read_text()
            )
            for fault in range(12):
                r = copy.deepcopy(original)
                if fault == 0:
                    r["machine"] = "other"
                elif fault == 1:
                    r["sources"].pop(next(iter(r["sources"])))
                elif fault == 2:
                    r["cases"].pop("repaired")
                elif fault == 3:
                    r["cases"]["working"]["observations"][0]["turns"] = 1
                elif fault == 4:
                    r["cases"]["working"]["observations"][4]["remaining"] += 1
                elif fault == 5:
                    r["cases"]["working"]["observations"][5]["expiries"] = 0
                elif fault == 6:
                    r["cases"]["custom-duration"]["observations"][0]["duration"] = 240
                elif fault == 7:
                    r["cases"]["boundaries"]["fixture"][3] ^= 1
                elif fault == 8:
                    r["cases"]["wrong-midnight"]["oracle_matches"] = True
                elif fault == 9:
                    r["cases"]["working"]["image_sha256"] = "0" * 64
                elif fault == 10:
                    r["cases"]["working"]["firmware_sha256"] = {}
                else:
                    r["cases"]["working"]["observations"][-1]["active"] = 1
                with (
                    self.subTest(system=system, fault=fault),
                    self.assertRaises(AssertionError),
                ):
                    C.check(system, r)


if __name__ == "__main__":
    unittest.main()
