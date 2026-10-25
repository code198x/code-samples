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
TOPIC = "rectangle-clipping"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        rects = [
            r
            for r in itertools.product(range(4), repeat=4)
            if r[0] <= r[2] and r[1] <= r[3]
        ]
        for a in rects:
            for b in rects:
                before = [99] * 6 + list(a) + list(b)
                out = m.clip(before)
                reverse = m.clip([99] * 6 + list(b) + list(a))
                self.assertEqual(out[:6], reverse[:6])
                self.assertEqual(out[1], 1)
                self.assertEqual(out[6:], before[6:])
                points = {
                    (x, y)
                    for x in range(4)
                    for y in range(4)
                    if a[0] <= x < a[2]
                    and a[1] <= y < a[3]
                    and b[0] <= x < b[2]
                    and b[1] <= y < b[3]
                }
                self.assertEqual(out[0], bool(points))
                c = out[2:6]
                if points:
                    self.assertEqual((c[2] - c[0]) * (c[3] - c[1]), len(points))
                    self.assertEqual(
                        points,
                        {(x, y) for x in range(c[0], c[2]) for y in range(c[1], c[3])},
                    )
                else:
                    self.assertEqual(c, [0] * 4)
        for index, value in [(6, -1), (6, 256), (6, 1.5), (8, 0), (10, -1), (12, 0)]:
            d = [99] * 6 + [10, 10, 30, 30] + [10, 10, 20, 20]
            d[index] = value
            out = m.clip(d)
            self.assertEqual(out[:6], [0] * 6)
            self.assertEqual(out[6:], d[6:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][4], 40)
            self.assertGreater(bad[0][4], 40)
            self.assertEqual(good[1][:6], [0, 1, 0, 0, 0, 0])


if __name__ == "__main__":
    unittest.main()
