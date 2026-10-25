"""Independent policy invariants and native evidence rejection controls."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-combat-focus.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "interaction-focus"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        import itertools

        for active in range(16):
            for current in [0, 1, 2, 3, 255]:
                for distances in itertools.product([0, 2, 5, 255], repeat=4):
                    for margin in [0, 2, 255]:
                        d = [99, 99, current, active, 5, margin] + list(distances)
                        r = m.focus(d)
                        eligible = [
                            i
                            for i, x in enumerate(distances)
                            if active & (1 << i) and x <= 5
                        ]
                        expected = 255
                        if eligible:
                            nearest = min(eligible, key=lambda i: (distances[i], i))
                            expected = (
                                current
                                if current in eligible
                                and distances[current] - distances[nearest] <= margin
                                else nearest
                            )
                        self.assertEqual(r, [expected, 1] + d[2:])
        self.assertEqual(m.focus([0, 0, 3, 15, 255, 255, 0, 5, 9, 255])[0], 3)
        for index, value in [
            (2, 4),
            (2, 254),
            (3, 16),
            (4, -1),
            (5, 256),
            (6, 1.5),
            (7, -1),
            (8, 256),
            (9, -1),
        ]:
            d = [99, 99, 1, 3, 20, 2, 9, 10, 30, 30]
            d[index] = value
            self.assertEqual(m.focus(d), [255, 0] + d[2:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertEqual(len(m.packet(TOPIC, variant)), 210)
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
