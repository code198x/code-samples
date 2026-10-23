"""Prove that empty, stale and falsified Ace observations do not pass."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "ace_check", Path(__file__).with_name("check-ace-map.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class AceMaps(unittest.TestCase):
    def setUp(self) -> None:
        self.record = json.loads((C.V.FOLDER / "verification/results.json").read_text())

    def test_real_observations(self) -> None:
        C.validate(self.record)

    def test_falsifications(self) -> None:
        mutations = {
            "language": lambda r: r.update(language="assembly"),
            "machine": lambda r: r.update(machine="other"),
            "empty": lambda r: r.update(observations={}),
            "missing variant": lambda r: r["observations"].pop("wrong-stride"),
            "source": lambda r: r.update(sources={}),
            "emulator": lambda r: r.update(emulator_sha256="0" * 64),
            "ROM": lambda r: r.update(firmware_sha256="0" * 64),
            "missing limits": lambda r: r.update(limits=""),
            "empty cases": lambda r: r["observations"]["positive"].update(cases=[]),
            "incorrect claim": lambda r: r["observations"]["positive"]["cases"][
                0
            ].update(actual=[9, 1]),
            "missing display": lambda r: r["observations"]["positive"]["cases"][
                0
            ].update(screen_hex=""),
            "stale display": lambda r: r["observations"]["positive"]["cases"][1].update(
                screen_hex=r["observations"]["positive"]["cases"][0]["screen_hex"]
            ),
            "corrupted map": lambda r: r["observations"]["positive"][
                "final_map"
            ].__setitem__(1, 99),
            "rejected write modified map": lambda r: r["observations"]["positive"][
                "after_rejected_writes"
            ].__setitem__(0, 1),
            "customisation unchanged": lambda r: r["observations"]["closed-exit"][
                "properties"
            ].__setitem__(3, 4),
            "stride control passes": lambda r: r["observations"].update(
                {"wrong-stride": copy.deepcopy(r["observations"]["positive"])}
            ),
            "write control passes": lambda r: r["observations"].update(
                {"write-without-valid": copy.deepcopy(r["observations"]["positive"])}
            ),
            "stack": lambda r: r["observations"]["positive"].update(stack_sentinel=0),
            "zero allocation": lambda r: r["observations"]["positive"].update(
                dictionary_bytes=0
            ),
            "expanded RAM": lambda r: r["observations"]["positive"].update(
                ram_top=32768
            ),
            "missing allocation observation": lambda r: r["observations"][
                "positive"
            ].update(allocation_screens={}),
        }
        for name, change in mutations.items():
            with self.subTest(fault=name):
                record = copy.deepcopy(self.record)
                change(record)
                with self.assertRaises((AssertionError, KeyError, ValueError)):
                    C.validate(record)


if __name__ == "__main__":
    unittest.main()
