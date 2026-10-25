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
TOPIC = "generation-handles"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for mask in range(16):
            for generation in range(256):
                state = [mask, 0, 255, 255, 9, 9, 9, 9] + [generation] * 4
                out = m.handles(state)
                free = [i for i in range(4) if not mask & (1 << i)]
                if free:
                    self.assertEqual(out[4:8], [1, free[0], (generation + 1) % 256, 0])
                    self.assertEqual(out[0], mask | (1 << free[0]))
                else:
                    self.assertEqual(out[4:8], [0, 255, 0, 0])
                for slot in range(4):
                    request = list(state)
                    request[1:4] = [2, slot, generation]
                    q = m.handles(request)
                    self.assertEqual(q[4], int(bool(mask & (1 << slot))))
                    self.assertEqual(q[0], mask)
                    request[1] = 1
                    q = m.handles(request)
                    self.assertEqual(q[0], mask & ~(1 << slot))
                    self.assertEqual(q[8:], state[8:])
        d = m.initial(TOPIC)
        first = None
        for i in range(257):
            d[1] = 0
            d = m.handles(d)
            if first is None:
                first = d[6]
            if i == 256:
                self.assertEqual(d[6], first)
                break
            d[1:4] = [1, d[5], d[6]]
            d = m.handles(d)
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[1][4], 1)
            self.assertEqual(good[2][4], 1)
            self.assertEqual(bad[1][4], 0)
            self.assertEqual(bad[2][4], 0)
            self.assertEqual(good[4][4], 0)
            self.assertEqual(good[5][4], 1)
            self.assertEqual(good[3][6], 0 if custom else 2)


if __name__ == "__main__":
    unittest.main()
