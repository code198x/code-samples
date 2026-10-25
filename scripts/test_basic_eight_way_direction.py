"""Native evidence, rejection controls and independent world-policy invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-world-policy.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "eight-way-direction"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for dx, dy in itertools.product(range(-255, 256), repeat=2):
            x, y = max(0, -dx), max(0, -dy)
            d = m.facing([99, 99, 99, x, y, x + dx, y + dy, 99])
            self.assertEqual(d[1:3], [abs(dx), abs(dy)])
            self.assertEqual(d[3:], [x, y, x + dx, y + dy, 1])
            u, v = abs(dx), abs(dy)
            if not u and not v:
                expected = 0
            elif u >= 2 * v:
                expected = 3 if dx > 0 else 7
            elif v >= 2 * u:
                expected = 5 if dy > 0 else 1
            elif dx > 0:
                expected = 4 if dy > 0 else 2
            else:
                expected = 6 if dy > 0 else 8
            self.assertEqual(d[0], expected)
        for index, value in [(3, -1), (4, 256), (5, 1.5), (6, 256)]:
            d = [99, 99, 99, 100, 100, 103, 107, 99]
            d[index] = value
            self.assertEqual(m.facing(d), [0, 0, 0] + d[3:7] + [0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertTrue(all(m.byte(v) for v in m.packet(TOPIC, variant)))
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
