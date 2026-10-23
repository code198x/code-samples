"""Falsify map evidence so a pass cannot mean zero/stale work."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "zx_check", Path(__file__).with_name("check-zx-basic-map.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class ZxBasicMaps(unittest.TestCase):
    def records(self) -> list:
        return [
            json.loads((C.V.folder(s) / "verification/results.json").read_text())
            for s in C.V.SYSTEMS
        ]

    def test_real(self) -> None:
        for record in self.records():
            C.validate(record)

    def test_capture_bindings(self) -> None:
        for system in C.V.SYSTEMS:
            C.validate_captures(system)
            manifest = json.loads(
                (C.V.folder(system) / "verification/captures.json").read_text()
            )
            for key in (
                "demo.png",
                "wrong-stride-read-0-1.png",
                "write-without-valid-reject-write-7-0-1.png",
            ):
                changed = manifest.copy()
                changed[key] = "0" * 64
                with self.assertRaises(AssertionError):
                    C.validate_captures(system, changed)
            with self.assertRaises(AssertionError):
                C.validate_captures(system, {})

    def test_falsifications(self) -> None:
        mutations = {
            "wrong language": lambda r: r.update(language="assembly"),
            "wrong machine": lambda r: r.update(machine="other"),
            "wrong RAM": lambda r: r.update(ram_bytes=1024),
            "missing startup": lambda r: r.update(configuration=""),
            "source": lambda r: r.update(sources={}),
            "emulator": lambda r: r.update(emulator_sha256="0" * 64),
            "ROM": lambda r: r.update(firmware_sha256="0" * 64),
            "limits": lambda r: r.update(limits=""),
            "no variants": lambda r: r.update(variants={}),
            "missing fault": lambda r: r["variants"].pop("wrong-stride"),
            "zero calls": lambda r: r["variants"]["positive"].update(cases=[]),
            "wrong program": lambda r: r["variants"]["positive"].update(
                program_sha256="0" * 64
            ),
            "missing display": lambda r: r["variants"]["positive"]["cases"][0].update(
                display_hex=""
            ),
            "display outside RAM": lambda r: r["variants"]["positive"]["cases"][
                0
            ].update(display_address=0),
            "claim": lambda r: r["variants"]["positive"]["cases"][0].update(
                actual=[9] * 5
            ),
            "stale": lambda r: r["variants"]["positive"]["cases"][1].update(
                display_hex=r["variants"]["positive"]["cases"][0]["display_hex"]
            ),
            "map corruption": lambda r: r["variants"]["positive"]["cases"][0][
                "map"
            ].__setitem__(1, 3),
            "guard corruption": lambda r: r["variants"]["positive"]["cases"][0][
                "map"
            ].__setitem__(35, 0),
            "wrong case": lambda r: r["variants"]["positive"]["cases"][0].update(
                label="other"
            ),
            "unchanged custom": lambda r: r["variants"].__setitem__(
                "closed-exit", copy.deepcopy(r["variants"]["positive"])
            ),
            "stride wrongly passes": lambda r: r["variants"].__setitem__(
                "wrong-stride", copy.deepcopy(r["variants"]["positive"])
            ),
            "write wrongly passes": lambda r: r["variants"].__setitem__(
                "write-without-valid", copy.deepcopy(r["variants"]["positive"])
            ),
            "missing demo": lambda r: r["demo"].update(display_hex=""),
        }
        for record in self.records():
            for name, mutate in mutations.items():
                with self.subTest(machine=record["machine"], fault=name):
                    changed = copy.deepcopy(record)
                    mutate(changed)
                    with self.assertRaises((AssertionError, KeyError, ValueError)):
                        C.validate(changed)


if __name__ == "__main__":
    unittest.main()
