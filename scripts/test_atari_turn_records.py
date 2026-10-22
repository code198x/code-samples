"""Adversarial controls for retained Atari execution evidence."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "records", Path(__file__).with_name("check-atari-turn-records.py")
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Cannot load checker")
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class EvidenceTests(unittest.TestCase):
    def test_records_and_corruptions(self) -> None:
        for system in C.V.SYSTEMS:
            original = json.loads(
                (
                    C.ROOT
                    / system
                    / "patterns/assembly/framework/turn-loop/verification/results.json"
                ).read_text()
            )
            C.check(system)
            for field in ["sources", "variants", "artifacts", "binaries"]:
                record = copy.deepcopy(original)
                record[field] = {}
                with (
                    self.subTest(system=system, field=field),
                    self.assertRaises(ValueError),
                ):
                    C.check(system, record)
            cases = [
                ("working", "service_ticks_in_30_frames", 0),
                ("working", "period_colour_clocks", [59964, 59964]),
                (
                    "held-as-press",
                    "states",
                    {
                        **original["variants"]["held-as-press"]["states"],
                        "held": original["variants"]["held-as-press"]["states"][
                            "pressed"
                        ],
                    },
                ),
            ]
            if system == "atari-2600":
                cases.append(("bad-service", "period_colour_clocks", [59736, 59736]))
            else:
                cases.append(("bad-service", "service_ticks_in_30_frames", 30))
            for variant, field, value in cases:
                record = copy.deepcopy(original)
                record["variants"][variant][field] = value
                with (
                    self.subTest(system=system, variant=variant, field=field),
                    self.assertRaises(ValueError),
                ):
                    C.check(system, record)


if __name__ == "__main__":
    unittest.main()
