"""Native records, altered evidence and independent mathematical invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-selection.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "shuffle-bag"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M

        def walk(
            state: list[int], emitted: tuple[int, ...], seen: set[tuple[int, ...]]
        ) -> None:
            left = state[1]
            if not left:
                self.assertEqual(set(emitted), set(range(state[0])))
                seen.add(emitted)
                return
            active = set(state[6 : 6 + left])
            for draw in range(left):
                request = list(state)
                request[2] = draw
                out = m.bag(request)
                self.assertEqual(out[4:6], [1, 0])
                self.assertNotIn(out[3], emitted)
                self.assertEqual(set(out[6 : 6 + out[1]]), active - {out[3]})
                walk(out, emitted + (out[3],), seen)

        for cap in [1, 4, 8]:
            seen: set[tuple[int, ...]] = set()
            start = m.reset_bag([cap, 0, 0, 0, 0, 0] + [0] * 8)
            walk(start, (), seen)
            self.assertEqual(seen, set(itertools.permutations(range(cap))))
        bad = [4, 3, 0, 9, 9, 9, 0, 0, 2, 9, 9, 9, 9, 9]
        out = m.bag(bad)
        self.assertEqual(out[1], 3)
        self.assertEqual(out[6:], bad[6:])
        self.assertEqual(out[5], 1)
        for custom in [False, True]:
            cap = 4 if custom else 8
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(len({d[3] for d in good[1 : cap + 1]}), cap)
            self.assertEqual(len({d[3] for d in bad[1 : cap + 1]}), 1)
            self.assertEqual(good[cap][1], 0)
            self.assertGreater(bad[cap][1], 0)
            self.assertEqual(good[-1][3:6], [255, 0, 0])


if __name__ == "__main__":
    unittest.main()
