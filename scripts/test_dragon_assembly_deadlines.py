"""Exercise positive native evidence and ten independent corruptions per route."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "check", Path(__file__).with_name("check-dragon-assembly-deadlines.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def exercise(test, system):
    V = C.load(system)
    original = json.loads((V.F / "verification/results.json").read_text())
    C.check(system)
    for fault in range(10):
        r = copy.deepcopy(original)
        c = r["cases"]["working"]
        if fault == 0:
            # A consistent claim of other bytes is caught only by the rebuild.
            forged = r["cases"]["custom"]
            forged["loaded_bytes"][0] ^= 1
            forged["loaded_sha256"] = hashlib.sha256(
                bytes(forged["loaded_bytes"])
            ).hexdigest()
        elif fault == 1:
            r["cases"].pop("repaired")
        elif fault == 2:
            c["samples"][0]["turn"] ^= 1
        elif fault == 3:
            c["samples"][4]["remaining"] ^= 1
        elif fault == 4:
            c["loaded_bytes"][0] ^= 1
        elif fault == 5:
            c["samples"][-1]["active"] ^= 1
        elif fault == 6:
            r["cases"]["boundaries"]["bytes"][2] ^= 1
        elif fault == 7:
            r["cases"]["wrong-boundary"]["oracle_matches"] = True
        elif fault == 8:
            c["image_sha256"] = "0" * 64
        else:
            r["firmware_sha256"] = {}
        with (
            test.subTest(system=system, fault=fault),
            test.assertRaisesRegex(
                AssertionError, "^Program bytes differ" if fault == 0 else ""
            ),
        ):
            C.check(system, r)


def provenance(test, system):
    """Changed, added or removed source text alone does not make a record stale."""
    V = C.load(system)
    r = json.loads((V.F / "verification/results.json").read_text())
    r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)
    with test.subTest(system=system):
        C.check(system, r)


class Evidence(unittest.TestCase):
    def test_dragon(self):
        exercise(self, "dragon-32")

    def test_source_digests_are_provenance(self):
        for system in ("dragon-32", "msx", "jupiter-ace", "sinclair-zx-spectrum"):
            provenance(self, system)


if __name__ == "__main__":
    unittest.main()
