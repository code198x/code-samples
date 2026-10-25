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
TOPIC = "ladder-controller"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for mode, y, on, up, down, jump in itertools.product(
            [0, 1], range(31), [0, 1, 255], [0, 1, 255], [0, 1, 255], [0, 1, 255]
        ):
            d = [mode, y, 99, 99, 99, on, up, down, jump, 0, 30]
            r = m.ladder(d)
            expected_mode = mode
            position = y
            jumped = 0
            if not on:
                expected_mode = 0
            elif mode or up or down:
                if jump:
                    expected_mode = 0
                    jumped = 1
                else:
                    expected_mode = 1
                    position = max(
                        0, min(30, y + (1 if down else 0) - (1 if up else 0))
                    )
            self.assertEqual(
                r, [expected_mode, position, int(not expected_mode), jumped, 1] + d[5:]
            )
        for index, value in [(0, 2), (1, -1), (5, 256), (6, 1.5), (9, 31), (10, -1)]:
            d = [1, 10, 99, 99, 99, 1, 1, 0, 0, 0, 30]
            d[index] = value
            self.assertEqual(m.ladder(d), d[:2] + [0, 0, 0] + d[5:])
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
