"""Native records, altered evidence and independent mathematical invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-selection.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "dirty-cells"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for mask in range(65536):
            before = [mask % 256, mask // 256, 255, 3, 9, 9, 9]
            peek = m.dirty(before)
            self.assertEqual(peek[:2], before[:2])
            self.assertEqual(peek[6], 0)
            before[3] = 2
            take = m.dirty(before)
            rest = take[0] + 256 * take[1]
            if mask:
                lowest = (mask & -mask).bit_length() - 1
                self.assertEqual(peek[4:6], [1, lowest])
                self.assertEqual(take[4:6], [1, lowest])
                self.assertEqual(rest, mask & (mask - 1))
            else:
                self.assertEqual(take[4:6], [0, 255])
                self.assertEqual(rest, 0)
        for slot in range(16):
            mark = m.dirty([0, 0, slot, 0, 9, 9, 9])
            self.assertEqual(mark[0] + 256 * mark[1], 1 << slot)
            self.assertEqual(mark[4], 1)
            self.assertEqual(m.dirty(mark)[4], 0)
            mark[3] = 1
            clear = m.dirty(mark)
            self.assertEqual(clear[:2], [0, 0])
            self.assertEqual(clear[4], 1)
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[5][4], 1)
            self.assertEqual(good[6][4], 1)
            self.assertEqual(bad[5][4], 0)
            self.assertEqual(bad[6][4], 0)
            self.assertNotEqual(good[0][:2], good[3][:2])


if __name__ == "__main__":
    unittest.main()
