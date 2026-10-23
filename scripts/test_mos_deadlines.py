"""Make retained-evidence acceptance reject plausible but false outcomes."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "checker", ROOT / "scripts/check-mos-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        for system in C.V.SYSTEMS:
            C.check(system)

    def test_corruption_controls(self) -> None:
        controls = 0
        for system in C.V.SYSTEMS:
            original = json.loads(
                (
                    ROOT
                    / system
                    / "patterns/assembly/framework/turn-deadline/verification/results.json"
                ).read_text()
            )
            for kind in [
                "language",
                "machine",
                "sources",
                "missing",
                "guard",
                "clock",
                "countdown",
                "untimed",
                "expiry",
                "wrong",
                "repeat",
                "disabled",
                "boundary",
                "fault",
                "image",
                "firmware",
            ]:
                r = copy.deepcopy(original)
                normal = r["cases"]["working"]["samples"]

                def state(stage: str, samples: list = normal) -> dict:
                    return next(s for s in samples if s["stage"] == stage)

                if kind == "language":
                    r["language"] = "basic"
                elif kind == "machine":
                    r["machine"] = "other"
                elif kind == "sources":
                    r["sources"].pop(next(iter(r["sources"])))
                elif kind == "missing":
                    r["cases"].pop("repaired")
                elif kind == "guard":
                    state("progress")["guards"][0] = 0
                elif kind == "clock":
                    state("idle-after")["clock"] = state("idle")["clock"]
                elif kind == "countdown":
                    state("progress")["remaining"] += 1
                elif kind == "untimed":
                    state("untimed-action")["active"] = 1
                elif kind == "expiry":
                    state("expiry")["turns"] = 1
                elif kind == "wrong":
                    r["cases"]["wrong-input-gate"]["samples"][-1]["expiries"] = 1
                elif kind == "repeat":
                    state("held-after")["turns"] += 1
                elif kind == "disabled":
                    state("disabled-after")["turns"] += 1
                elif kind == "boundary":
                    r["cases"]["boundaries"]["bytes"][0] ^= 1
                elif kind == "fault":
                    r["cases"]["wrong-boundary"]["bytes"] = copy.deepcopy(
                        r["cases"]["boundaries"]["bytes"]
                    )
                elif kind == "image":
                    state("expiry")["image_sha256"] = "0" * 64
                elif kind == "firmware":
                    r["cases"]["working"]["firmware_sha256"]["os.rom"] = "0" * 64
                with (
                    self.subTest(system=system, control=kind),
                    self.assertRaises((AssertionError, ValueError, KeyError)),
                ):
                    C.check(system, r)
                controls += 1
        self.assertEqual(controls, 32)


if __name__ == "__main__":
    unittest.main()
