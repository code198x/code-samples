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
TOPIC = "slope-height"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for profile in [m.PROFILE, [0] * 8, [255] * 8, [7, 6, 5, 4, 3, 2, 1, 0]]:
            for x, base in itertools.product(range(8), range(256)):
                normal = m.slope([x, base, 0, 99, 99] + profile)
                mirrored = m.slope([7 - x, base, 255, 99, 99] + profile)
                expected = base + profile[x]
                self.assertEqual(
                    normal[3:5], [expected, 1] if expected <= 255 else [255, 0]
                )
                self.assertEqual(normal[3:5], mirrored[3:5])
                self.assertEqual(normal[:3], [x, base, 0])
                self.assertEqual(normal[5:], profile)
        self.assertEqual(m.slope([0, 255, 0, 99, 99] + m.PROFILE)[3:5], [255, 1])
        self.assertEqual(m.slope([4, 252, 0, 99, 99] + m.PROFILE)[3:5], [255, 0])
        for index, value in [
            (0, -1),
            (0, 8),
            (0, 1.5),
            (1, 256),
            (2, -1),
            (2, 256),
            (5, 1.5),
            (12, 256),
        ]:
            d = [3, 100, 0, 99, 99] + m.PROFILE
            d[index] = value
            out = m.slope(d)
            self.assertEqual(out[3:5], [255, 0])
            self.assertEqual(out[:3] + out[5:], d[:3] + d[5:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good[0][3], bad[0][3])
            self.assertEqual(good[0][0], 3)
            self.assertEqual(good[3][3:5], [255, 0])
            self.assertEqual(good[-1][3:5], [255, 0])


if __name__ == "__main__":
    unittest.main()
