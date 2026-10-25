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
TOPIC = "pixel-mask-collision"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for p in range(256):
            for q in range(256):
                before = [99, 99, 0, 0, 99] + [p] + [0] * 7 + [q] + [0] * 7
                d = m.mask(before)
                self.assertEqual(d[:2], [1, 0] if p & q else [0, 255])
                self.assertEqual(d[2:4], before[2:4])
                self.assertEqual(d[4], 1)
                self.assertEqual(d[5:], before[5:])
        for x, y in itertools.product(range(9), repeat=2):
            d = m.mask([99, 99, x, y, 99] + [255] * 16)
            self.assertEqual(d[:2], [1, y] if x < 8 and y < 8 else [0, 255])
        for index, value in [
            (2, -1),
            (2, 256),
            (2, 1.5),
            (3, -1),
            (3, 256),
            (3, 1.5),
            (5, 256),
            (13, -1),
            (20, 1.5),
        ]:
            d = [99, 99, 0, 0, 99] + [255] * 16
            d[index] = value
            self.assertEqual(m.mask(d), [0, 255] + d[2:4] + [0] + d[5:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][:2], [1, 4] if custom else [0, 255])
            self.assertNotEqual(good[0][:2], bad[0][:2])
            self.assertEqual(good[2][:2], [0, 255])
            self.assertEqual(good[3][:2], [0, 255])
            self.assertEqual(good[0][5:], good[-1][5:])


if __name__ == "__main__":
    unittest.main()
