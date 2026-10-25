"""Native records, rejection controls and independent temporal invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-temporal.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "rational-tick-divider"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for denominator in range(1, 256):
            for numerator in range(denominator + 1):
                for phase in {0, denominator - 1}:
                    d = m.divider([phase, numerator, denominator, 99, 99])
                    self.assertEqual(d[0] + denominator * d[3], phase + numerator)
                    self.assertTrue(0 <= d[0] < denominator)
                    self.assertIn(d[3], [0, 1])
                    self.assertEqual(d[1:3], [numerator, denominator])
                    self.assertEqual(d[4], 1)
        for denominator in [1, 3, 5, 50, 60, 255]:
            for numerator in range(denominator + 1):
                for phase in {0, denominator - 1}:
                    d = [phase, numerator, denominator, 0, 0]
                    count = 0
                    for tick in range(1, 13):
                        d = m.divider(d)
                        count += d[3]
                        self.assertEqual(
                            count, (phase + tick * numerator) // denominator
                        )
                        self.assertEqual(d[0], (phase + tick * numerator) % denominator)
        for p, n, d in [
            (-1, 1, 3),
            (3, 1, 3),
            (1.5, 1, 3),
            (0, 4, 3),
            (0, 1, 0),
            (0, 1, 256),
            (0, 1.5, 3),
        ]:
            self.assertEqual(m.divider([p, n, d, 99, 99]), [p, n, d, 0, 0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertTrue(all(m.byte(v) for v in m.packet(TOPIC, variant)))
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
