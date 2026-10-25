"""Native records, negative controls and independent service/data invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-services.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "dictionary-lookup"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        keys = [0, 7, 7, 255, 8, 9, 10, 11]
        values = [11, 99, 88, 0, 18, 19, 20, 21]
        for count in range(9):
            mapping = {}
            for k, v in zip(keys[:count], values[:count]):
                mapping.setdefault(k, v)
            for key in range(256):
                before = [99, 99, 99, key, count] + keys + values
                d = m.lookup(before)
                self.assertEqual(d[:3], [mapping.get(key, 0), int(key in mapping), 1])
                self.assertEqual(d[3:], before[3:])
        for index, value in [
            (3, -1),
            (3, 256),
            (3, 1.5),
            (4, 9),
            (4, -1),
            (4, 1.5),
            (5, 256),
            (13, 1.5),
        ]:
            d = [99, 99, 99, 7, 8] + keys + values
            d[index] = value
            out = m.lookup(d)
            self.assertEqual(out[:3], [0, 0, 0])
            self.assertEqual(out[3:], d[3:])
        self.assertEqual(m.lookup([0, 0, 0, 255, 4] + keys + values)[:3], [0, 1, 1])
        self.assertEqual(m.lookup([0, 0, 0, 9, 4] + keys + values)[:3], [0, 0, 1])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(
                [d[:2] for d in good[1:]], [[99, 1], [0, 0], [0, 1], [11, 1]]
            )
            self.assertNotEqual(good[0][:2], bad[0][:2])
            self.assertEqual(good[0][5:], good[-1][5:])


if __name__ == "__main__":
    unittest.main()
