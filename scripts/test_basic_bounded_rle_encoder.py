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
TOPIC = "bounded-rle-encoder"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for count in range(9):
            for values in itertools.product([0, 255], repeat=count):
                expected = []
                for value in values:
                    if expected and expected[-1] == value:
                        expected[-2] += 1
                    else:
                        expected.extend([1, value])
                for capacity in range(17):
                    d = m.encode(
                        [99, 99, 99, count, capacity]
                        + list(values)
                        + [0] * (8 - count)
                        + [99] * 16
                    )
                    if len(expected) > capacity:
                        self.assertEqual(d[:3], [0, 2, 1])
                        self.assertEqual(d[13:], [99] * 16)
                    else:
                        self.assertEqual(d[:3], [len(expected), 0, 1])
                        self.assertEqual(d[13 : 13 + len(expected)], expected)
                        self.assertEqual(
                            d[13 + len(expected) :], [99] * (16 - len(expected))
                        )
                        if len(expected) <= 13:
                            back = m.decode(
                                [0, 0, 0, len(expected), 8]
                                + expected
                                + [0] * (13 - len(expected))
                                + [99] * 8
                            )
                            self.assertEqual(back[:2], [count, 0])
                            self.assertEqual(back[18 : 18 + count], list(values))
        for index, value in [(3, -1), (3, 1.5), (3, 9), (4, 17), (5, 256), (5, 1.5)]:
            d = [99, 99, 99, 8, 16] + [65] * 8 + [99] * 16
            d[index] = value
            out = m.encode(d)
            self.assertEqual(out[:3], [0, 1, 0])
            self.assertEqual(out[3:], d[3:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[1][13:], good[0][13:])
            self.assertEqual(good[1][:3], [0, 2, 1])
            self.assertEqual(good[2][:3], [0, 0, 1])
            self.assertEqual(good[3][:3], [2, 0, 1])
            self.assertEqual(bad[0][13:], [99] * 16)


if __name__ == "__main__":
    unittest.main()
