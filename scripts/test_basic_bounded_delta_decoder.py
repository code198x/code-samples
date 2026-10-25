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
TOPIC = "bounded-delta-decoder"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for base in range(256):
            for byte in range(256):
                d = m.delta([99, 99, 1, base] + [byte] * 8 + [99] * 8)
                self.assertEqual(d[:4], [1, 1, 1, base])
                self.assertEqual(d[12:], [(base + byte) % 256] + [99] * 7)
        for count in range(9):
            before = [99, 99, count, 250] + [10, 128, 255, 1, 127, 129, 0, 5] + [99] * 8
            d = m.delta(before)
            self.assertEqual(
                d[12 : 12 + count], [4, 132, 131, 132, 3, 132, 132, 137][:count]
            )
            self.assertEqual(d[12 + count :], [99] * (8 - count))
            self.assertEqual(d[2:12], before[2:12])
        for index, value in [
            (2, -1),
            (2, 9),
            (2, 1.5),
            (3, 256),
            (3, -1),
            (4, 256),
            (4, 1.5),
        ]:
            d = [99, 99, 8, 100] + [1] * 8 + [99] * 8
            d[index] = value
            out = m.delta(d)
            self.assertEqual(out[:2], [0, 0])
            self.assertEqual(out[2:], d[2:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[1][12:], good[0][12:])
            self.assertEqual(good[2][12:], good[0][12:])
            self.assertEqual(good[2][:2], [0, 0])
            self.assertNotEqual(good[0][12:], bad[0][12:])


if __name__ == "__main__":
    unittest.main()
