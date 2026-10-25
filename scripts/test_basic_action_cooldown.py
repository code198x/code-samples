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
TOPIC = "action-cooldown"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for period in [0, 1, 3, 5, 255]:
            for events in itertools.product([(0, 0), (1, 0), (0, 1), (1, 1)], repeat=5):
                d = [0, 0, 0, period, 0, 0, 0]
                ready = 0
                for tick, (request, available) in enumerate(events):
                    d[1:3] = [request, available]
                    d[4] = 0
                    d = m.cooldown(d)
                    d[4] = 1
                    d = m.cooldown(d)
                    grant = int(tick >= ready and request and available)
                    if grant:
                        ready = tick + period
                    self.assertEqual(d[5:], [grant, 1])
                    self.assertEqual(d[0], max(0, ready - tick))
                    self.assertEqual(d[1:5], [request, available, period, 1])
        for timer in range(256):
            self.assertEqual(
                m.cooldown([timer, 1, 1, 3, 0, 99, 99])[0], max(0, timer - 1)
            )
            self.assertEqual(
                m.cooldown([timer, 1, 1, 3, 1, 99, 99])[0], timer if timer else 3
            )
        for index, value in [(0, -1), (0, 256), (1, 1.5), (2, -1), (3, 256), (4, 2)]:
            d = [4, 1, 1, 3, 1, 99, 99]
            d[index] = value
            self.assertEqual(m.cooldown(d), d[:5] + [0, 0])
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
