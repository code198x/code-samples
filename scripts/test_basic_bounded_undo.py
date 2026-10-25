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
TOPIC = "bounded-undo"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for edits in itertools.product([(0, 0), (0, 3), (15, 0), (15, 3)], repeat=4):
            d = m.initial(TOPIC)
            board = list(range(16))
            d[6:22] = board
            states = [list(board)]
            for cell, value in edits:
                d[1:4] = [0, cell, value]
                d = m.undo(d)
                board = list(board)
                board[cell] = value
                states.append(board)
                self.assertEqual(d[6:22], board)
                self.assertEqual(d[4:6], [1, 0])
            full = list(d)
            full[1:4] = [0, 7, 99]
            blocked = m.undo(full)
            self.assertEqual(blocked[6:], full[6:])
            self.assertEqual(blocked[0], 4)
            self.assertEqual(blocked[4:6], [0, 0])
            for expected in reversed(states[:-1]):
                d[1] = 1
                d = m.undo(d)
                self.assertEqual(d[6:22], expected)
            self.assertEqual(d[0], 0)
            d[1] = 1
            self.assertEqual(m.undo(d)[4:6], [0, 0])
        d = [2, 1, 0, 0, 9, 9] + [0] * 16 + [0, 16, 0, 0] + [1] * 4
        out = m.undo(d)
        self.assertEqual(out[0], 2)
        self.assertEqual(out[5], 1)
        d[1] = 2
        out = m.undo(d)
        self.assertEqual(out[0], 0)
        self.assertEqual(out[6:], d[6:])
        for custom in [False, True]:
            cell = 15 if custom else 0
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[2][6 + cell], 20 if custom else 9)
            self.assertEqual(good[3][6 + cell], 11 if custom else 7)
            self.assertNotEqual(bad[2][6 + cell], 20 if custom else 9)
            self.assertNotEqual(bad[3][6 + cell], 11 if custom else 7)
            self.assertEqual(good[8][4:6], [0, 0])
            self.assertEqual(good[9][0], 0)
            self.assertEqual(good[0][0], 1)


if __name__ == "__main__":
    unittest.main()
