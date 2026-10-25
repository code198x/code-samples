"""Native observations, rejection controls and independent geometry invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-geometry.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "swept-axis-collision"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for old, target, size, start, end in itertools.product(
            range(9), range(9), range(1, 4), range(9), range(10)
        ):
            before = [99] * 3 + [old, target, size, start, end]
            d = m.sweep(before)
            valid = start < end and not (old < end and old + size > start)
            self.assertEqual(d[2], valid)
            self.assertEqual(d[3:], before[3:])
            if not valid:
                self.assertEqual(d[:3], [old, 0, 0])
                continue
            self.assertTrue(min(old, target) <= d[0] <= max(old, target))
            self.assertFalse(d[0] < end and d[0] + size > start)
            if d[1]:
                self.assertEqual(
                    d[0] + size, start
                ) if target > old else self.assertEqual(d[0], end)
            else:
                self.assertEqual(d[0], target)
        for values in [
            (10, 100, 0, 50, 60),
            (250, 250, 6, 50, 60),
            (10, 251, 5, 50, 60),
            (10, 100, 5, 60, 50),
            (50, 10, 5, 50, 60),
        ]:
            self.assertEqual(m.sweep([99] * 3 + list(values))[:3], [values[0], 0, 0])
        for index, value in [
            (3, -1),
            (3, 256),
            (3, 1.5),
            (4, 256),
            (5, 1.5),
            (6, -1),
            (7, 256),
        ]:
            d = [99] * 3 + [10, 100, 5, 50, 60]
            d[index] = value
            out = m.sweep(d)
            self.assertEqual(out[:3], [d[3], 0, 0])
            self.assertEqual(out[3:], d[3:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][:3], [60 if custom else 45, 1, 1])
            self.assertEqual([d[1] for d in good[1:]], [0, 0, 0])
            self.assertNotEqual(bad[0][0], good[0][0])


if __name__ == "__main__":
    unittest.main()
