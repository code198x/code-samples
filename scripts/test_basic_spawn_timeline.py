"""Native records, altered evidence and independent snapshot/timing invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-timelines.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "spawn-timeline"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for delays in itertools.product(range(4), repeat=4):
            d = m.initial(TOPIC)
            d[8:] = [10, 20, 30, 40] + list(delays)
            emitted = []
            for tick in range(1, sum(delays) + 7):
                d = m.timeline(d)
                if d[5]:
                    emitted.append((tick, d[4]))
            time = 0
            expected = []
            for delay, event in zip(delays, [10, 20, 30, 40]):
                time += delay + 1
                expected.append((time, event))
            self.assertEqual(emitted, expected)
            self.assertEqual(d[3], 1)
        d = [1, 0, 254, 0, 9, 9, 9, 9, 255, 0, 0, 0, 255, 0, 0, 0]
        d = m.timeline(d)
        self.assertEqual(d[2], 255)
        self.assertEqual(d[5], 0)
        d = m.timeline(d)
        self.assertEqual(d[4:6], [255, 1])
        self.assertEqual(d[3], 1)
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual([d[4] for d in good if d[5]], [10, 20, 30, 40])
            self.assertNotEqual(len([d for d in bad if d[5]]), 4)
            self.assertNotEqual(sum(d[4] for d in bad if d[5]), 100)
            self.assertEqual(good[0][1], 1 if custom else 0)


if __name__ == "__main__":
    unittest.main()
