"""Native records, rejection controls and independent record invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-records.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "streaming-crc8"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for polynomial in [7, 49]:
            for remainder in range(256):
                for byte in range(256):
                    out = m.crc([remainder, byte, polynomial, 99])
                    self.assertEqual(out[1:], [byte, polynomial, 1])
                    self.assertEqual(
                        out[0], m.crc([0, remainder ^ byte, polynomial, 99])[0]
                    )
                    self.assertTrue(0 <= out[0] <= 255)
            d = [0, 0, polynomial, 0]
            for byte in b"123456789":
                d[1] = byte
                d = m.crc(d)
            self.assertEqual(d[0], 244 if polynomial == 7 else 162)
        self.assertEqual(m.crc([0, 0, 7, 99]), [0, 0, 7, 1])
        for index, value in [
            (0, -1),
            (0, 256),
            (0, 1.5),
            (1, -1),
            (1, 256),
            (1, 1.5),
            (2, 0),
            (2, 255),
            (2, 7.5),
        ]:
            d = [99, 57, 7, 99]
            d[index] = value
            out = m.crc(d)
            self.assertEqual(out, d[:3] + [0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][0], 244 if custom else 151)
            self.assertNotEqual(good[-1][0], bad[-1][0])


if __name__ == "__main__":
    unittest.main()
