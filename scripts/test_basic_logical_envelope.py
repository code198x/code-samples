"""Native records, rejection controls and independent interface/data invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-interfaces.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "logical-envelope"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for attack, decay, sustain, release in itertools.product(
            [1, 4, 8, 15], [1, 3, 15], [0, 6, 15], [1, 2, 15]
        ):
            d = [0, 0, 0, 0, 1, attack, decay, sustain, release]
            peak = (15 + attack - 1) // attack
            settle = max(1, (15 - sustain + decay - 1) // decay)
            for tick in range(1, 21):
                if tick <= peak:
                    level = min(15, tick * attack)
                    phase = 2 if tick == peak else 1
                else:
                    elapsed = tick - peak
                    level = max(sustain, 15 - elapsed * decay)
                    phase = 3 if elapsed >= settle else 2
                d = m.envelope(d)
                self.assertEqual(d[:4], [level, phase, 1, 1])
                self.assertEqual(d[4:], [1, attack, decay, sustain, release])
            start = level
            d[4] = 0
            for tick in range(1, 21):
                d = m.envelope(d)
                expected = max(0, start - tick * release)
                self.assertEqual(d[:4], [expected, 4 if expected else 0, 0, 1])
            d[4] = 1
            d = m.envelope(d)
            self.assertEqual(d[:4], [attack, 2 if attack == 15 else 1, 1, 1])
        for index, value in [
            (0, 16),
            (0, 1.5),
            (1, 5),
            (2, 2),
            (4, 256),
            (5, 0),
            (6, 16),
            (7, -1),
            (8, 0),
        ]:
            d = [0, 0, 0, 99, 1, 4, 3, 6, 2]
            d[index] = value
            expected = list(d)
            expected[3] = 0
            self.assertEqual(m.envelope(d), expected)
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
