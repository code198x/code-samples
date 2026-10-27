"""Falsify compiled pool records, complete owner storage and native identities."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "pool_check", Path(__file__).with_name("check-blitz-object-pool.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing retained pool checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def original(self):
        return json.loads((C.V.V / "results.json").read_text())

    def test_native(self) -> None:
        C.check()

    def test_identities_and_completion(self) -> None:
        original = self.original()
        faults = [
            "route",
            "source",
            "configuration",
            "fixture",
            "fixture_program",
            "missing_single",
            "missing_full",
            "missing_min",
            "missing_age",
            "extra",
            "program",
            "producer",
            "image",
            "quit",
            "same_exit",
            "selection",
            "count",
            "stride",
            "allocation",
            "base",
            "upper_base",
            "hash",
            "wrong_owner",
            "custom_owner",
            "repair_owner",
        ]
        for fault in faults:
            r = copy.deepcopy(original)
            row = r["cases"]["cases"]
            if fault == "route":
                r["system"] = "other"
            elif fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "configuration":
                r["configuration"]["firmware_sha256"] = "0" * 64
            elif fault == "fixture":
                r["fixture"]["fixture_sha256"] = "0" * 64
            elif fault == "fixture_program":
                r["fixture"]["program_sha256"]["working"] = "0" * 64
            elif fault == "missing_single":
                r["cases"].pop("single")
            elif fault == "missing_full":
                r["cases"].pop("wrong-cases")
            elif fault == "missing_min":
                r["cases"].pop("extremes")
            elif fault == "missing_age":
                r["cases"].pop("age")
            elif fault == "extra":
                r["cases"]["unknown"] = copy.deepcopy(row)
            elif fault == "program":
                row["program_sha256"] = "0" * 64
            elif fault == "producer":
                row["server"]["version"] = "unknown"
            elif fault == "image":
                row["image_sha256"] = "0" * 64
            elif fault == "quit":
                row["quit_image_sha256"] = "0" * 64
            elif fault == "same_exit":
                row["quit_image_sha256"] = row["image_sha256"]
            elif fault == "selection":
                row["image"] = "caller-wrong-cases.png"
            elif fault == "count":
                row["case_count"] = 0
            elif fault == "stride":
                row["record_bytes"] = 1
            elif fault == "allocation":
                row["allocated_observer_bytes"] = 0
            elif fault == "base":
                row["bank_address"] = 0
            elif fault == "upper_base":
                row["bank_address"] = 2 * 1024 * 1024
            elif fault == "hash":
                row["packet_sha256"] = "0" * 64
            elif fault == "wrong_owner":
                r["cases"]["wrong"]["outputs"] = r["cases"]["working"]["outputs"]
            elif fault == "custom_owner":
                r["cases"]["custom"]["outputs"][0] = 8
            else:
                r["cases"]["repaired"]["outputs"][-1] = 0
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_rehashed_packets(self) -> None:
        original = self.original()
        controls = [
            ("cases", offset)
            for offset in (
                0,
                4,
                8,
                12,
                16,
                20,
                24,
                28,
                32,
                36,
                68,
                72,
                108,
                204,
                300,
                396,
                492,
                380935,
            )
        ]
        controls += [("wrong-cases", 204), ("repaired-cases", 300)]
        controls += [
            (name, offset)
            for name in ("boundaries", "extremes")
            for offset in (0, 4, 16, 20, 24, 28, 32, 36, 40, 72, 76, 112)
        ]
        controls += [
            ("age", offset)
            for offset in (0, 4, 8, 12, 16, 24, 40, 72, 76, 108, 112, 148, 463)
        ]
        for name, offset in controls:
            r = copy.deepcopy(original)
            row = r["cases"][name]
            row["packet"][offset] ^= 1
            row["packet_sha256"] = hashlib.sha256(bytes(row["packet"])).hexdigest()
            with (
                self.subTest(name=name, offset=offset),
                self.assertRaisesRegex(AssertionError, "packet differs"),
            ):
                C.check(r)

    def test_empty_model(self) -> None:
        with (
            patch.object(C.C, "cases", return_value=()),
            self.assertRaisesRegex(AssertionError, "full pool model"),
        ):
            C.check()

    def test_pixels(self) -> None:
        with (
            patch.object(C.V.A, "number", return_value=0),
            self.assertRaisesRegex(AssertionError, "pixels differ"),
        ):
            C.check()


if __name__ == "__main__":
    unittest.main()
