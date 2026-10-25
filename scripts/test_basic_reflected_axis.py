"""Native observations, rejection controls and independent mask/motion invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-motion.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "reflected-axis"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for a, b in [(0, 1), (0, 3), (2, 7), (0, 10)]:
            for initial, distance, direction in itertools.product(
                range(a, b + 1), range(256), [0, 1]
            ):
                p = initial
                s = direction
                count = 0
                for _ in range(distance):
                    if (s == 0 and p == a) or (s == 1 and p == b):
                        s = 1 - s
                        count += 1
                    p += 1 if s else -1
                before = [initial, a, b, distance, direction, 99, 99]
                d = m.reflect(before)
                self.assertEqual(d, [p, a, b, distance, s, count, 1])
                self.assertTrue(a <= d[0] <= b)
                self.assertLessEqual(count, distance)
        self.assertEqual(m.reflect([0, 0, 10, 10, 1, 99, 99]), [10, 0, 10, 10, 1, 0, 1])
        self.assertEqual(m.reflect([10, 0, 10, 1, 1, 99, 99]), [9, 0, 10, 1, 0, 1, 1])
        for index, value in [
            (0, -1),
            (0, 256),
            (0, 1.5),
            (1, 11),
            (2, 0),
            (3, -1),
            (3, 256),
            (4, 2),
            (4, 1.5),
        ]:
            d = [5, 0, 10, 7, 1, 99, 99]
            d[index] = value
            self.assertEqual(m.reflect(d), d[:5] + [0, 0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][0], 3 if custom else 5)
            self.assertEqual(good[0][5], 2 if custom else 1)
            self.assertEqual(good[4][0], good[3][0])
            self.assertEqual(good[4][4], good[3][4])
            self.assertEqual(good[4][5:], [0, 1])
            self.assertEqual(good[5][5:], [0, 0])
            self.assertNotEqual(good[0][5], bad[0][5])


if __name__ == "__main__":
    unittest.main()
