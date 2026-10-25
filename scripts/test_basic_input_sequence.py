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
TOPIC = "input-sequence"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for events in itertools.product([0, 1, 2], repeat=7):
            d = [0, 0, 0, 0]
            history = []
            for event in events:
                if event:
                    history.append(event)
                d[1] = event
                d = m.sequence(d)
                self.assertEqual(
                    d[2], int(bool(event) and history[-4:] == [1, 2, 1, 2])
                )
                expected = max(
                    n for n in range(4) if n == 0 or history[-n:] == [1, 2, 1, 2][:n]
                )
                self.assertEqual(d[0], expected)
                self.assertEqual(d[1], event)
                self.assertEqual(d[3], 1)
        for p, q in [(-1, 1), (4, 1), (1.5, 1), (0, -1), (0, 3), (0, 1.5)]:
            self.assertEqual(m.sequence([p, q, 99, 99]), [p, q, 0, 0])
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
