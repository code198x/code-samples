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
TOPIC = "input-repeat"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for delay, rate in itertools.product([1, 2, 4], repeat=2):
            for events in itertools.product([0, 1], repeat=6):
                d = [0, 0, 0, 0, delay, rate, 0]
                due = None
                for tick, held in enumerate(events):
                    expected = 0
                    if not held:
                        due = None
                    elif due is None:
                        expected = 1
                        due = tick + delay
                    elif tick == due:
                        expected = 1
                        due = tick + rate
                    d[0] = held
                    d = m.repeat(d)
                    self.assertEqual(d[3], expected)
                    self.assertEqual(d[1], held)
                    self.assertEqual(d[2], 0 if due is None else due - tick)
                    self.assertEqual(d[4:], [delay, rate, 1])
        for index, value in [
            (0, -1),
            (0, 256),
            (1, 2),
            (2, 1.5),
            (3, 99),
            (4, 0),
            (4, 256),
            (5, 0),
        ]:
            if index == 3:
                continue
            d = [1, 1, 2, 99, 4, 2, 99]
            d[index] = value
            out = m.repeat(d)
            expected = list(d)
            expected[3] = expected[6] = 0
            self.assertEqual(out, expected)
        self.assertEqual(m.repeat([255, 0, 255, 99, 4, 2, 99]), [255, 1, 4, 1, 4, 2, 1])
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
