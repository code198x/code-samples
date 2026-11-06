"""Prove native evidence checks reject plausible corruption."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "checker", Path(__file__).with_name("check-ace-deadline.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        C.check()

    def test_corruption_controls(self) -> None:
        original = json.loads((C.FOLDER / "verification/native.json").read_text())
        boundary = json.loads((C.FOLDER / "verification/boundaries.json").read_text())
        mutations = [
            lambda r, b: r.update(status="built"),
            lambda r, b: r.update(machine="other"),
            lambda r, b: r.update(language="assembly"),
            lambda r, b: r.update(emulator_sha256=""),
            lambda r, b: r.update(firmware_sha256=""),
            lambda r, b: r["cases"].pop("repaired"),
            lambda r, b: r["cases"]["working"].update(sources={}),
            lambda r, b: r["cases"]["working"].update(ram_top=32768),
            lambda r, b: r["cases"]["working"].update(data_top_after_exit=0),
            lambda r, b: r["cases"]["working"]["samples"].clear(),
            lambda r, b: r["cases"]["working"]["samples"][0].update(turn=1),
            lambda r, b: r["cases"]["working"]["samples"][0].update(cpu_sp=0),
            lambda r, b: r["cases"]["custom"]["samples"][0]["state"].update(DU=200),
            lambda r, b: r["cases"]["wrong"]["samples"][-3]["state"].update(DR=0),
            lambda r, b: r["cases"]["working"].update(image_sha256=""),
            lambda r, b: r["cases"]["working"]["capture"].update(pixel_match=False),
            lambda r, b: r["cases"]["working"]["capture"].update(video_hex="00"),
            lambda r, b: r["cases"]["working"].update(
                image=r["cases"]["wrong"]["image"],
                image_sha256=r["cases"]["wrong"]["image_sha256"],
            ),
            lambda r, b: b["cases"].pop("signed-fault"),
            lambda r, b: b["cases"]["working"]["cases"].pop(),
            lambda r, b: b["cases"]["working"]["cases"][0].update(actual=[1, 1, 1]),
            lambda r, b: b["cases"]["working"]["cases"][0].update(expected=[1, 1, 1]),
            lambda r, b: b["cases"]["working"]["cases"][0].update(tag=0),
            lambda r, b: b["cases"]["working"]["cases"][0].update(data_top=0),
            lambda r, b: b["cases"]["signed-fault"]["cases"][7].update(
                oracle_matches=True
            ),
        ]
        for index, mutate in enumerate(mutations):
            with self.subTest(index=index):
                r, b = copy.deepcopy(original), copy.deepcopy(boundary)
                mutate(r, b)
                with self.assertRaises(ValueError):
                    C.check(r, b)

    def test_forged_typed_program_is_rejected(self) -> None:
        """A record claiming other typed FORTH is caught by the typed-text check."""
        r = json.loads((C.FOLDER / "verification/native.json").read_text())
        r["cases"]["custom"]["sources"]["routines.fth"] = "0" * 64
        with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
            C.check(r)
        manifest = json.loads((C.FOLDER / "verification/sources.json").read_text())
        key = next(k for k in manifest if k.endswith("boundaries.fth"))
        manifest[key] = "0" * 64
        with self.assertRaisesRegex(AssertionError, "^Typed program differs"):
            C.check(manifest=manifest)

    def test_script_digests_are_provenance(self) -> None:
        """Changed script or Makefile digests alone do not make a record stale."""
        manifest = json.loads((C.FOLDER / "verification/sources.json").read_text())
        for key in manifest:
            if not key.endswith(".fth"):
                manifest[key] = "0" * 64
        C.check(manifest=manifest)


if __name__ == "__main__":
    unittest.main()
