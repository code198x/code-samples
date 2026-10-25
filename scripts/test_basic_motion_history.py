"""Native records, altered evidence and independent entity-state invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-entities.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "motion-history"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        d = m.initial(TOPIC)
        timeline = []
        for step in range(1, 33):
            d[2:6] = [step, step * 2, 255, 1]
            out = m.history(d)
            timeline = (timeline + [(step, step * 2)])[-8:]
            self.assertEqual(out[8:10], [0, 0])
            self.assertEqual(out[0], step % 8)
            self.assertEqual(out[1], min(step, 8))
            d = out
            for lag in range(8):
                request = list(d)
                request[4:6] = [lag, 0]
                q = m.history(request)
                self.assertEqual(q[10:], d[10:])
                self.assertEqual(q[:2], d[:2])
                self.assertEqual(
                    q[6:9],
                    [*timeline[-1 - lag], 1] if lag < len(timeline) else [0, 0, 0],
                )
        bad = list(d)
        bad[0] = 8
        out = m.history(bad)
        self.assertEqual(out[10:], bad[10:])
        self.assertEqual(out[9], 1)
        zero = m.history([0, 0, 0, 0, 0, 1, 9, 9, 9, 9] + [0] * 16)
        self.assertEqual(zero[6:10], [0, 0, 1, 0])
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            index = 8 if custom else 11
            self.assertEqual(good[index][6:8], [2, 4] if custom else [10, 20])
            self.assertEqual(bad[index][6:8], [0, 0])
            self.assertEqual(good[0][1], 1)
            self.assertEqual(good[index][1], 8)


if __name__ == "__main__":
    unittest.main()
