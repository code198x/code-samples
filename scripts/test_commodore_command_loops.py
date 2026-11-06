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
                for mutation in ["screen", "count", "stage", "image"]:
                    bad = copy.deepcopy(r)
                    if mutation == "screen":
                        bad["cases"]["working"]["observations"][-1]["screen_bytes"] = [
                            32
                        ] * r["screen_length"]
                    elif mutation == "count":
                        bad["cases"]["working"]["observations"][-1]["count"] = 1
                    elif mutation == "stage":
                        bad["cases"]["working"]["observations"].pop()
                    else:
                        bad["cases"]["working"]["observations"][-1]["image_sha256"] = (
                            "0" * 64
                        )
                    with self.assertRaises(ValueError, msg=mutation):
                        C.check(system, track, record=bad)

    def test_forged_program_is_rebuilt(self):
        """A record claiming another program is caught by regenerating it."""
        for system, track in C.V.ROUTES:
            folder = (
                C.ROOT
                / system
                / f"patterns/{track}/framework/command-loop/verification/reusable"
            )
            r = json.loads((folder / "results.json").read_text())
            key = "entered_sha256" if track == "basic" else "prg_sha256"
            r["cases"]["nonzero"][key] = "0" * 64
            message = (
                "^Typed program differs"
                if track == "basic"
                else "^Program bytes differ"
            )
            with (
                self.subTest(system=system, track=track),
                self.assertRaisesRegex(AssertionError, message),
            ):
                C.check(system, track, record=r)

    def test_source_digests_are_provenance(self):
        """Changed source or observer digests alone do not make a record stale."""
        for system, track in C.V.ROUTES:
            folder = (
                C.ROOT
                / system
                / f"patterns/{track}/framework/command-loop/verification/reusable"
            )
            r = json.loads((folder / "results.json").read_text())
            r["sources"] = dict.fromkeys(r["sources"], "0" * 64)
            r["observer_sources"] = {}
            with self.subTest(system=system, track=track):
                C.check(system, track, record=r)


if __name__ == "__main__":
    unittest.main()
