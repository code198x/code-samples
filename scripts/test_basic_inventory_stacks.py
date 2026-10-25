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
        C.select("inventory-stacks")
        C.qualify()

    def test_whole_request_conservation(self) -> None:
        C.select("inventory-stacks")
        m = C.M
        for cap in [1, 9, 99, 255]:
            for stock in range(cap + 1):
                for amount in [0, 1, cap, 255]:
                    for mode in [0, 1]:
                        row = [0, amount, mode, cap, 0, 0, stock, 0, 0, 0]
                        out = m.call(row)
                        delta = -amount if mode else amount
                        allowed = 0 <= stock + delta <= cap
                        self.assertEqual(out[6], stock + delta if allowed else stock)
                        self.assertEqual(out[4], int(allowed))
                        self.assertEqual(out[7:], row[7:])
        row = [4, 2, 0, 9, 9, 9, 1, 2, 3, 4]
        self.assertEqual(m.call(row), [4, 2, 0, 9, 0, 2, 1, 2, 3, 4])


if __name__ == "__main__":
    unittest.main()
