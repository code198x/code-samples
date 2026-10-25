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
TOPIC = "decimal-format"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for value in range(65536):
            before = [value % 256, value // 256, 99] + [99] * 5
            out = m.format_decimal(before)
            self.assertEqual(out[:3], before[:2] + [1])
            self.assertEqual(len(out[3:]), 5)
            self.assertTrue(all(48 <= v <= 57 for v in out[3:]))
            self.assertEqual(int(bytes(out[3:]).decode()), value)
        for index, value in [(0, -1), (0, 256), (0, 1.5), (1, -1), (1, 256), (1, 1.5)]:
            d = [255, 255, 99] + [99] * 5
            d[index] = value
            out = m.format_decimal(d)
            self.assertEqual(out, d[:2] + [0] + d[3:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(bytes(good[0][3:]), b"04096" if custom else b"65535")
            self.assertEqual(
                [bytes(d[3:]) for d in good[1:]],
                [b"00000", b"00001", b"09999", b"10000"],
            )
            self.assertEqual(bad[0][1], 0)


if __name__ == "__main__":
    unittest.main()
