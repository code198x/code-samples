"""Falsify the actual retained bytes and outcome guards."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checker", ROOT / "scripts/check-msx-gameboy-loops.py"
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
            for s, t in C.ROUTES
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

    def test_changed_source_fails(self) -> None:
        self.rejected(
            lambda r: r["sources"].update({next(iter(r["sources"])): "0" * 64})
        )

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
                if r["track"] == "assembly" and r["system"] == "msx"
            )
        )
        r["cases"]["working"]["returned_screen"] = [32] * 1000
        with self.assertRaises(ValueError):
            C.check_record(ROOT, r)

    def test_video_write_must_match_rule_state(self) -> None:
        r = copy.deepcopy(
            next(
                r
                for r in self.records
                if r["system"] == "msx" and r["track"] == "assembly"
            )
        )
        for event in r["cases"]["working"]["io_traces"]["first"]["events"]:
            if event["port"] == "$0098":
                event["value"] = "$00"
                break
        with self.assertRaises(ValueError):
            C.check_record(ROOT, r)

    def test_disabled_wait_cannot_use_normal_service_record(self) -> None:
        r = copy.deepcopy(
            next(r for r in self.records if r["system"] == "nintendo-game-boy")
        )
        r["cases"]["no-wait"] = copy.deepcopy(r["cases"]["working"])
        with self.assertRaises(ValueError):
            C.check_record(ROOT, r)

    def test_unknown_language_route_fails(self) -> None:
        self.rejected(lambda r: r.update(track="forth"))


if __name__ == "__main__":
    unittest.main()
