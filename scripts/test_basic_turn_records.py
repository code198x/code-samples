"""Retained-evidence gates must reject missing bindings and false progression."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "turn_records", Path(__file__).with_name("check-basic-turn-records.py")
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Cannot load record checker")
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class EvidenceTests(unittest.TestCase):
    def test_real_records_and_corruptions(self) -> None:
        for system in C.SYSTEMS:
            original = json.loads(
                (
                    C.ROOT
                    / system
                    / "patterns/basic/framework/command-loop/verification/reusable/results.json"
                ).read_text()
            )
            C.check(system)
            mutations = [
                ("sources", {}),
                ("images", {}),
                ("traces", {**original["traces"], "default": [0, 1, 1]}),
                ("traces", {**original["traces"], "reset-mistake": [0, 1, 2]}),
                ("idle_frames_per_observation", 0),
                ("invalid_command_unchanged_in_working_callers", False),
            ]
            for key, value in mutations:
                with self.subTest(system=system, corruption=key, value=value):
                    record = copy.deepcopy(original)
                    record[key] = value
                    with self.assertRaises(ValueError):
                        C.check(system, record=record)

    def test_forged_typed_program_is_rejected(self) -> None:
        """A record claiming other typed BASIC is caught by the typed-text check."""
        for system in C.SYSTEMS:
            record = json.loads(
                (
                    C.ROOT
                    / system
                    / "patterns/basic/framework/command-loop/verification/reusable/results.json"
                ).read_text()
            )
            key = next(k for k in record["sources"] if k.endswith("/routines.bas"))
            record["sources"][key] = "0" * 64
            with (
                self.subTest(system=system),
                self.assertRaisesRegex(AssertionError, "^Typed program differs"),
            ):
                C.check(system, record=record)

    def test_observer_digests_are_provenance(self) -> None:
        """Changed observer script digests alone do not make a record stale."""
        for system in C.SYSTEMS:
            record = json.loads(
                (
                    C.ROOT
                    / system
                    / "patterns/basic/framework/command-loop/verification/reusable/results.json"
                ).read_text()
            )
            record["observer_sources"] = dict.fromkeys(
                record["observer_sources"], "0" * 64
            )
            with self.subTest(system=system):
                C.check(system, record=record)


if __name__ == "__main__":
    unittest.main()
