"""Reject plausible but false BASIC deadline evidence."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-basic-deadlines.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        for machine in C.SYSTEMS:
            with self.subTest(machine=machine):
                C.check(machine)

    def test_corruption_controls(self) -> None:
        for machine in C.SYSTEMS:
            p = C.folder(machine) / "verification"
            record = json.loads((p / "native.json").read_text())
            boundaries = json.loads((p / "boundaries.json").read_text())
            mutations = [
                lambda r, b: r.update(status="built"),
                lambda r, b: r.update(system="other"),
                lambda r, b: r.update(language="assembly"),
                lambda r, b: r.update(sources={}),
                lambda r, b: r.update(emulator_sha256=""),
                lambda r, b: r.update(firmware_sha256={}),
                lambda r, b: r["variants"].pop("repaired"),
                lambda r, b: r["variants"]["working"].update(source_sha256=""),
                lambda r, b: r["variants"]["working"]["samples"].clear(),
                lambda r, b: r["variants"]["working"]["samples"][0]["raw"].__setitem__(
                    16, 0
                ),
                lambda r, b: r["variants"]["working"]["samples"][0]["raw"].__setitem__(
                    19, 0
                ),
                lambda r, b: r["variants"]["working"]["samples"][0].update(turn=99),
                lambda r, b: r["variants"]["custom"].update(image_sha256=""),
                lambda r, b: next(
                    x
                    for x in r["variants"]["wrong"]["samples"]
                    if x["stage"] == "wrong-never-expires"
                ).update(elapsed=1),
                lambda r, b: r["variants"]["working"]["memory"].update(
                    helper_token_bytes=0
                ),
                lambda r, b: r["variants"]["working"]["memory"][
                    "program_bytes"
                ].__setitem__(0, 0),
                lambda r, b: r["variants"]["working"]["memory"].update(heap_end=0),
                lambda r, b: b.update(system="other"),
                lambda r, b: b.update(modulus=1),
                lambda r, b: b.update(listing_sha256=""),
                lambda r, b: b["cases"].pop(),
                lambda r, b: b["raw"].__setitem__(100, 0),
                lambda r, b: b["cases"][0]["bytes"].__setitem__(1, 1),
                lambda r, b: b.update(emulator_sha256=""),
            ]
            for i, mutate in enumerate(mutations):
                with self.subTest(machine=machine, mutation=i):
                    r, b = copy.deepcopy(record), copy.deepcopy(boundaries)
                    mutate(r, b)
                    with self.assertRaises(ValueError):
                        C.check(machine, r, b)


if __name__ == "__main__":
    unittest.main()
