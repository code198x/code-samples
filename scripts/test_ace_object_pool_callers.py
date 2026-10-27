"""Falsify full-program pool execution evidence and native publication output."""

from __future__ import annotations

import importlib.util
import json
import unittest
from pathlib import Path
from typing import Any
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "ace_pool_caller_check",
    Path(__file__).with_name("check-ace-object-pool-callers.py"),
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing complete-caller checker")
K = importlib.util.module_from_spec(spec)
spec.loader.exec_module(K)


class Evidence(unittest.TestCase):
    def original(self, group: str = "working") -> dict[str, Any]:
        return json.loads((K.V.V / ("callers-" + group + ".json")).read_text())

    def reject(self, r: dict[str, Any], group: str = "working") -> None:
        with self.assertRaises((AssertionError, KeyError, ValueError, TypeError)):
            K.check_group(group, r)

    def test_complete_native_programs(self) -> None:
        K.check()

    def test_identity_load_and_stack(self) -> None:
        faults = (
            "complete",
            "group",
            "producer",
            "source",
            "runtime",
            "order",
            "size",
            "address",
            "program",
            "entered",
            "missing_demo",
            "missing_row",
            "extra_row",
            "recipe",
            "prefix",
            "top",
            "cpu",
            "empty_top",
            "empty_here",
            "empty_prefix",
        )
        for fault in faults:
            r = self.original()
            row = r["caller_rows"][-1]
            if fault == "complete":
                r["complete"] = False
            elif fault == "group":
                r["group"] = "other"
            elif fault == "producer":
                r["producer_sha256"] = "0" * 64
            elif fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "runtime":
                r["configuration"]["ram_top"] = 32768
            elif fault == "order":
                r["files"].reverse()
            elif fault == "size":
                r["sizes"]["caller.fth"] += 1
            elif fault == "address":
                r["addresses"]["SLOTS"] += 1
            elif fault == "program":
                r["program_sha256"] = "0" * 64
            elif fault == "entered":
                r["entered_source_sha256"] = "0" * 64
            elif fault == "missing_demo":
                r["demo_lines"].pop()
            elif fault == "missing_row":
                r["caller_rows"].pop()
            elif fault == "extra_row":
                r["caller_rows"].append(row.copy())
            elif fault == "recipe":
                r["entered_lines"][-1] = "DROP"
            elif fault == "prefix":
                row["prefix"] = 78
            elif fault == "top":
                row["data_top"] += 2
            elif fault == "cpu":
                row["cpu_sp"] = row["data_top"]
            elif fault == "empty_top":
                r["final_stack"]["data_top"] += 2
            elif fault == "empty_here":
                r["final_stack"]["dictionary"] += 2
            else:
                r["final_stack"]["screen_hex"] = "00" * 768
            with self.subTest(fault=fault):
                self.reject(r)

    def test_every_owner_context_and_array_cell(self) -> None:
        for group in K.B.VARIANTS:
            for field, keys in (
                ("state", K.C.C.NAMES),
                ("flags", range(9)),
                ("payload", range(9)),
            ):
                for key in keys:
                    r = self.original(group)
                    r["caller_rows"][-1][field][key] ^= 1
                    with self.subTest(group=group, field=field, key=key):
                        self.reject(r, group)

    def test_compiled_program_and_actual_pixels(self) -> None:
        for offset in (0, 77, 200, 668, 714, 818):
            r = self.original()
            raw = bytearray.fromhex(r["caller_rows"][-1]["dictionary_hex"])
            raw[offset] ^= 1
            r["caller_rows"][-1]["dictionary_hex"] = raw.hex()
            with self.subTest(offset=offset):
                self.reject(r)
        original = K.C.P.png
        for fault in ("width", "active_pixel", "ink"):

            def altered(path: Path, fault: str = fault) -> tuple:
                w, h, channels, data = original(path)
                if fault == "width":
                    return w - 1, h, channels, data
                data = bytearray(data)
                if fault == "active_pixel":
                    data[(48 * w + 32) * channels] ^= 1
                else:
                    for i in range(0, len(data), 4):
                        if data[i : i + 4] == bytes((207, 207, 207, 255)):
                            data[i] = 255
                return w, h, channels, data

            with self.subTest(fault=fault), patch.object(K.C.P, "png", altered):
                self.reject(self.original())
        with self.assertRaises(AssertionError):
            K.check({})


if __name__ == "__main__":
    unittest.main()
