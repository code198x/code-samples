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
TOPIC = "moving-solid-push"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for x, w, a, b, s in itertools.product(
            range(0, 32, 3), [1, 2, 4], range(0, 32, 5), range(0, 32, 4), [1, 3]
        ):
            d = [99] * 4 + [x, w, a, b, s, 0, 31]
            r = m.solid(d)
            valid = not (set(range(x, x + w)) & set(range(a, a + s)))
            self.assertEqual(r[3], int(valid))
            self.assertEqual(r[4:], d[4:])
            if not valid:
                self.assertEqual(r[:4], [x, 0, 0, 0])
                continue
            desired = None
            if b > a and a + s <= x < b + s:
                desired = b + s
            if b < a and b < x + w <= a:
                desired = b - w
            if desired is None:
                self.assertEqual(r[:4], [x, 0, 0, 1])
            elif not 0 <= desired <= 31:
                self.assertEqual(r[:4], [x, 0, 1, 1])
            else:
                self.assertEqual(r[:4], [desired, 1, 0, 1])
                self.assertFalse(
                    set(range(desired, desired + w)) & set(range(b, b + s))
                )
        for index, value in [
            (4, -1),
            (5, 0),
            (6, 256),
            (7, 1.5),
            (8, 0),
            (9, 99),
            (10, -1),
        ]:
            d = [99] * 4 + [10, 2, 0, 12, 2, 0, 30]
            d[index] = value
            self.assertEqual(m.solid(d), [d[4], 0, 0, 0] + d[4:])
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
