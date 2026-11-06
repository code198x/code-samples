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

    def test_forged_program_is_rebuilt(self) -> None:
        """A record claiming other program bytes or text is caught by the rebuild."""
        for system in C.SYSTEMS:
            record = json.loads(
                (C.folder_for(system) / "verification/results.json").read_text()
            )
            record["cases"]["nonzero"]["program_sha256"] = "0" * 64
            message = (
                "^Typed program differs"
                if system in ("bbc-micro", "acorn-electron")
                else "^Program bytes differ"
            )
            with (
                self.subTest(system=system),
                self.assertRaisesRegex(AssertionError, message),
            ):
                C.check(system, record)

    def test_source_digests_are_provenance(self) -> None:
        """Changed source or observer digests alone do not make a record stale."""
        for system in C.SYSTEMS:
            record = json.loads(
                (C.folder_for(system) / "verification/results.json").read_text()
            )
            record["sources"] = dict.fromkeys(record["sources"], "0" * 64)
            record["observer_sources"] = {}
            with self.subTest(system=system):
                C.check(system, record)


if __name__ == "__main__":
    unittest.main()
