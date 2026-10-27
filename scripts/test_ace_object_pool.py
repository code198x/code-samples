"""Falsify native pool records, complete storage, stack and compiled identity."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path
from typing import Any
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "ace_pool_check", Path(__file__).with_name("check-ace-object-pool.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing pool checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def original(self, group: str = "bounds") -> dict[str, Any]:
        return json.loads((C.V.V / (group + ".json")).read_text())

    def reject(self, record: dict[str, Any], group: str = "bounds") -> None:
        with self.assertRaises((AssertionError, KeyError, ValueError, TypeError)):
            C.check_group(group, record)

    def test_complete_native(self) -> None:
        C.check()

    def test_bounds_identity_and_coverage(self) -> None:
        C.check_group("bounds", self.original())
        faults = (
            "complete",
            "source",
            "runtime",
            "files",
            "sizes",
            "here",
            "before",
            "addresses",
            "alias",
            "recipe_hash",
            "initial",
            "missing_row",
            "extra_row",
            "swapped_rows",
            "tag",
            "operation",
            "argument",
            "base",
            "owner",
            "recipe_line",
            "missing_recipe",
            "top",
            "cpu",
            "prefix",
        )
        for fault in faults:
            with self.subTest(fault=fault):
                r = self.original()
                row = r["rows"][0]
                if fault == "complete":
                    r["complete"] = False
                elif fault == "source":
                    r["sources"][next(iter(r["sources"]))] = "0" * 64
                elif fault == "runtime":
                    r["configuration"]["ram_top"] = 32768
                elif fault == "files":
                    r["files"].reverse()
                elif fault == "sizes":
                    r["sizes"]["routines.fth"] += 1
                elif fault in ("here", "before"):
                    r[fault] += 1
                elif fault == "addresses":
                    r["addresses"]["PB"] += 2
                elif fault == "alias":
                    r["addresses"]["PB"] = r["addresses"]["PC"]
                elif fault == "recipe_hash":
                    r["entered_source_sha256"] = "0" * 64
                elif fault == "initial":
                    r["dictionary_before_hex"] = r["dictionary_before_hex"][:-2]
                elif fault == "missing_row":
                    r["rows"].pop()
                elif fault == "extra_row":
                    r["rows"].append(copy.deepcopy(row))
                elif fault == "swapped_rows":
                    r["rows"][0], r["rows"][1] = r["rows"][1], r["rows"][0]
                elif fault in ("tag", "operation"):
                    row[fault] = "other"
                elif fault in ("argument", "base"):
                    row[fault] += 1
                elif fault == "owner":
                    row["owner"] = True
                elif fault == "recipe_line":
                    r["entered_lines"][-1] = "DROP"
                elif fault == "missing_recipe":
                    r["entered_lines"].pop()
                elif fault == "top":
                    row["data_top"] += 2
                elif fault == "cpu":
                    row["cpu_sp"] = row["data_top"]
                elif fault == "prefix":
                    row["stack"][0] = 78
                self.reject(r)

    def test_bounds_all_cells_and_storage(self) -> None:
        for field in ("state", "before_state"):
            for name in C.C.NAMES:
                r = self.original()
                r["rows"][0][field][name] ^= 32768
                with self.subTest(field=field, name=name):
                    self.reject(r)
        for field in ("flags", "before_flags", "payload", "before_payload"):
            for index in range(9):
                r = self.original()
                r["rows"][0][field][index] ^= 1
                with self.subTest(field=field, index=index):
                    self.reject(r)
        r = self.original()
        r["rows"][0]["stack"][-1] ^= 1
        self.reject(r)

    def test_raw_compiled_code_and_owned_data(self) -> None:
        offsets = [0, 77, 200, 500, 818]
        offsets += [C.ADDRESS[name] - 15460 for name in C.C.NAMES]
        offsets += [C.ADDRESS["SLOTS"] - 15460 + i for i in range(9)]
        offsets += [C.ADDRESS["PAYLOAD"] - 15460 + i * 2 for i in range(9)]
        for offset in offsets:
            r = self.original()
            raw = bytearray.fromhex(r["rows"][0]["dictionary_hex"])
            raw[offset] ^= 1
            r["rows"][0]["dictionary_hex"] = raw.hex()
            with self.subTest(offset=offset):
                self.reject(r)
        # Alter both compiled reference and every sample: unchanged-code masks
        # alone would accept this forged program; the exact producer image fails.
        r = self.original()
        for item, key in [(r, "dictionary_before_hex")] + [
            (row, "dictionary_hex") for row in r["rows"]
        ]:
            raw = bytearray.fromhex(item[key])
            raw[200] ^= 1
            item[key] = raw.hex()
        self.reject(r)

    def test_capture_and_empty_controls(self) -> None:
        for fault in ("image", "sha", "screen", "glyph", "pixel_flag"):
            r = self.original()
            capture = r["capture"]
            if fault == "image":
                capture["image"] = "other.png"
            elif fault == "sha":
                capture["sha256"] = "0" * 64
            elif fault == "screen":
                capture["pixels"]["video_hex"] = "00"
            elif fault == "glyph":
                capture["pixels"]["glyphs"] = {}
            else:
                capture["pixels"]["pixel_match"] = False
            with self.subTest(fault=fault):
                self.reject(r)
        original = C.P.png
        for fault in ("width", "pixel", "white"):

            def altered(path: Path, fault: str = fault) -> tuple:
                w, h, n, data = original(path)
                if fault == "width":
                    return w - 1, h, n, data
                data = bytearray(data)
                if fault == "white":
                    for i in range(0, len(data), 4):
                        if data[i : i + 4] == bytes((207, 207, 207, 255)):
                            data[i : i + 3] = bytes((255, 255, 255))
                else:
                    data[(48 * w + 32) * n] ^= 1
                return w, h, n, data

            with self.subTest(fault=fault), patch.object(C.P, "png", altered):
                self.reject(self.original())
        with patch.object(C, "scenario", lambda _: iter(())):
            self.reject(self.original())
        with self.assertRaises(AssertionError):
            C.check({})

    def test_owner_and_mask_semantics(self) -> None:
        for group in ("working", "custom", "single", "wrong", "repaired", "masks"):
            r = self.original(group)
            C.check_group(group, r)
            for field, key in (
                ("state", "PK"),
                ("state", "PF"),
                ("state", "PX"),
                ("payload", 0),
                ("payload", 8),
                ("flags", 8),
            ):
                changed = copy.deepcopy(r)
                changed["rows"][-1][field][key] ^= 1
                with self.subTest(group=group, field=field, key=key):
                    self.reject(changed, group)


if __name__ == "__main__":
    unittest.main()
