"""Falsification controls for native AMOS deadline records."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-amos-deadline.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        C.check()

    def test_corruption_controls(self) -> None:
        original = json.loads((C.FOLDER / "verification/results.json").read_text())
        mutations = [
            lambda r: r.update(status="compiled"),
            lambda r: r.update(machine="other"),
            lambda r: r.update(language="blitz"),
            lambda r: r.update(configuration="different"),
            lambda r: r.update(emulator_sha256=""),
            lambda r: r.update(firmware_sha256=""),
            lambda r: r.update(runtime_media_sha256=""),
            lambda r: r["cases"].pop("repaired"),
            lambda r: r["cases"]["working"].update(program_sha256=""),
            lambda r: r["cases"]["working"].update(bank_address=0),
            lambda r: r["cases"]["working"]["samples"].clear(),
            lambda r: r["cases"]["working"]["samples"][0]["bank"].__setitem__(28, 0),
            lambda r: r["cases"]["working"]["samples"][0]["bank"].__setitem__(31, 0),
            lambda r: r["cases"]["working"]["samples"][0].update(turn=9),
            lambda r: r["cases"]["custom"]["samples"][0].update(duration=200),
            lambda r: r["cases"]["working"]["samples"][0].update(image_sha256=""),
            lambda r: r["cases"]["wrong"]["samples"][-3].update(remaining=0),
            lambda r: r["cases"]["boundaries"]["cases"].pop(),
            lambda r: r["cases"]["boundaries"]["raw"].__setitem__(159, 0),
            lambda r: r["cases"]["boundaries"]["cases"][0].update(actual=[1, 1, 1, 1]),
            lambda r: r["cases"]["boundaries"]["cases"][0].update(
                expected=[1, 1, 1, 1]
            ),
            lambda r: r["cases"]["wrong-boundary"]["cases"][3].update(
                oracle_matches=True
            ),
            lambda r: r["cases"].pop("wrong-boundary"),
        ]
        for index, mutate in enumerate(mutations):
            with self.subTest(index=index):
                record = copy.deepcopy(original)
                mutate(record)
                with self.assertRaises(ValueError):
                    C.check(record)


if __name__ == "__main__":
    unittest.main()
