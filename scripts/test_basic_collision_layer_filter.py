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
TOPIC = "collision-layer-filter"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for a, ma, b, mb in itertools.product(range(8), repeat=4):
            for sa, sb in [(0, 0), (0, 1), (1, 0), (255, 255)]:
                d = m.collision([99, a, ma, b, mb, sa, sb, 99])
                accepted = bool(a & mb) and bool(b & ma)
                expected = 2 if accepted and sa and sb else 1 if accepted else 0
                self.assertEqual(d, [expected, a, ma, b, mb, sa, sb, 1])
                swapped = m.collision([99, b, mb, a, ma, sb, sa, 99])
                self.assertEqual(swapped[0], d[0])
        for bit in range(8):
            self.assertEqual(
                m.collision([99, 1 << bit, 255, 255, 1 << bit, 1, 1, 99])[0], 2
            )
        for index, value in [(1, -1), (2, 256), (3, 1.5), (4, -1), (5, 256), (6, 1.5)]:
            d = [99, 1, 2, 2, 1, 1, 1, 99]
            d[index] = value
            self.assertEqual(m.collision(d), [0] + d[1:7] + [0])
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
