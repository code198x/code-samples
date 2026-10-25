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
TOPIC = "bounded-bit-writer"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for cursor in range(33):
            for count in range(9):
                for value in range(256):
                    before = [99, cursor, count, value, 85, 170, 85, 170]
                    d = m.write(before)
                    if cursor + count > 32:
                        self.assertEqual(d, [0] + before[1:])
                        continue
                    self.assertEqual(d[:2], [1, cursor + count])
                    back = m.read([99, 99, cursor, count] + d[4:])
                    self.assertEqual(back[0], value % 2**count)
                    old = f"{int.from_bytes(bytes(before[4:]), 'big'):032b}"
                    actual = f"{int.from_bytes(bytes(d[4:]), 'big'):032b}"
                    self.assertEqual(actual[:cursor], old[:cursor])
                    self.assertEqual(actual[cursor + count :], old[cursor + count :])
        for index, value in [
            (1, -1),
            (1, 1.5),
            (2, 9),
            (3, -1),
            (3, 256),
            (4, 256),
            (4, 1.5),
        ]:
            d = [99, 0, 8, 171, 85, 85, 85, 85]
            d[index] = value
            self.assertEqual(m.write(d), [0] + d[1:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[-1][4:], [171, 205, 239, 1])
            self.assertNotEqual(bad[-1][4:], good[-1][4:])
            self.assertEqual(good[0][1], 8 if custom else 4)


if __name__ == "__main__":
    unittest.main()
