"""Prove incomplete or falsified retained observations fail the gate."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "loop_records", Path(__file__).with_name("check-loop-language-records.py")
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Checker missing")
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class RecordGuards(unittest.TestCase):
    def test_complete_records(self) -> None:
        for system in C.SYSTEMS:
            with self.subTest(system=system):
                C.check(system)

    def test_rejects_missing_and_false_claims(self) -> None:
        for system in C.SYSTEMS:
            original = json.loads(
                (C.folder_for(system) / "verification/results.json").read_text()
            )
            for fault in (
                "no-cases",
                "missing-case",
                "no-sources",
                "wrong-source",
                "no-observer",
                "wrong-machine",
                "no-images",
                "wrong-tool",
                "false-progression",
                "false-repair",
                "fault-did-not-fail",
                "no-firmware",
            ):
                record = copy.deepcopy(original)
                if fault == "no-cases":
                    record["cases"] = {}
                elif fault == "missing-case":
                    del record["cases"]["fixed"]
                elif fault == "no-sources":
                    record["sources"] = {}
                elif fault == "wrong-source":
                    record["sources"][next(iter(record["sources"]))] = "0" * 64
                elif fault == "no-observer":
                    record["observer_sources"] = {}
                elif fault == "wrong-machine":
                    record["machine_id"] = "other"
                elif fault == "no-images":
                    record["artifacts"] = {}
                elif fault == "wrong-tool":
                    record["executable_sha256"] = "0" * 64
                elif fault == "false-progression":
                    record["cases"]["wrap"]["progression"][-1] = 256
                elif fault == "false-repair":
                    record["cases"]["fixed"] = copy.deepcopy(record["cases"]["wrong"])
                elif fault == "fault-did-not-fail":
                    record["cases"]["wrong"] = copy.deepcopy(record["cases"]["default"])
                elif fault == "no-firmware":
                    record["firmware_sha256"] = {}
                with (
                    self.subTest(system=system, fault=fault),
                    self.assertRaises(ValueError),
                ):
                    C.check(system, record)


if __name__ == "__main__":
    unittest.main()
