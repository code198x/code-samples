"""Native records, altered evidence and independent entity-state invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-entities.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "waypoint-route"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for x in range(256):
            for target in range(256):
                for speed in [1, 7, 255]:
                    d = m.route([x, 0, 1, speed, 0, 9, 0, 9, 9, target, 0, 0, 0])
                    self.assertEqual(d[7:9], [1, 0])
                    self.assertLessEqual(abs(d[0] - x), speed)
                    self.assertLessEqual(min(x, target), d[0])
                    self.assertLessEqual(d[0], max(x, target))
                    self.assertEqual(
                        abs(target - d[0]), max(0, abs(target - x) - speed)
                    )
                    self.assertEqual(d[5], int(d[0] == target))
                    self.assertEqual(d[6], d[5])
        d = [2, 0, 4, 1, 1, 0, 0, 0, 0] + [2] * 4
        for i in range(12):
            d = m.route(d)
            self.assertEqual(d[1], (i + 1) % 4)
            self.assertEqual(d[5], 1)
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertTrue(any(d[5] and d[0] == 1 for d in good))
            self.assertTrue(any(d[5] and d[0] == 3 for d in good))
            self.assertFalse(any(d[5] and d[0] in [1, 3] for d in bad))
            self.assertEqual(good[-1][6], 0 if custom else 1)
            self.assertEqual(good[0][0], 5 if custom else 4)


if __name__ == "__main__":
    unittest.main()
