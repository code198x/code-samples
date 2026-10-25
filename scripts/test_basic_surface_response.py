"""Native evidence, rejection controls and independent world-policy invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-traversal.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "surface-response"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        from fractions import Fraction

        for speed, direction, tangent, coefficient in itertools.product(
            range(256), [0, 1], [0, 1, 128, 254, 255], range(5)
        ):
            d = [99] * 4 + [speed, direction, tangent, coefficient]
            r = m.surface(d)
            self.assertEqual(
                r,
                [
                    int(Fraction(speed) * Fraction(coefficient, 4)),
                    1 - direction,
                    tangent,
                    1,
                ]
                + d[4:],
            )
            self.assertLessEqual(r[0], speed)
            restored = m.surface([0] * 4 + [r[0], r[1], r[2], 4])
            self.assertEqual(restored[:3], [r[0], direction, tangent])
        for index, value in [(4, -1), (4, 256), (5, 2), (6, 256), (7, 5), (7, 1.5)]:
            d = [99] * 4 + [11, 1, 254, 3]
            d[index] = value
            self.assertEqual(m.surface(d), [0] * 4 + d[4:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertTrue(all(m.byte(v) for v in m.packet(TOPIC, variant)))
            self.assertLess(len(m.packet(TOPIC, variant)), 995)
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
