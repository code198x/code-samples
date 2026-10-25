"""Native records, altered evidence and independent mathematical invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-selection.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "stable-depth-order"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for count in range(9):
            for depths in itertools.product(range(3), repeat=count):
                values = list(depths) + [99] * (8 - count)
                before = [count, 9, 9] + values + [7] * 8
                out = m.order(before)
                self.assertEqual(out[3:11], values)
                self.assertEqual(
                    out[11 : 11 + count],
                    sorted(range(count), key=lambda i: (values[i], i)),
                )
                self.assertEqual(out[11 + count :], list(range(count, 8)))
        bad = [9, 9, 9] + [1] * 8 + [7] * 8
        self.assertEqual(m.order(bad)[11:], bad[11:])
        self.assertEqual(m.order(bad)[1:3], [0, 1])
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[0][11], 1 if custom else 6)
            self.assertEqual(bad[0][11], 0)
            self.assertEqual(good[1][3], 0)
            self.assertEqual(good[0][3], 6)
            self.assertEqual(good[2][11:], good[1][11:])


if __name__ == "__main__":
    unittest.main()
