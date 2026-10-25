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
TOPIC = "weighted-choice"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for weights in itertools.product(range(6), repeat=4):
            total = sum(weights)
            counts = [0] * 4
            for draw in range(total):
                out = m.choice([4, draw, 9, 9, 9, 9] + list(weights) + [0] * 4)
                self.assertEqual(out[3:6], [1, 0, total])
                counts[out[2]] += 1
            self.assertEqual(counts, list(weights))
            invalid = m.choice([4, total, 9, 9, 9, 9] + list(weights) + [0] * 4)
            self.assertEqual(invalid[2:5], [255, 0, 2 if total else 0])
        over = m.choice([2, 0, 9, 9, 9, 9, 200, 100] + [0] * 6)
        self.assertEqual(over[2:6], [255, 0, 1, 0])
        last = m.choice([1, 254, 9, 9, 9, 9, 255] + [0] * 7)
        self.assertEqual(last[2:6], [0, 1, 0, 255])
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[0][2], 3)
            self.assertNotEqual(bad[0][2], 3)
            self.assertEqual(good[1][2], 2 if custom else 3)
            self.assertNotEqual(bad[1][2], 2 if custom else 3)
            self.assertEqual(good[0][6], 2 if custom else 1)
            self.assertEqual(good[-1][6:], [0] * 8)


if __name__ == "__main__":
    unittest.main()
