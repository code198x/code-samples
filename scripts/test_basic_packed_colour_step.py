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
TOPIC = "packed-colour-step"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for current, target in itertools.product(range(256), repeat=2):
            d = m.colour([current, target, 99])
            before = m.channels(current)
            after = m.channels(d[0])
            goal = m.channels(target)
            self.assertEqual(d[1:], [target, 1])
            for a, b, t in zip(before, after, goal):
                self.assertEqual(abs(t - b), max(0, abs(t - a) - 1))
                self.assertTrue(min(a, t) <= b <= max(a, t))
            duration = max(abs(a - b) for a, b in zip(before, goal))
            cursor = current
            for tick in range(duration):
                cursor = m.colour([cursor, target, 0])[0]
            self.assertEqual(cursor, target)
            self.assertEqual(m.colour([target, target, 99]), [target, target, 1])
        for current, target in [(-1, 0), (256, 0), (1.5, 0), (0, 256), (0, 1.5)]:
            self.assertEqual(m.colour([current, target, 99]), [current, target, 0])
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
