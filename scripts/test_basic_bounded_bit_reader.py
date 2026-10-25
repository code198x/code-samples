"""Native records, rejection controls and independent packing invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-packing.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "bounded-bit-reader"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for word in [0, 0xFFFFFFFF, 0xABCDEF01, 0x55AA55AA]:
            bits = f"{word:032b}"
            data = list(word.to_bytes(4, "big"))
            for cursor in range(33):
                for count in range(9):
                    before = [99, 99, cursor, count] + data
                    d = m.read(before)
                    if cursor + count <= 32:
                        self.assertEqual(
                            d[:3],
                            [
                                int(bits[cursor : cursor + count] or "0", 2),
                                1,
                                cursor + count,
                            ],
                        )
                    else:
                        self.assertEqual(d[:3], [0, 0, cursor])
                    self.assertEqual(d[3:], before[3:])
        for index, value in [(2, -1), (2, 1.5), (3, 9), (4, -1), (4, 256), (4, 1.5)]:
            d = [99, 99, 0, 8, 171, 205, 239, 1]
            d[index] = value
            out = m.read(d)
            self.assertEqual(out[:2], [0, 0])
            self.assertEqual(out[2:], d[2:])
        for custom in [False, True]:
            good, checks = m.clients(TOPIC, custom, False)
            bad, badchecks = m.clients(TOPIC, custom, True)
            self.assertEqual(checks, [1, 1])
            self.assertEqual(badchecks, [0, 0])
            self.assertEqual(good[-1][2], 32)
            self.assertLess(bad[-1][2], 32)
            self.assertEqual(good[0][2], 8 if custom else 4)


if __name__ == "__main__":
    unittest.main()
