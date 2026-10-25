"""Native observations, rejection controls and independent geometry invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-geometry.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "point-circle"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for radius in [0, 1, 5, 128, 255]:
            for x in range(256):
                for y in range(256):
                    before = [99] * 3 + [x, y, 0, 0, radius, 99]
                    d = m.circle(before)
                    self.assertEqual(d[0], x * x + y * y <= radius * radius)
                    self.assertEqual(d[1:3], [x, y])
                    self.assertEqual(d[3:8], before[3:8])
                    self.assertEqual(d[8], 1)
        self.assertEqual(
            m.circle([99] * 3 + [103, 104, 100, 100, 5, 99])[:3], [1, 3, 4]
        )
        self.assertEqual(
            m.circle([99] * 3 + [255, 255, 0, 0, 255, 99])[:3], [0, 255, 255]
        )
        self.assertEqual(m.circle([99] * 3 + [0, 0, 255, 0, 255, 99])[:3], [1, 255, 0])
        for index, value in [
            (3, -1),
            (3, 256),
            (3, 1.5),
            (4, 256),
            (5, -1),
            (6, 1.5),
            (7, 256),
        ]:
            d = [99] * 3 + [104, 104, 100, 100, 5, 99]
            d[index] = value
            out = m.circle(d)
            self.assertEqual(out[:3], [0, 0, 0])
            self.assertEqual(out[8], 0)
            self.assertEqual(out[3:8], d[3:8])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][0], 1 if custom else 0)
            self.assertEqual(bad[0][0], 1)
            self.assertEqual(good[0][2], 4)
            self.assertEqual(bad[0][2], 0)
            self.assertEqual(good[1][0], 1)
            self.assertEqual(good[2][0], 0)


if __name__ == "__main__":
    unittest.main()
