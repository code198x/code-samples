"""Native records, negative controls and independent service/data invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-services.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "priority-event-queue"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for priorities in itertools.product([0, 1, 255], repeat=4):
            d = m.initial(TOPIC)
            for event, p in enumerate(priorities, 1):
                d[5:8] = [0, event, p]
                d = m.queue(d)
                self.assertEqual(d[2:4], [1, 1])
            full = list(d)
            d[5:8] = [0, 99, 255]
            blocked = m.queue(d)
            self.assertEqual(blocked[:4], [255, 0, 0, 1])
            self.assertEqual(blocked[4], 4)
            self.assertEqual(blocked[8:], full[8:])
            actual = []
            for _ in range(4):
                d[5] = 1
                d = m.queue(d)
                actual.append(tuple(d[:2]))
                self.assertEqual(d[8 + d[4]], 0)
                self.assertEqual(d[12 + d[4]], 0)
            self.assertEqual(
                actual, sorted(enumerate(priorities, 1), key=lambda x: -x[1])
            )
            self.assertEqual(d[8:], [0] * 8)
            d[5] = 1
            self.assertEqual(m.queue(d)[:4], [255, 0, 0, 1])
        for index, value in [
            (4, -1),
            (4, 5),
            (4, 1.5),
            (5, 2),
            (5, 1.5),
            (6, 256),
            (7, -1),
            (8, 256),
            (12, 1.5),
        ]:
            d = [99] * 4 + [1, 0, 11, 9] + [22] * 4 + [9] * 4
            d[index] = value
            out = m.queue(d)
            self.assertEqual(out[:4], [255, 0, 0, 0])
            self.assertEqual(out[4:], d[4:])
        d = [99] * 4 + [2, 1, 0, 0] + [1, 2, 0, 0] + [1, 2, 0, 0]
        self.assertEqual(m.queue(d)[:4], [255, 0, 0, 0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual([d[0] for d in good[4:8]], [22, 33, 44, 11])
            self.assertEqual(good[0][4], 1)
            self.assertEqual(good[-1][:4], [255, 0, 0, 1])
            self.assertNotEqual(bad[4][0], good[4][0])


if __name__ == "__main__":
    unittest.main()
