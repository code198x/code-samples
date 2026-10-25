"""Native records, rejection controls and independent platform-query invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-platforms.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "camera-deadzone"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for left, right in [(0, 0), (40, 80), (60, 60), (255, 255)]:
            for old, player in itertools.product(range(256), repeat=2):
                before = [old, player, left, right, 255, 99, 99]
                d = m.camera(before)
                self.assertEqual(d[1:5], before[1:5])
                self.assertEqual(d[5:], [int(d[0] != old), 1])
                self.assertTrue(0 <= d[0] <= 255)
                if left <= player - old <= right:
                    self.assertEqual(d[0], old)
                elif player - old < left:
                    self.assertEqual(d[0], max(0, player - left))
                else:
                    self.assertEqual(d[0], min(255, player - right))
        self.assertEqual(
            m.camera([100, 50, 40, 80, 200, 99, 99]), [10, 50, 40, 80, 200, 1, 1]
        )
        for index, value in [
            (0, -1),
            (0, 201),
            (0, 1.5),
            (1, 256),
            (2, 81),
            (3, -1),
            (4, 1.5),
        ]:
            d = [0, 100, 40, 80, 200, 99, 99]
            d[index] = value
            self.assertEqual(m.camera(d), d[:5] + [0, 0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual([d[0] for d in good[:2]], [30, 40] if custom else [10, 20])
            self.assertEqual(good[2][0], 0)
            self.assertEqual(good[3][0], 195 if custom else 175)
            self.assertEqual(good[4][0], good[3][0])
            self.assertEqual(good[4][5:], [0, 0])
            self.assertNotEqual(good[1][0], bad[1][0])


if __name__ == "__main__":
    unittest.main()
