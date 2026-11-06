"""Set invariants, capacity guards and complete retained native qualification."""

from __future__ import annotations

import importlib.util
import json
import unittest
from pathlib import Path

S = importlib.util.spec_from_file_location(
    "pool_gate", Path(__file__).with_name("check-additional-object-pools.py")
)
C = importlib.util.module_from_spec(S)
S.loader.exec_module(C)


class Contract(unittest.TestCase):
    def test_independent_sets_and_guard(self) -> None:
        for cap in range(1, 256):
            self.assertEqual(C.V.B.capacity(f"POOL_CAPACITY={cap}\n"), cap)
            self.assertEqual(C.V.B.capacity(f"POOL_CAPACITY equ {cap}\n"), cap)
        for source in [
            "",
            "POOL_CAPACITY=0\n",
            "POOL_CAPACITY=256\n",
            "POOL_CAPACITY=-1\n",
            "POOL_CAPACITY=1.5\n",
            "POOL_CAPACITY equ unknown\n",
        ]:
            with self.assertRaises(ValueError):
                C.V.B.capacity(source)
        for cap in [4, 8]:
            p = C.V.O.M.packet(cap)
            self.assertEqual(len(p), 1286 + cap)
            for mask in range(256):
                occupied = {i for i in range(cap) if mask & (1 << i)}
                chosen = next((i for i in range(cap) if i not in occupied), cap)
                row = p[2 + 5 * mask : 7 + 5 * mask]
                self.assertEqual(row[0], chosen)
                self.assertEqual(row[2], mask & ((1 << cap) - 1))
                self.assertEqual(
                    row[1],
                    (mask | 1 << chosen) & ((1 << cap) - 1)
                    if chosen < cap
                    else mask & ((1 << cap) - 1),
                )
                self.assertEqual(row[3], 10 if chosen < cap else 3)
                self.assertEqual(row[4], 147)
        self.assertEqual(C.V.O.packet("demo"), C.V.O.packet("repaired"))
        for variant in C.V.B.VARIANTS:
            p = C.V.O.packet(variant)
            self.assertEqual(p[0], 165)
            self.assertEqual(p[-1], 239)
            self.assertTrue(all(0 <= v <= 255 for v in p))
            self.assertLess(len(p), 4096)
            self.assertEqual(p[-3:-1], C.V.O.checks(variant))
        self.assertEqual(C.V.O.packet("boundary-one")[1:4], [1, 147, 0])
        self.assertEqual(C.V.O.packet("boundary-max")[1], 255)

    def test_native_observations_and_rejections(self) -> None:
        for system in C.V.CONFIG:
            C.qualify(system)

    def test_source_digests_are_provenance(self) -> None:
        """Changed source or script text alone does not make a record stale."""
        for system in C.V.CONFIG:
            f = C.V.folder(system) / "verification"
            cfg = json.loads((f / "configuration.json").read_text())
            for variant in C.V.B.VARIANTS:
                r = json.loads((f / (variant + ".json")).read_text())
                r["sources"] = {path: "0" * 64 for path in r["sources"]}
                with self.subTest(system=system, variant=variant):
                    C.check(system, r, cfg)


if __name__ == "__main__":
    unittest.main()
