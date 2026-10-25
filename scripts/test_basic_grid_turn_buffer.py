"""Native evidence, rejection controls and independent decision/codec invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-decisions.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "grid-turn-buffer"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        graph = {}
        for cell in range(16):
            graph[cell] = {}
            for target in range(16):
                if target == cell - 1 and target // 4 == cell // 4:
                    graph[cell][1] = target
                if target == cell + 1 and target // 4 == cell // 4:
                    graph[cell][2] = target
                if target == cell - 4:
                    graph[cell][3] = target
                if target == cell + 4:
                    graph[cell][4] = target
        for walls in [[], [4], [4, 5], [0, 5, 10, 15]]:
            world = m.world(walls)
            for cell, direction, pending, request in itertools.product(
                range(16), range(5), range(5), range(5)
            ):
                before = [cell, direction, pending, 99, 99, request] + world
                expected = list(before)
                expected[3:5] = [0, 0]
                if cell not in walls:
                    expected[4] = 1
                    expected[2] = request or pending
                    for wanted, turn in [(expected[2], True), (direction, False)]:
                        target = graph[cell].get(wanted)
                        if target is None or target in walls:
                            continue
                        expected[0] = target
                        expected[3] = 1
                        if turn:
                            expected[1] = wanted
                            expected[2] = 0
                        break
                self.assertEqual(m.turns(before), expected)
        for index, value in [
            (0, -1),
            (0, 16),
            (0, 1.5),
            (1, 5),
            (2, 5),
            (5, 255),
            (6, -1),
            (21, 256),
        ]:
            d = [8, 2, 0, 99, 99, 3] + m.world([4])
            d[index] = value
            expected = list(d)
            expected[3:5] = [0, 0]
            self.assertEqual(m.turns(d), expected)
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
