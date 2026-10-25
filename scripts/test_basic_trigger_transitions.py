"""Native records, rejection controls and independent temporal invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-temporal.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "trigger-transitions"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for previous, current in itertools.product(range(256), repeat=2):
            d = m.trigger([99, 99, 99, previous, current, 99])
            e, s, x = d[:3]
            self.assertEqual(e + s, current)
            self.assertEqual(x + s, previous)
            self.assertEqual(e & s, 0)
            self.assertEqual(x & current, 0)
            self.assertEqual(s, previous & current)
            self.assertEqual(d[3:], [current, current, 1])
        for index, value in [(3, -1), (3, 256), (3, 1.5), (4, -1), (4, 256), (4, 1.5)]:
            d = [99, 99, 99, 128, 129, 99]
            d[index] = value
            self.assertEqual(m.trigger(d), [0, 0, 0] + d[3:5] + [0])
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
