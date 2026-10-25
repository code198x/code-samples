"""Native evidence, rejection controls and independent world-policy invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-aim.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "aimed-projectile"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        from fractions import Fraction

        for dx, dy in itertools.product(range(-255, 256, 3), repeat=2):
            x, y = max(0, -dx), max(0, -dy)
            scale = max(abs(dx), abs(dy))
            for speed in [0, 1, 4, 15]:
                d = [99, 99, 99, x, y, x + dx, y + dy, speed]
                r = m.aim(d)
                self.assertEqual(r[2:], [1] + d[3:])
                decoded = [v - 256 if v >= 128 else v for v in r[:2]]
                if scale:
                    expected = [
                        int(Fraction(abs(delta) * speed, scale))
                        * (1 if delta >= 0 else -1)
                        for delta in [dx, dy]
                    ]
                else:
                    expected = [0, 0]
                self.assertEqual(decoded, expected)
                self.assertEqual(max(map(abs, decoded)), speed if scale else 0)
                reverse = m.aim([0, 0, 0, x + dx, y + dy, x, y, speed])
                self.assertEqual(reverse[:2], [(-v) % 256 for v in decoded])
        for index, value in [(3, -1), (4, 256), (5, 1.5), (6, 256), (7, 16), (7, -1)]:
            d = [99, 99, 99, 100, 100, 110, 105, 4]
            d[index] = value
            self.assertEqual(m.aim(d), [0, 0, 0] + d[3:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertTrue(all(m.byte(v) for v in m.packet(TOPIC, variant)))
            self.assertEqual(len(m.packet(TOPIC, variant)), 168)
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
