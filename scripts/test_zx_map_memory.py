"""Retained evidence must reject wrong capacity, stale output and hidden writes."""

from __future__ import annotations

import copy
import importlib.util
import json
import shutil
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "memory_check", ROOT / "scripts/check-zx-map-memory.py"
)
assert SPEC and SPEC.loader
K = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(K)


class MemoryRecords(unittest.TestCase):
    def setUp(self) -> None:
        self.system = "sinclair-zx81"
        K.CURRENT_SYSTEM = self.system
        folder = K.C.V.folder(self.system) / "verification/memory"
        self.good = json.loads((folder / "compact.json").read_text())
        self.readable = json.loads((folder / "readable-4096.json").read_text())
        self.rejection = json.loads((folder / "readable-2048.json").read_text())

    def rejected(self, mutate) -> None:
        data = copy.deepcopy(self.good)
        mutate(data)
        with self.assertRaises((AssertionError, ValueError, KeyError, IndexError)):
            K.compact(data, self.system)

    def test_qualified_records(self) -> None:
        K.check()

    def test_changed_native_capture(self) -> None:
        folder = K.C.V.folder(self.system) / "verification/memory"
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / "records"
            shutil.copytree(folder, destination)
            capture = destination / "compact-caller.png"
            capture.write_bytes(capture.read_bytes() + b"altered")
            with self.assertRaises(AssertionError):
                K.manifest(destination, self.system, 4096)

    def test_missing_capture(self) -> None:
        folder = K.C.V.folder(self.system) / "verification/memory"
        with tempfile.TemporaryDirectory() as temporary:
            destination = Path(temporary) / "records"
            shutil.copytree(folder, destination)
            (destination / "compact-bad-write.png").unlink()
            with self.assertRaises(FileNotFoundError):
                K.manifest(destination, self.system, 4096)

    def test_failed_qualification_cannot_refresh_bindings(self) -> None:
        folder = K.C.V.folder(self.system) / "verification/memory"
        before = (folder / "manifest.json").read_bytes()
        with (
            patch.object(
                K,
                "compact",
                side_effect=AssertionError("incomplete native qualification"),
            ),
            self.assertRaises(AssertionError),
        ):
            K.check(refresh_manifests=True)
        self.assertEqual((folder / "manifest.json").read_bytes(), before)

    def test_no_cases(self) -> None:
        self.rejected(lambda d: d.update(cases=[]))

    def test_extra_ram(self) -> None:
        self.rejected(lambda d: d.update(ram_bytes=16384))

    def test_wrong_source(self) -> None:
        self.rejected(lambda d: d.update(sources={}))

    def test_empty_program(self) -> None:
        self.rejected(lambda d: d.update(program_hex=""))

    def test_stale_heap(self) -> None:
        self.rejected(lambda d: d["cases"][1].update(heap=d["cases"][0]["heap"]))

    def test_claim_without_native_storage(self) -> None:
        self.rejected(lambda d: d["cases"][0]["heap"]["values"].update(T=999))

    def test_missing_display(self) -> None:
        self.rejected(lambda d: d["cases"][0]["screen"].update(hex="", text=""))

    def test_stale_call_with_identical_result(self) -> None:
        def mutate(d):
            previous = next(c for c in d["cases"] if c["label"] == "world-0-0")
            current = next(c for c in d["cases"] if c["label"] == "world-7-7")
            # Both legitimately return tile zero. Check actual received X/Y too.
            for field in ("heap", "screen", "snapshot"):
                current[field] = copy.deepcopy(previous[field])

        self.rejected(mutate)

    def test_stale_screen(self) -> None:
        self.rejected(lambda d: d["cases"][1].update(screen=d["cases"][0]["screen"]))

    def test_bad_stack_accounting(self) -> None:
        self.rejected(lambda d: d["caller_snapshot"].update(observed_gap=999))

    def test_stack_outside_stock_ram(self) -> None:
        def mutate(d):
            s = d["caller_snapshot"]
            s["cpu"]["sp"] = "$4FF4"
            s["sp"] = 0x4FF4
            s["observed_gap"] = s["sp"] - s["frontier"]

        self.rejected(mutate)

    def test_heap_not_at_recorded_variables(self) -> None:
        self.rejected(
            lambda d: d["caller_heap"].update(address=d["caller_heap"]["address"] + 1)
        )

    def test_false_customisation(self) -> None:
        self.rejected(lambda d: d["customisation"]["heap"]["values"].update(F=4))

    def test_false_stride_repair(self) -> None:
        self.rejected(lambda d: d.update(stride_repair=d["wrong_stride"]))

    def test_false_write_repair(self) -> None:
        self.rejected(lambda d: d.update(write_repair=d["bad_write"]))

    def test_rejected_write_corrupts_storage(self) -> None:
        def mutate(d):
            case = next(c for c in d["cases"] if c["label"] == "reject-write-7-0-1")
            h = case["heap"]
            raw = bytearray.fromhex(h["hex"])
            index = raw.find(bytes(h["values"]["M$"]))
            self.assertGreaterEqual(index, 0)
            raw[index] = 29
            h["hex"] = raw.hex()
            h["values"]["M$"][0] = 29

        self.rejected(mutate)

    def test_wrong_initial_room(self) -> None:
        def mutate(d):
            h = d["dispatcher_start"]
            raw = bytearray.fromhex(h["hex"])
            index = raw.find(bytes(h["values"]["M$"]))
            self.assertGreaterEqual(index, 0)
            raw[index] = 29
            h["hex"] = raw.hex()
            h["values"]["M$"][0] = 29

        self.rejected(mutate)

    def test_false_readable_cost(self) -> None:
        self.readable["component_bytes"]["caller"] = 1
        with self.assertRaises(AssertionError):
            K.readable(self.readable, self.system, 4096, True)

    def test_wrong_sampled_gap(self) -> None:
        self.readable["sampled_min_gap"] += 1
        with self.assertRaises(AssertionError):
            K.readable(self.readable, self.system, 4096, True)

    def test_missing_memory_error(self) -> None:
        self.rejection["status"] = "passed"
        with self.assertRaises(AssertionError):
            K.readable(self.rejection, self.system, 2048, False)

    def test_unqualified_rom(self) -> None:
        self.readable["identity"]["firmware_sha256"] = "0" * 64
        with self.assertRaises(AssertionError):
            K.readable(self.readable, self.system, 4096, True)


if __name__ == "__main__":
    unittest.main()
