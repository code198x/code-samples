"""Challenge stock-ROM state proof, compiled words, stack discipline and pixels."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path
from typing import Any
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "ace_flow_check", Path(__file__).with_name("check-ace-game-flow.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing retained Ace checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def original(self) -> dict[str, Any]:
        return json.loads((C.V.V / "native.json").read_text())

    def test_native(self) -> None:
        C.check()

    def test_identity_coverage_and_stack(self) -> None:
        original = self.original()
        controls = [
            "route",
            "source",
            "runtime",
            "missing_table",
            "missing_owner",
            "extra_owner",
            "ram",
            "order",
            "entered",
            "extent",
            "address",
            "alias",
            "producer",
            "missing_row",
            "swapped_row",
            "input",
            "command",
            "counter",
            "tag",
            "dictionary",
            "top",
            "cpu",
            "gap",
            "missing_wait",
            "wait_top",
            "wait_cpu",
            "owner_count",
            "held",
            "frame",
            "owner_tag",
            "custom",
            "wrong",
            "image",
            "screen_flag",
        ]
        for fault in controls:
            r = copy.deepcopy(original)
            table = r["cases"]["table"]
            row = table["rows"][0]
            if fault == "route":
                r["language"] = "other"
            elif fault == "source":
                r["sources"][next(iter(r["sources"]))] = "0" * 64
            elif fault == "runtime":
                r["configuration"]["firmware_sha256"] = "0" * 64
            elif fault == "missing_table":
                r["cases"].pop("table")
            elif fault == "missing_owner":
                r["cases"].pop("repaired")
            elif fault == "extra_owner":
                r["cases"]["unknown"] = copy.deepcopy(table)
            elif fault == "ram":
                table["ram_top"] = 32768
            elif fault == "order":
                table["here_after_files"] = dict(
                    reversed(list(table["here_after_files"].items()))
                )
            elif fault == "entered":
                table["entered_source_sha256"] = "0" * 64
            elif fault == "extent":
                table["program_identity"]["bytes"] = 1
            elif fault == "address":
                table["addresses"]["GS"] = 0
            elif fault == "alias":
                table["addresses"]["GS"] = table["addresses"]["GE"]
            elif fault == "producer":
                table["server"]["version"] = "other"
            elif fault == "missing_row":
                table["rows"].pop()
            elif fault == "swapped_row":
                table["rows"][0], table["rows"][1] = table["rows"][1], table["rows"][0]
            elif fault == "input":
                row["inputs"][1] = 1
            elif fault == "command":
                row["command"] = "77 0 0 GICASE"
            elif fault == "counter":
                row["completed"] = 0
            elif fault == "tag":
                row["tag"] = 0
            elif fault == "dictionary":
                row["after_return"]["dictionary"] += 2
            elif fault == "top":
                row["after_return"]["data_top"] -= 2
            elif fault == "cpu":
                row["after_return"]["cpu_sp"] = row["after_return"]["data_top"]
            elif fault == "gap":
                row["after_return"]["separation"] += 2
            elif fault == "missing_wait":
                row.pop("while_waiting")
            elif fault == "wait_top":
                row["while_waiting"]["data_top"] = table["here"] + 20
            elif fault == "wait_cpu":
                row["while_waiting"]["cpu_sp"] = 16385
            elif fault == "owner_count":
                r["cases"]["working"]["rows"].pop()
            elif fault == "held":
                r["cases"]["working"]["rows"][1]["held"] = 0
            elif fault == "frame":
                r["cases"]["working"]["rows"][1]["frame"] = 0
            elif fault == "owner_tag":
                r["cases"]["working"]["tag"] = 0
            elif fault == "custom":
                r["cases"]["custom"]["outputs"][4] = 3
            elif fault == "wrong":
                r["cases"]["wrong"]["outputs"] = r["cases"]["working"]["outputs"]
            elif fault == "image":
                table["capture"]["image_sha256"] = "0" * 64
            else:
                table["capture"]["pixels"]["pixel_match"] = False
            with (
                self.subTest(fault=fault),
                self.assertRaises((AssertionError, KeyError, ValueError)),
            ):
                C.check(r)

    def test_complete_cells_and_owner_context(self) -> None:
        original = self.original()
        for index in (0, 19, 47, 64, 318, 323, 363, 365):
            for field in range(9):
                r = copy.deepcopy(original)
                r["cases"]["table"]["rows"][index]["values"][field] ^= 256
                with (
                    self.subTest(index=index, field=field),
                    self.assertRaisesRegex(AssertionError, "state/payload"),
                ):
                    C.check(r)
        for name in ("working", "custom", "wrong", "repaired"):
            for field in C.V.NAMES + ("GP", "GV", "GH", "GL", "GR"):
                r = copy.deepcopy(original)
                r["cases"][name]["rows"][8]["state"][field] ^= 256
                with (
                    self.subTest(name=name, field=field),
                    self.assertRaisesRegex(AssertionError, "owner context"),
                ):
                    C.check(r)

    def test_rehashed_compiled_code(self) -> None:
        original = self.original()
        for name in ("table", "working", "custom", "wrong", "repaired"):
            for both in (False, True):
                r = copy.deepcopy(original)
                c = r["cases"][name]
                program = c["program_identity"]
                after = bytearray.fromhex(program["after_hex"])
                after[0] ^= 1
                program["after_hex"] = after.hex()
                program["after_sha256"] = hashlib.sha256(after).hexdigest()
                if both:
                    before = bytearray.fromhex(c["dictionary_before_hex"])
                    before[0] ^= 1
                    c["dictionary_before_hex"] = before.hex()
                    program["before_sha256"] = hashlib.sha256(before).hexdigest()
                with (
                    self.subTest(name=name, both=both),
                    self.assertRaisesRegex(AssertionError, "code or headers"),
                ):
                    C.check(r)

    def test_pixel_evidence(self) -> None:
        original = self.original()
        for fault in ("video", "glyph", "filename"):
            r = copy.deepcopy(original)
            c = r["cases"]["table"]["capture"]
            if fault == "video":
                raw = bytearray.fromhex(c["pixels"]["video_hex"])
                raw[-1] ^= 128
                c["pixels"]["video_hex"] = raw.hex()
            elif fault == "glyph":
                c["pixels"]["glyphs"]["32"][0] ^= 128
            else:
                c["image"] = "working-resumed.png"
            with self.subTest(fault=fault), self.assertRaises(AssertionError):
                C.check(r)
        with (
            patch.object(C.P, "png", return_value=(320, 288, 4, bytes(320 * 288 * 4))),
            self.assertRaisesRegex(AssertionError, "framebuffer"),
        ):
            C.check(original)

    def test_empty_model(self) -> None:
        with (
            patch.object(C.C, "cases", return_value=()),
            self.assertRaisesRegex(AssertionError, "independent model"),
        ):
            C.check()

    def test_wrong_emulator_ink(self) -> None:
        decode = C.P.png

        def wrong_ink(path: Path) -> tuple[int, int, int, bytearray]:
            width, height, channels, pixels = decode(path)
            raw = bytearray(pixels)
            for offset in range(0, len(raw), channels):
                if raw[offset : offset + 3] == bytes((207, 207, 207)):
                    raw[offset : offset + 3] = bytes((255, 255, 255))
            return width, height, channels, raw

        with (
            patch.object(C.P, "png", side_effect=wrong_ink),
            self.assertRaisesRegex(AssertionError, "framebuffer"),
        ):
            C.check()

    def test_compiled_owned_cells(self) -> None:
        original = self.original()
        for name in ("table", "working", "custom", "wrong", "repaired"):
            for initial in (False, True):
                r = copy.deepcopy(original)
                c = r["cases"][name]
                field = "OA" if name == "table" else "GH"
                offset = c["addresses"][field] - c["here_before"]
                data = bytearray.fromhex(
                    c["dictionary_before_hex"]
                    if initial
                    else c["program_identity"]["after_hex"]
                )
                data[offset] ^= 1
                if initial:
                    c["dictionary_before_hex"] = data.hex()
                    c["program_identity"]["before_sha256"] = hashlib.sha256(
                        data
                    ).hexdigest()
                else:
                    c["program_identity"]["after_hex"] = data.hex()
                    c["program_identity"]["after_sha256"] = hashlib.sha256(
                        data
                    ).hexdigest()
                with (
                    self.subTest(name=name, initial=initial),
                    self.assertRaisesRegex(AssertionError, "owned-cell bytes"),
                ):
                    C.check(r)


if __name__ == "__main__":
    unittest.main()
