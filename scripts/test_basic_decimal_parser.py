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
TOPIC = "decimal-parser"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for prefix in range(256):
            for char in range(256):
                out = m.parse([prefix, char, 99])
                self.assertEqual(out[1], char)
                if 48 <= char <= 57:
                    expected = prefix * 10 + char - 48
                    self.assertEqual(out[2], 1 if expected <= 255 else 3)
                    self.assertEqual(out[0], expected if expected <= 255 else prefix)
                else:
                    self.assertEqual(out, [prefix, char, 2])
        for index, value in [(0, -1), (0, 256), (0, 1.5), (1, -1), (1, 256), (1, 1.5)]:
            d = [25, 53, 99]
            d[index] = value
            self.assertEqual(m.parse(d), d[:2] + [4])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[0][0], 1 if custom else 2)
            self.assertNotEqual(good[-1][0], bad[-1][0])
        self.assertEqual(m.parse([25, 54, 99]), [25, 54, 3])
        self.assertEqual(m.parse([25, 53, 99]), [255, 53, 1])


if __name__ == "__main__":
    unittest.main()
