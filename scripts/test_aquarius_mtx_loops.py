"""Falsify the actual retained bytes and outcome guards."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checker", ROOT / "scripts/check-aquarius-mtx-loops.py"
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.records = [
            json.loads(
                (
                    ROOT
                    / s
                    / "patterns"
                    / t
                    / "framework/command-loop/verification/reusable-results.json"
                ).read_text()
            )
            for s in ("mattel-aquarius", "memotech-mtx")
            for t in ("basic", "assembly")
        ]

    def test_all_routes_pass(self) -> None:
        for r in self.records:
            with self.subTest(system=r["system"], track=r["track"]):
                C.check_record(ROOT, r)

    def rejected(self, change) -> None:
        for original in self.records:
            r = copy.deepcopy(original)
            change(r)
            with (
                self.subTest(system=r["system"], track=r["track"]),
                self.assertRaises(ValueError),
            ):
                C.check_record(ROOT, r)

    def test_empty_cases_fail(self) -> None:
        self.rejected(lambda r: r.update(cases={}))

    def test_missing_idle_fails(self) -> None:
        self.rejected(lambda r: r["cases"]["working"]["observations"].pop(1))

    def test_changed_count_fails(self) -> None:
        self.rejected(
            lambda r: r["cases"]["working"]["observations"][2].update(count=99)
        )

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of another program is caught only by the rebuild."""
        for original in self.records:
            r = copy.deepcopy(original)
            case = r["cases"]["nonzero"]
            if r["track"] == "assembly":
                case["loaded_bytes"][0] ^= 1
                case["loaded_sha256"] = hashlib.sha256(
                    bytes(case["loaded_bytes"])
                ).hexdigest()
                message = "^Program bytes differ"
            else:
                case["entered_source"] += " "
                message = "^Typed program differs"
            with (
                self.subTest(system=r["system"], track=r["track"]),
                self.assertRaisesRegex(AssertionError, message),
            ):
                C.check_record(ROOT, r)

    def test_source_digests_are_provenance(self) -> None:
        """Changed source or observer digests alone do not make a record stale."""
        for original in self.records:
            r = copy.deepcopy(original)
            r["sources"] = dict.fromkeys(r["sources"], "0" * 64)
            r["observer_sources"] = dict.fromkeys(r["observer_sources"], "0" * 64)
            with self.subTest(system=r["system"], track=r["track"]):
                C.check_record(ROOT, r)

    def test_changed_capture_fails(self) -> None:
        self.rejected(
            lambda r: r["cases"]["working"]["observations"][0].update(
                capture_sha256="0" * 64
            )
        )

    def test_reset_is_not_a_repair(self) -> None:
        self.rejected(
            lambda r: r["cases"].update(
                repaired=copy.deepcopy(r["cases"]["wrong-reset"])
            )
        )

    def test_blank_display_fails(self) -> None:
        self.rejected(
            lambda r: r["cases"]["working"]["observations"][2].update(
                memory=[32] * len(r["cases"]["working"]["observations"][2]["memory"])
            )
        )

    def test_loaded_bytes_fail_if_changed(self) -> None:
        for original in self.records:
            if original["track"] != "assembly":
                continue
            r = copy.deepcopy(original)
            r["cases"]["working"]["loaded_bytes"][0] ^= 1
            with self.assertRaises(ValueError):
                C.check_record(ROOT, r)

    def test_held_key_control_must_fail(self) -> None:
        for original in self.records:
            if original["track"] != "assembly":
                continue
            r = copy.deepcopy(original)
            r["cases"]["no-edge"] = copy.deepcopy(r["cases"]["working"])
            with self.assertRaises(ValueError):
                C.check_record(ROOT, r)

    def test_firmware_return_required(self) -> None:
        r = copy.deepcopy(
            next(
                r
                for r in self.records
                if r["track"] == "assembly" and r["system"] == "mattel-aquarius"
            )
        )
        r["cases"]["working"]["returned_screen"] = [32] * 1000
        with self.assertRaises(ValueError):
            C.check_record(ROOT, r)


if __name__ == "__main__":
    unittest.main()
