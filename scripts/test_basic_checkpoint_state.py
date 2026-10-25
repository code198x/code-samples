"""Native records, altered evidence and independent snapshot/timing invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-timelines.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "checkpoint-state"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for x in range(256):
            for y in range(256):
                for resource in [0, 255]:
                    before = [x, y, resource, 9, 9, 9, 9, 0, 0, 9, 9]
                    d = m.snapshot(before)
                    self.assertEqual(d[3:8], [x, y, resource, x ^ y ^ resource, 1])
                    self.assertEqual(d[9:], [1, 0])
                    d[:3] = [200, 201, 1]
                    d[8] = 1
                    self.assertEqual(m.snapshot(d)[:3], [x, y, resource])
        for bit in range(8):
            d = [99, 98, 97, 10, 20, 3, 29 ^ (1 << bit), 1, 1, 9, 9]
            out = m.snapshot(d)
            self.assertEqual(out[:3], d[:3])
            self.assertEqual(out[9:], [0, 3])
        collision = m.snapshot([99, 98, 97, 20, 10, 3, 29, 1, 1, 9, 9])
        self.assertEqual(collision[:3], [20, 10, 3])
        self.assertEqual(collision[9:], [1, 0])
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[1][:3], [40, 60, 5] if custom else [10, 20, 3])
            self.assertEqual(bad[1][:3], [200, 201, 1])
            self.assertEqual(good[2][9:], [0, 3])
            self.assertEqual(good[3][9:], [0, 0])
            self.assertEqual(good[0][3], 40 if custom else 10)


if __name__ == "__main__":
    unittest.main()
