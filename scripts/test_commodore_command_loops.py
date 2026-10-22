"""Controls must reject plausible falsified progression and missing evidence."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-commodore-command-loops.py")
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class NativeRecords(unittest.TestCase):
    def test_records_and_controls(self):
        for system, track in C.V.ROUTES:
            with self.subTest(system=system, track=track):
                folder = (
                    C.ROOT
                    / system
                    / f"patterns/{track}/framework/command-loop/verification/reusable"
                )
                r = json.loads((folder / "results.json").read_text())
                C.check(system, track, record=r)
                for mutation in ["screen", "count", "binding", "stage", "image"]:
                    bad = copy.deepcopy(r)
                    if mutation == "screen":
                        bad["cases"]["working"]["observations"][-1]["screen_bytes"] = [
                            32
                        ] * r["screen_length"]
                    elif mutation == "count":
                        bad["cases"]["working"]["observations"][-1]["count"] = 1
                    elif mutation == "binding":
                        bad["sources"].pop(next(iter(bad["sources"])))
                    elif mutation == "stage":
                        bad["cases"]["working"]["observations"].pop()
                    else:
                        bad["cases"]["working"]["observations"][-1]["image_sha256"] = (
                            "0" * 64
                        )
                    with self.assertRaises(ValueError, msg=mutation):
                        C.check(system, track, record=bad)


if __name__ == "__main__":
    unittest.main()
