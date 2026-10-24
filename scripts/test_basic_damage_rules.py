"""Qualify native observations and independent game-rule invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-rules.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select("damage-rules")
        C.qualify()

    def test_saturation_and_recovery_boundaries(self) -> None:
        C.select("damage-rules")
        m = C.M
        for health in range(256):
            for amount in range(256):
                out = m.call([health, 0, amount, 4, 0, 0, 0])
                self.assertEqual(out[0], max(0, health - amount))
                self.assertEqual(out[4], int(health > 0 and amount > 0))
                self.assertEqual(out[5], int(health > 0 and amount >= health))
        for remaining in range(256):
            out = m.call([3, remaining, 1, 4, 0, 0, 0])
            self.assertEqual(out[4], int(remaining <= 1))
            self.assertGreaterEqual(out[1], 0)
        for bad in [0, 1.5, 256]:
            out = m.call([3, 2, 1, bad, 9, 9, 9])
            self.assertEqual(out[:4], [3, 2, 1, bad])
            self.assertEqual(out[4:], [0, 0, 1])


if __name__ == "__main__":
    unittest.main()
