"""Native records, rejection controls and independent logical-input invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-input-models.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "analogue-deadzone"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for sample, centre, radius in itertools.product(
            range(256), range(256), [0, 8, 16, 127]
        ):
            d = m.analogue([sample, centre, radius, 99, 99, 99])
            delta = sample - centre
            outside = abs(delta) > radius
            self.assertEqual(d[:3], [sample, centre, radius])
            self.assertEqual(
                d[3:],
                [
                    1 if delta < 0 else 2 if delta > 0 else 0,
                    max(0, abs(delta) - radius),
                    1,
                ]
                if outside
                else [0, 0, 1],
            )
        for index, value in [(0, -1), (0, 256), (1, 1.5), (2, -1), (2, 128), (2, 1.5)]:
            d = [110, 100, 8, 99, 99, 99]
            d[index] = value
            self.assertEqual(m.analogue(d), d[:3] + [0, 0, 0])
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
