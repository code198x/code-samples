"""Challenge full native state, chunk coverage, ownership and evidence identities."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "flow_check", Path(__file__).with_name("check-blitz-game-flow.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing retained checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_native(self) -> None:
        C.check()

    def test_corruptions(self) -> None:
        original = json.loads((C.V.V / "results.json").read_text())
        controls = [
            "route",
            "source",
            "runtime",
            "fixture",
            "fixture_program",
            "missing_owner",
            "missing_chunk",
            "extra_chunk",
            "program",
            "producer",
            "image",
            "quit",
            "same_exit",
            "image_selection",
            "chunk_index",
            "start",
            "count",
            "total",
            "stride",
            "allocation",
            "address",
            "packet_hash",
            "custom",
            "wrong",
            "repair",
        ]
        for fault in controls:
            r = copy.deepcopy(original)
            row = r["cases"]["cases-0"]
            if fault == "route":
                r["language"] = "amos"
            elif fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "runtime":
                r["configuration"]["firmware_sha256"] = "0" * 64
            elif fault == "fixture":
                r["fixture"]["fixture_sha256"] = "0" * 64
            elif fault == "fixture_program":
                r["fixture"]["program_sha256"]["working"] = "0" * 64
            elif fault == "missing_owner":
                r["cases"].pop("small")
            elif fault == "missing_chunk":
                r["cases"].pop("cases-5")
            elif fault == "extra_chunk":
                r["cases"]["cases-6"] = copy.deepcopy(row)
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
            elif fault == "image_selection":
                row["image"] = "caller-cases-1.png"
            elif fault == "chunk_index":
                row["chunk_index"] = 1
            elif fault == "start":
                row["start_case"] = 64
            elif fault == "count":
                row["case_count"] = 0
            elif fault == "total":
                row["total_case_count"] = 64
            elif fault == "stride":
                row["record_bytes"] = 44
            elif fault == "allocation":
                row["allocated_observer_bytes"] = 0
            elif fault == "address":
                row["bank_address"] = 0
            elif fault == "packet_hash":
                row["packet_sha256"] = "0" * 64
            elif fault == "custom":
                r["cases"]["custom"]["outputs"][4] = 3
            elif fault == "wrong":
                r["cases"]["wrong"]["outputs"] = r["cases"]["working"]["outputs"]
            else:
                r["cases"]["repaired"]["outputs"][0] = 0
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_rehashed_packet_corruptions(self) -> None:
        original = json.loads((C.V.V / "results.json").read_text())
        # Complete field offsets cover high bits, pulses, preserved payload, INIT and guards.
        controls = [
            ("cases-0", n) for n in (0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 3079)
        ]
        controls += [
            ("cases-5", n) for n in (0, 40 * 48, 45 * 48 + 8, 45 * 48 + 28, 2215)
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
            self.assertRaisesRegex(AssertionError, "independent model"),
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
