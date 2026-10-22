"""Falsify retained-evidence guards without changing qualified files."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checker", ROOT / "scripts/check-dragon-ace-loops.py"
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.records = []
        for system, track in [("dragon-32", "basic"), ("jupiter-ace", "forth")]:
            for language, file in [
                (track, "variants.json"),
                ("assembly", "results.json"),
            ]:
                path = (
                    ROOT
                    / system
                    / "patterns"
                    / language
                    / "framework/command-loop/verification"
                    / file
                )
                cls.records.append(
                    (
                        json.loads(path.read_text()),
                        system == "dragon-32",
                        language == "assembly",
                    )
                )

    def test_retained_records_pass(self) -> None:
        for record, dragon, assembly in self.records:
            with self.subTest(dragon=dragon, assembly=assembly):
                C.check_record(ROOT, record, dragon, assembly)

    def rejected(self, change) -> None:
        for original, dragon, assembly in self.records:
            record = copy.deepcopy(original)
            change(record)
            with (
                self.subTest(dragon=dragon, assembly=assembly),
                self.assertRaises(ValueError),
            ):
                C.check_record(ROOT, record, dragon, assembly)

    def test_empty_cases_fail(self) -> None:
        self.rejected(lambda r: r.update(cases={}))

    def test_missing_idle_fails(self) -> None:
        self.rejected(lambda r: r["cases"]["working"]["observations"].pop(1))

    def test_claimed_count_cannot_replace_screen(self) -> None:
        self.rejected(
            lambda r: r["cases"]["working"]["observations"][2].update(count=90)
        )

    def test_blank_screen_fails(self) -> None:
        self.rejected(
            lambda r: r["cases"]["working"]["observations"][2].update(screen=[32] * 160)
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

    def test_reset_fault_cannot_claim_repair(self) -> None:
        self.rejected(
            lambda r: r["cases"].update(
                repaired=copy.deepcopy(r["cases"]["wrong-reset"])
            )
        )

    def test_loaded_bytes_are_bound(self) -> None:
        for original, dragon, assembly in self.records:
            if not assembly:
                continue
            record = copy.deepcopy(original)
            record["cases"]["working"]["loaded_bytes"][0] ^= 1
            with self.assertRaises(ValueError):
                C.check_record(ROOT, record, dragon, assembly)

    def test_return_requires_visible_firmware_result(self) -> None:
        for original, dragon, assembly in self.records:
            if not assembly:
                continue
            record = copy.deepcopy(original)
            record["cases"]["working"]["returned_screen"] = [32] * 768
            with self.assertRaises(ValueError):
                C.check_record(ROOT, record, dragon, assembly)


if __name__ == "__main__":
    unittest.main()
