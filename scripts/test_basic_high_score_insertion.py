"""Native records, rejection controls and independent record invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-records.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "high-score-insertion"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for values in itertools.product([0, 1, 255], repeat=6):
            d = m.initial(TOPIC)
            expected = []
            for tag, value in enumerate(values, 1):
                before = list(d)
                d[3:5] = [value, tag]
                d = m.score(d)
                extended = expected + [(value, tag)]
                ordered = sorted(extended, key=lambda item: -item[0])[:4]
                retained = (value, tag) in ordered
                self.assertEqual(
                    d[:3],
                    [ordered.index((value, tag)), 1, 1] if retained else [255, 0, 1],
                )
                self.assertEqual(d[5], len(ordered))
                self.assertEqual(list(zip(d[6 : 6 + d[5]], d[10 : 10 + d[5]])), ordered)
                if not retained:
                    self.assertEqual(d[5:], before[5:])
                expected = ordered
        invalid = [99, 99, 99, 50, 1, 4] + [1, 2, 3, 4] + [1, 2, 3, 4]
        out = m.score(invalid)
        self.assertEqual(out[:3], [255, 0, 0])
        self.assertEqual(out[3:], invalid[3:])
        for index, value in [
            (3, -1),
            (3, 256),
            (4, 1.5),
            (5, -1),
            (5, 5),
            (5, 1.5),
            (6, 256),
            (10, -1),
        ]:
            d = [99, 99, 99, 50, 1, 1] + [100] * 4 + [1] * 4
            d[index] = value
            out = m.score(d)
            self.assertEqual(out[:3], [255, 0, 0])
            self.assertEqual(out[3:], d[3:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][0], 0)
            self.assertNotEqual(good[-1][6:14], bad[-1][6:14])


if __name__ == "__main__":
    unittest.main()
