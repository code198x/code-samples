"""Native evidence, immutable model histories and independent invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-world.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select("grid-line-sight")
        C.qualify()

    def test_octants_ties_and_blockers(self) -> None:
        C.select("grid-line-sight")
        m = C.M.M
        for start in range(16):
            for target in range(16):
                cells = m.sampled_cells(4, start, target)
                self.assertEqual((cells[0], cells[-1]), (start, target))
                self.assertEqual(
                    len(cells),
                    max(abs(start % 4 - target % 4), abs(start // 4 - target // 4)) + 1,
                )
                for wall in range(16):
                    grid = [int(i == wall) for i in range(16)]
                    out = m.sight([4, 4, start, target, 0, 0, 0] + grid + [42] * 16)
                    self.assertEqual(out[4], int(wall not in cells))
        self.assertEqual(m.sampled_cells(4, 0, 6), [0, 5, 6])
        self.assertEqual(m.sampled_cells(4, 6, 0), [6, 1, 0])
        for mask in range(65536):
            grid = [int(bool(mask & (1 << i))) for i in range(16)]
            out = m.sight([4, 4, 0, 15, 0, 0, 0] + grid + [42] * 16)
            self.assertEqual(
                out[4], int(not any(mask & (1 << i) for i in [0, 5, 10, 15]))
            )
        history = m.clients("grid-line-sight", False, False)
        self.assertEqual(history[0][7 + 5], 1)
        self.assertEqual(history[1][7 + 5], 0)


if __name__ == "__main__":
    unittest.main()
