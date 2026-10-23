"""Ensure the retained-evidence gate rejects plausible false BASIC outcomes."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "check_native", ROOT / "scripts/check-electron-cpc-basic-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing checker")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_real_records(self) -> None:
        for system in C.V.SYSTEMS:
            C.check(system)

    def test_false_outcomes_are_rejected(self) -> None:
        controls = 0
        for system in C.V.SYSTEMS:
            original = json.loads(
                (C.V.folder(system) / "verification/results.json").read_text()
            )
            for kind in [
                "language",
                "machine",
                "source",
                "variant",
                "guard",
                "decode",
                "clock",
                "untimed",
                "restart",
                "expiry",
                "wrong",
                "disable",
                "line",
                "memory",
                "arithmetic",
                "control",
                "capture",
                "firmware",
            ]:
                r = copy.deepcopy(original)
                states = {s["stage"]: s for s in r["cases"]["working"]["samples"]}
                if kind == "language":
                    r["language"] = "assembly"
                elif kind == "machine":
                    r["system"] = "other"
                elif kind == "source":
                    r["sources"].pop(next(iter(r["sources"])))
                elif kind == "variant":
                    r["cases"].pop("repaired")
                elif kind == "guard":
                    states["idle-progress"]["raw"][16] = 0
                elif kind == "decode":
                    states["idle-progress"]["remaining"] += 1
                elif kind == "clock":
                    states["untimed-idle"]["clock"] = states["initial"]["clock"]
                elif kind == "untimed":
                    states["untimed-action"]["raw"][2] = 1
                    states["untimed-action"]["active"] = 1
                elif kind == "restart":
                    states["action-restarts"]["turn"] = 1
                    states["action-restarts"]["raw"][0] = 1
                elif kind == "expiry":
                    states["await-expiry"]["turn"] = 2
                    states["await-expiry"]["raw"][0] = 2
                elif kind == "wrong":
                    r["cases"]["wrong"]["samples"][-3]["elapsed"] = 1
                elif kind == "disable":
                    states["disabled-idle"]["turn"] += 1
                    states["disabled-idle"]["raw"][0] += 1
                elif kind == "line":
                    r["cases"]["working"]["memory"]["program_bytes"][3] ^= 1
                elif kind == "memory":
                    r["cases"]["working"]["memory"]["helper_token_bytes"] = 0
                elif kind == "arithmetic":
                    r["cases"]["boundaries"]["raw"][3] ^= 1
                elif kind == "control":
                    r["cases"]["wrong-boundary"]["raw"] = copy.deepcopy(
                        r["cases"]["boundaries"]["raw"]
                    )
                elif kind == "capture":
                    r["cases"]["working"]["images"][
                        next(iter(r["cases"]["working"]["images"]))
                    ] = "0" * 64
                elif kind == "firmware":
                    r["cases"]["working"]["firmware_sha256"][
                        next(iter(r["cases"]["working"]["firmware_sha256"]))
                    ] = "0" * 64
                with (
                    self.subTest(system=system, control=kind),
                    self.assertRaises((AssertionError, ValueError, KeyError)),
                ):
                    C.check(system, r)
                controls += 1
        self.assertEqual(controls, 36)


if __name__ == "__main__":
    unittest.main()
