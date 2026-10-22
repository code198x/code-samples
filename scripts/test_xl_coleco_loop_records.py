"""Adversarial checks for missing evidence, changed inputs and false behaviour."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "records", Path(__file__).with_name("check-xl-coleco-loop-records.py")
)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Checker missing")
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class RecordGuards(unittest.TestCase):
    def test_complete_records(self) -> None:
        for key in C.CONFIGS:
            with self.subTest(key=key):
                C.check(key)

    def test_false_or_incomplete_claims_fail(self) -> None:
        for key in C.CONFIGS:
            original = json.loads((C.paths(key)[1] / "results.json").read_text())
            for fault in (
                "empty-cases",
                "missing-source",
                "stale-source",
                "missing-observer",
                "wrong-language",
                "missing-images",
                "wrong-image",
                "wrong-tool",
                "missing-program",
                "wrong-progression",
                "false-repair",
                "missing-firmware",
            ):
                record = copy.deepcopy(original)
                if fault == "empty-cases":
                    record["variants"] = {}
                elif fault == "missing-source":
                    record["sources"] = {}
                elif fault == "stale-source":
                    record["sources"][next(iter(record["sources"]))] = "0" * 64
                elif fault == "missing-observer":
                    record["observer_sources"] = {}
                elif fault == "wrong-language":
                    record["language"] = "other"
                elif fault == "missing-images":
                    record["artifacts"] = {}
                elif fault == "wrong-image":
                    record["artifacts"][next(iter(record["artifacts"]))] = "0" * 64
                elif fault == "wrong-tool":
                    record["emulator_sha256"] = "0" * 64
                elif fault == "missing-program":
                    record["program_sha256"] = {}
                elif fault == "missing-firmware":
                    record["firmware_sha256"] = {}
                elif fault == "false-repair":
                    record["program_sha256"][
                        "fixed" if key == "atari-basic" else "fixed-edge"
                    ] = "0" * 64
                elif fault == "wrong-progression":
                    if key == "atari-basic":
                        record["variants"]["wrap"]["progression"][-1] = 256
                    else:
                        record["variants"]["wrap"]["states"]["second"][0] = 256
                with self.subTest(key=key, fault=fault), self.assertRaises(ValueError):
                    C.check(key, record)
            if key != "atari-basic":
                record = copy.deepcopy(original)
                record["variants"]["bad-wait"]["service_ticks_in_30_frames"] = 30
                with (
                    self.subTest(key=key, fault="false-timing-fault"),
                    self.assertRaises(ValueError),
                ):
                    C.check(key, record)
                record = copy.deepcopy(original)
                record["variants"]["held-as-press"]["states"]["held"] = record[
                    "variants"
                ]["held-as-press"]["states"]["pressed"]
                with (
                    self.subTest(key=key, fault="false-held-fault"),
                    self.assertRaises(ValueError),
                ):
                    C.check(key, record)


if __name__ == "__main__":
    unittest.main()
