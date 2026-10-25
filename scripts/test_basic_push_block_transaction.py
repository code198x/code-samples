"""Native evidence, rejection controls and independent world-policy invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-world-policy.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "push-block-transaction"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        graph = {}
        for c in range(16):
            graph[c] = {}
            if c % 4:
                graph[c][1] = c - 1
            if c % 4 < 3:
                graph[c][2] = c + 1
            if c >= 4:
                graph[c][3] = c - 4
            if c < 12:
                graph[c][4] = c + 4
        for cell, request, crate, wall in itertools.product(
            range(16), range(1, 5), range(-1, 16), range(-1, 16)
        ):
            world = m.board([] if crate < 0 else [crate], [] if wall < 0 else [wall])
            before = [cell, 99, 99, request] + world
            d = m.push(before)
            expected = list(before)
            expected[1:3] = [0, 0]
            if world[cell] == 0:
                expected[2] = 1
                adjacent = graph[cell].get(request)
                if adjacent is not None:
                    if world[adjacent] == 0:
                        expected[0] = adjacent
                        expected[1] = 1
                    elif world[adjacent] == 2:
                        destination = graph[adjacent].get(request)
                        if destination is not None and world[destination] == 0:
                            expected[4 + adjacent] = 0
                            expected[4 + destination] = 2
                            expected[0] = adjacent
                            expected[1] = 2
            self.assertEqual(d, expected)
            self.assertEqual(d[4:].count(2), world.count(2))
            if not d[1]:
                self.assertEqual(d[4:], world)
            if d[2]:
                self.assertEqual(d[4 + int(d[0])], 0)
        for index, value in [
            (0, -1),
            (0, 16),
            (0, 1.5),
            (3, 0),
            (3, 5),
            (4, -1),
            (19, 256),
        ]:
            d = [5, 99, 99, 2] + m.board([6])
            d[index] = value
            expected = list(d)
            expected[1:3] = [0, 0]
            self.assertEqual(m.push(d), expected)
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
