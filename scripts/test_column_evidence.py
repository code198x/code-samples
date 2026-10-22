"""Falsify retained claims using the same validators as the real inventory."""

from __future__ import annotations

import copy
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "columns", ROOT / "scripts/check-column-evidence.py"
)
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)
DATA = json.loads((ROOT / "docs/column-expansion.json").read_text())


def route(system: str) -> dict:
    return next(r for r in DATA["routes"] if r["system"] == system)


def record(system: str) -> dict:
    return json.loads(
        (ROOT / route(system)["folder"] / "verification/results.json").read_text()
    )


class EvidenceControls(unittest.TestCase):
    def test_real_inventory_and_files(self) -> None:
        self.assertEqual(C.validate(ROOT, DATA)["machine_language_routes"], 26)

    def test_empty_inventory(self) -> None:
        with self.assertRaisesRegex(ValueError, "Missing/duplicate"):
            C.inventory([])

    def test_missing_machine(self) -> None:
        with self.assertRaises(ValueError):
            C.inventory(DATA["routes"][:-1])

    def test_wrong_language(self) -> None:
        rows = copy.deepcopy(DATA["routes"])
        rows[0]["track"] = "assembly"
        with self.assertRaisesRegex(ValueError, "Wrong machine/language"):
            C.inventory(rows)

    def test_invented_zx_sound(self) -> None:
        rows = copy.deepcopy(DATA["routes"])
        next(r for r in rows if r["system"] == "sinclair-zx80")["sound_absent"] = False
        with self.assertRaisesRegex(ValueError, "stock sound"):
            C.inventory(rows)

    def test_aquarius_line_collision_is_rejected(self) -> None:
        p = ROOT / route("mattel-aquarius")["folder"]
        C.basic_lines((p / "demo.bas").read_text())
        with self.assertRaisesRegex(ValueError, "overlapping"):
            C.basic_lines((p / "mistakes/overlapping-lines.bas").read_text())

    def test_empty_listing(self) -> None:
        with self.assertRaises(ValueError):
            C.basic_lines("")

    def test_missing_observations(self) -> None:
        r = record("msx")
        r["observations"] = []
        with self.assertRaisesRegex(ValueError, "sequence"):
            C.check_native(route("msx"), r)

    def test_counter_cannot_disagree_with_actual_memory(self) -> None:
        r = record("msx")
        r["observations"][2]["count"] += 1
        with self.assertRaisesRegex(ValueError, "differs from memory"):
            C.check_native(route("msx"), r)

    def test_held_input_cannot_be_presented_as_one_press(self) -> None:
        r = record("coleco-colecovision")
        r["observations"][3]["bytes"] = [2]
        r["observations"][3]["count"] = 2
        with self.assertRaisesRegex(ValueError, "hold"):
            C.check_native(route("coleco-colecovision"), r)

    def test_zx_count_must_be_in_display_line(self) -> None:
        r = record("sinclair-zx81")
        r["observations"][0]["bytes"][1] = 0
        with self.assertRaisesRegex(ValueError, "display digits"):
            C.check_native(route("sinclair-zx81"), r)

    def test_missing_sound_negative(self) -> None:
        r = record("msx")
        r["sound_negative_rejected"] = False
        with self.assertRaisesRegex(ValueError, "sound control"):
            C.check_native(route("msx"), r)

    def test_muted_wave_cannot_satisfy_working_audio(self) -> None:
        p = ROOT / route("msx")["folder"] / "verification"
        working = C.pcm(p / "sound.wav")
        negative = C.pcm(p / "sound-negative.wav")
        baseline = C.pcm(p / "keyboard-baseline.wav")
        C.sound_guard(working, negative, baseline)
        with self.assertRaisesRegex(ValueError, "No program audio"):
            C.sound_guard(negative, negative, baseline)

    def test_live_wave_cannot_be_passed_off_as_muted(self) -> None:
        p = ROOT / route("coleco-colecovision")["folder"] / "verification"
        working = C.pcm(p / "sound.wav")
        with self.assertRaisesRegex(ValueError, "Muted control"):
            C.sound_guard(working, working)

    def test_fault_must_fail_held_guard(self) -> None:
        r = {"status": "passed", "held_guard_rejected": True, "first": 1, "held": 1}
        with self.assertRaisesRegex(ValueError, "Missing edge"):
            C.check_fault(route("sord-m5"), r)

    def test_changed_and_missing_sources_are_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as name:
            root = Path(name)
            p = root / "routine.inc"
            p.write_text("correct")
            expected = C.sha(p)
            C.bound(root, p.name, expected)
            p.write_text("wrong")
            with self.assertRaisesRegex(ValueError, "Changed file"):
                C.bound(root, p.name, expected)
            p.unlink()
            with self.assertRaisesRegex(ValueError, "Missing/outside"):
                C.bound(root, p.name, expected)

    def test_outside_path(self) -> None:
        with (
            tempfile.TemporaryDirectory() as name,
            self.assertRaisesRegex(ValueError, "Missing/outside"),
        ):
            C.bound(Path(name), "../escape", "0" * 64)

    def test_empty_audio_rejected(self) -> None:
        import wave

        with tempfile.TemporaryDirectory() as name:
            p = Path(name) / "empty.wav"
            with wave.open(str(p), "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(48000)
            with self.assertRaisesRegex(ValueError, "Empty/unsupported"):
                C.pcm(p)


if __name__ == "__main__":
    unittest.main()
