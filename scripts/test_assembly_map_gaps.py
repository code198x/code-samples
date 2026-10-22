"""Prove that incomplete, stale and falsified native records fail."""

from __future__ import annotations

import copy
import importlib.util
import json
import unittest
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "map_check", Path(__file__).with_name("check-assembly-map-gaps.py")
)
assert SPEC and SPEC.loader
C = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(C)


class MapRecords(unittest.TestCase):
    def test_real_records(self):
        C.main()

    def test_falsifications(self):
        for cfg in json.loads(C.V.CONFIG.read_text()):
            original = json.loads(
                (C.V.folder(cfg) / "verification/results.json").read_text()
            )
            mutations = {
                "language": lambda r: r.update(language="basic"),
                "machine": lambda r: r.update(machine="other"),
                "ram": lambda r: r["configuration"].update(results=0),
                "source": lambda r: r["sources"].update({"missing": "0" * 64}),
                "wrong read": lambda r: r["observations"]["positive"].__setitem__(
                    0, 99
                ),
                "incomplete": lambda r: r["observations"]["positive"].__setitem__(
                    -1, 0
                ),
                "missing control": lambda r: r["observations"].pop("wrong-stride"),
                "control passes": lambda r: r["observations"].update(
                    {"write-without-valid": r["observations"]["positive"]}
                ),
                "same fixture": lambda r: r["fixtures"].update(
                    {"wrong-stride": r["fixtures"]["positive"]}
                ),
                "limits": lambda r: r.update(limits=""),
            }
            for name, mutate in mutations.items():
                with self.subTest(system=cfg["system"], fault=name):
                    altered = copy.deepcopy(original)
                    mutate(altered)
                    with self.assertRaises(
                        (RuntimeError, ValueError, AssertionError, KeyError)
                    ):
                        C.validate(cfg, altered)


if __name__ == "__main__":
    unittest.main()
