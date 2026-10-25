"""Native records, rejection controls and independent resource/action invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-resources.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "resource-wallet"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for balance, amount in itertools.product(range(256), repeat=2):
            for mode in [0, 1]:
                before = [balance, amount, mode, 99, 99]
                d = m.wallet(before)
                self.assertEqual(d[1:3], before[1:3])
                self.assertEqual(d[4], 0)
                if mode == 1:
                    self.assertEqual(d[3], int(amount <= balance))
                    self.assertEqual(balance - d[0], amount if d[3] else 0)
                else:
                    self.assertEqual(d[3], 1)
                    self.assertEqual(d[0] - balance, min(amount, 255 - balance))
                self.assertTrue(0 <= d[0] <= 255)
        for index, value in [(0, -1), (0, 256), (1, 1.5), (2, 2)]:
            d = [3, 2, 1, 99, 99]
            d[index] = value
            self.assertEqual(m.wallet(d), d[:3] + [0, 1])
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
