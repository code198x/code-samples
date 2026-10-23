"""Falsify native Blitz deadline records without booting licensed media."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-blitz-deadline.py")
)
assert s and s.loader
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_record(self) -> None:
        C.check()

    def test_corruptions(self) -> None:
        original = json.loads((C.FOLDER / "verification/results.json").read_text())

        def false_initial(r):
            stage = next(
                s for s in r["cases"]["working"]["samples"] if s["stage"] == "expiry"
            )
            r["cases"]["working"].update(
                initial_image=stage["image"], initial_sha256=stage["image_sha256"]
            )

        mutations = [
            lambda r: r.update(status="compiled"),
            lambda r: r.update(machine="other"),
            lambda r: r.update(language="amos"),
            lambda r: r.update(configuration="other"),
            lambda r: r["toolchain"].update(emulator_sha256=""),
            lambda r: r["fixture"].update(builder_sha256=""),
            lambda r: r["fixture"].update(disk_sha256=""),
            lambda r: r["cases"].pop("repaired"),
            lambda r: r["cases"]["working"].update(program_sha256=""),
            lambda r: r["cases"]["working"].update(bank_address=0),
            lambda r: r["cases"]["working"].update(bank_length=1),
            lambda r: r["cases"]["working"].update(initial_sha256=""),
            lambda r: r["cases"]["working"]["samples"].clear(),
            lambda r: r["cases"]["working"]["samples"].pop(),
            lambda r: r["cases"]["working"]["samples"][0]["bank"].__setitem__(32, 0),
            lambda r: r["cases"]["working"]["samples"][0]["bank"].__setitem__(39, 0),
            lambda r: r["cases"]["working"]["samples"][0].update(turn=9),
            lambda r: r["cases"]["working"]["samples"][0].update(image_sha256=""),
            lambda r: r["cases"]["working"]["samples"][1].update(frames=0),
            lambda r: r["cases"]["custom"]["samples"][0].update(duration=200),
            lambda r: r["cases"]["wrong"]["samples"][-3].update(remaining=0),
            lambda r: r["cases"]["boundaries"]["raw"].__setitem__(271, 0),
            lambda r: r["cases"]["boundaries"]["raw"].__setitem__(0, 1),
            lambda r: r["cases"]["wrong-boundary"]["raw"].__setitem__(0, 1),
            lambda r: r["cases"].pop("wrong-boundary"),
            false_initial,
        ]
        for i, mutate in enumerate(mutations):
            with self.subTest(control=i):
                record = copy.deepcopy(original)
                mutate(record)
                with self.assertRaises(ValueError):
                    C.check(record)


if __name__ == "__main__":
    unittest.main()
