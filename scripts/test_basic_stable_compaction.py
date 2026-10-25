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
TOPIC = "stable-compaction"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for count in range(9):
            for mask in range(1 << count):
                flags = [i + 1 if mask & (1 << i) else 0 for i in range(count)] + [
                    200
                ] * (8 - count)
                values = list(range(10, 18))
                state = [count, 9, 9, 9] + flags + values
                out = m.compact(state)
                kept = [i for i in range(count) if mask & (1 << i)]
                n = len(kept)
                self.assertEqual(out[:4], [n, count - n, 1, 0])
                self.assertEqual(out[4 : 4 + n], [flags[i] for i in kept])
                self.assertEqual(out[12 : 12 + n], [values[i] for i in kept])
                self.assertEqual(out[4 + n : 4 + count], [0] * (count - n))
                self.assertEqual(out[12 + n : 12 + count], [0] * (count - n))
                self.assertEqual(out[4 + count : 12], flags[count:])
                self.assertEqual(out[12 + count :], values[count:])
        state = [9, 9, 9, 9] + [1] * 8 + list(range(8))
        out = m.compact(state)
        self.assertEqual(out[4:], state[4:])
        self.assertEqual(out[:4], [9, 0, 0, 1])
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[0][0], 2)
            self.assertEqual(bad[0][0], 3)
            self.assertEqual(good[0][12 + (3 if custom else 4)], 88 if custom else 99)
            self.assertEqual(bad[0][12 + (3 if custom else 4)], 0)
            self.assertEqual(good[2][4:], good[1][4:])


if __name__ == "__main__":
    unittest.main()
