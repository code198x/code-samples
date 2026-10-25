"""Native records, rejection controls and independent platform-query invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-platforms.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "jump-windows"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for cw, bw in itertools.product([1, 2, 4], repeat=2):
            for events in itertools.product([(0, 0), (1, 0), (0, 1), (1, 1)], repeat=5):
                d = [0, 0, 0, 0, 0, cw, bw, 0]
                ce = be = 0
                for tick, (grounded, pressed) in enumerate(events, 1):
                    if grounded:
                        ce = tick + cw
                    if pressed:
                        be = tick + bw
                    jumped = int(tick < ce and tick < be)
                    if jumped:
                        ce = be = tick
                    d[3:5] = [grounded, pressed]
                    d = m.jump(d)
                    self.assertEqual(
                        d[:3], [jumped, max(0, ce - tick), max(0, be - tick)]
                    )
                    self.assertEqual(d[3:], [grounded, pressed, cw, bw, 1])
        self.assertEqual(m.jump([99, 1, 1, 0, 0, 4, 4, 99])[:3], [0, 0, 0])
        self.assertEqual(m.jump([99, 2, 2, 0, 0, 4, 4, 99])[:3], [1, 0, 0])
        for index, value in [
            (1, -1),
            (1, 256),
            (2, 1.5),
            (3, -1),
            (3, 256),
            (4, 1.5),
            (5, 0),
            (5, 256),
            (6, 0),
            (6, 1.5),
        ]:
            d = [99, 4, 4, 1, 1, 4, 4, 99]
            d[index] = value
            self.assertEqual(m.jump(d), [0] + d[1:7] + [0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual([d[0] for d in good[:4]], [1, 0, 0, 0])
            self.assertEqual([d[0] for d in bad[:4]], [1, 1, 1, 1])
            self.assertEqual(sum(d[0] for d in good[4:]), 0 if custom else 2)
            self.assertEqual(good[0][0], 1)
            self.assertEqual(good[-1][0], 0)


if __name__ == "__main__":
    unittest.main()
