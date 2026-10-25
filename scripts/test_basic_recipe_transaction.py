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
        C.select("recipe-transaction")
        C.qualify()

    def test_atomic_costs_and_capacity(self) -> None:
        C.select("recipe-transaction")
        m = C.M
        for h in range(8):
            for i in range(8):
                for result in range(8):
                    row = [h, i, result, 2, 1, 2, 7, 0, 0]
                    out = m.call(row)
                    ok = h >= 2 and i >= 1 and result <= 5
                    self.assertEqual(
                        out[:3], [h - 2, i - 1, result + 2] if ok else row[:3]
                    )
                    self.assertEqual(out[7], int(ok))
        for a, b, p in [(0, 0, 1), (1, 1, 0), (0, 1, 1), (1, 0, 1)]:
            out = m.call([5, 5, 0, a, b, p, 7, 0, 0])
            self.assertEqual(out[8], 2 if (a + b == 0 or p == 0) else 0)


if __name__ == "__main__":
    unittest.main()
