"""Native observations, rejection controls and independent geometry invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-geometry.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "nearest-target"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        a = [0, 51, 49, 50]
        b = [0, 50, 50, 80]
        for mask in range(256):
            for x, y in itertools.product([0, 50, 255], repeat=2):
                before = [99] * 5 + [mask, x, y] + a + b
                d = m.nearest(before)
                self.assertEqual(d[4], 1)
                self.assertEqual(d[5:], before[5:])
                active = [i for i in range(4) if mask & (1 << i)]
                if not active:
                    self.assertEqual(d[:4], [255, 0, 0, 0])
                    continue
                distances = [abs(x - a[i]) + abs(y - b[i]) for i in active]
                minimum = min(distances)
                self.assertEqual(
                    d[0],
                    next(i for i in active if abs(x - a[i]) + abs(y - b[i]) == minimum),
                )
                self.assertEqual(d[1] + 256 * d[2], minimum)
                self.assertEqual(d[3], 1)
        self.assertEqual(
            m.nearest([0] * 5 + [1, 255, 255] + [0] * 8)[:5], [0, 254, 1, 1, 1]
        )
        for index, value in [
            (5, -1),
            (5, 256),
            (5, 1.5),
            (6, 256),
            (7, 1.5),
            (8, -1),
            (12, 256),
        ]:
            d = [99] * 5 + [15, 50, 50] + a + b
            d[index] = value
            out = m.nearest(d)
            self.assertEqual(out[:5], [255, 0, 0, 0, 0])
            self.assertEqual(out[5:], d[5:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][0], 1)
            self.assertEqual(bad[0][0], 0)
            self.assertEqual(good[1][:5], [255, 0, 0, 0, 1])
            self.assertEqual(good[3][:5], [255, 0, 0, 0, 1])


if __name__ == "__main__":
    unittest.main()
