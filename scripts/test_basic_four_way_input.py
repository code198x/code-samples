"""Native records, rejection controls and independent logical-input invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-input-models.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "four-way-input"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for held, axis in itertools.product(range(256), [0, 1]):
            d = m.directions([held, axis, 99, 99])
            horizontal = (held % 4 in [2]) - (held % 4 in [1])
            vertical = ((held // 4) % 4 in [2]) - ((held // 4) % 4 in [1])
            chosen = axis
            if not horizontal and vertical:
                chosen = 1
            if horizontal and not vertical:
                chosen = 0
            direction = (
                (1 if horizontal < 0 else 2)
                if chosen == 0 and horizontal
                else (3 if vertical < 0 else 4)
                if chosen == 1 and vertical
                else 0
            )
            self.assertEqual(d, [held, chosen, direction, 1])
            self.assertEqual(m.directions([held % 16, axis, 0, 0])[1:], d[1:])
        for h, a in [(-1, 0), (256, 0), (1.5, 0), (5, 2), (5, 1.5)]:
            self.assertEqual(m.directions([h, a, 99, 99]), [h, a, 0, 0])
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
