"""Native records, rejection controls and independent packing invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-packing.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "bounded-rle"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for counts in itertools.product(range(1, 5), repeat=3):
            plain = [
                v for count, value in zip(counts, [65, 66, 67]) for v in [value] * count
            ]
            stream = [v for pair in zip(counts, [65, 66, 67]) for v in pair] + [0] * 7
            for limit in range(9):
                d = m.decode([99, 99, 0, 6, limit] + stream + [99] * 8)
                n = min(len(plain), limit)
                self.assertEqual(d[:2], [n, 0 if len(plain) <= limit else 4])
                self.assertEqual(d[18 : 18 + n], plain[:n])
                self.assertEqual(d[18 + n :], [99] * (8 - n))
        for count in range(1, 256):
            for limit in range(9):
                d = m.decode([99, 99, 0, 2, limit] + [count, 65] + [0] * 11 + [99] * 8)
                n = min(count, limit)
                self.assertEqual(d[:2], [n, 0 if count <= limit else 4])
                self.assertEqual(d[18:], [65] * n + [99] * (8 - n))
        for s, t, e in [(12, 13, 2), (6, 8, 3), (0, 5, 2)]:
            d = m.decode([99, 99, s, t, 8] + m.STREAM + [99] * 8)
            self.assertEqual(d[1], e)
        for index, value in [(2, -1), (2, 1.5), (3, 14), (4, 9), (5, 256), (5, 1.5)]:
            d = [99, 99, 0, 6, 8] + m.STREAM + [99] * 8
            d[index] = value
            out = m.decode(d)
            self.assertEqual(out[:2], [0, 1])
            self.assertEqual(out[2:], d[2:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            self.assertEqual(c, [1, 1])
            self.assertEqual(good[0][:2], [5, 4] if custom else [6, 0])
            self.assertEqual([d[1] for d in good[1:]], [2, 3, 0])
        self.assertEqual(m.clients(TOPIC, False, True)[1], [0, 0])


if __name__ == "__main__":
    unittest.main()
