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
TOPIC = "one-way-platform"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for x, w, a, b in itertools.product(range(6), range(4), range(6), range(4)):
            for old, new, y in [
                (0, 6, 3),
                (3, 3, 3),
                (4, 2, 3),
                (3, 6, 3),
                (4, 6, 3),
                (0, 2, 3),
            ]:
                for drop in [0, 1, 255]:
                    before = [99, 99, x, w, old, new, a, b, y, drop, 99]
                    d = m.platform(before)
                    landed = int(
                        not drop
                        and w > 0
                        and b > 0
                        and max(x, a) < min(x + w, a + b)
                        and old <= y <= new
                    )
                    self.assertEqual(d[:2], [landed, y if landed else new])
                    self.assertEqual(d[2:10], before[2:10])
                    self.assertEqual(d[10], 1)
        self.assertEqual(
            m.platform([0, 0, 250, 20, 90, 110, 255, 20, 100, 0, 0])[:2], [1, 100]
        )
        self.assertEqual(
            m.platform([0, 0, 0, 255, 0, 255, 255, 1, 100, 0, 0])[:2], [0, 255]
        )
        for index, value in [
            (2, -1),
            (3, 256),
            (4, 1.5),
            (5, -1),
            (6, 256),
            (7, 1.5),
            (8, 256),
            (9, -1),
        ]:
            d = [99, 99, 10, 10, 90, 110, 15, 10, 100, 0, 99]
            d[index] = value
            out = m.platform(d)
            self.assertEqual(out[:2], [0, d[5]])
            self.assertEqual(out[2:10], d[2:10])
            self.assertEqual(out[10], 0)
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            self.assertEqual(c, [1, 1])
            self.assertEqual(good[0][:2], [0, 110] if custom else [1, 100])
            self.assertEqual([d[:2] for d in good[1:]], [[0, 90], [1, 100], [0, 110]])
        bad, b = m.clients(TOPIC, False, True)
        self.assertEqual(b, [0, 0])
        self.assertEqual(bad[0][:2], [0, 110])


if __name__ == "__main__":
    unittest.main()
