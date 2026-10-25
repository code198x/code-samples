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
        C.select("bounded-grid-path")
        C.qualify()

    def test_grid_paths_and_full_reachable_region(self) -> None:
        C.select("bounded-grid-path")
        m = C.M.M
        for w in range(1, 5):
            for h in range(1, 5):
                for start in range(w * h):
                    for target in range(w * h):
                        row = (
                            [w, h, start, target, 9, 9, 9, 9, 9] + [0] * 16 + [42] * 48
                        )
                        out = m.path(row)
                        self.assertEqual(
                            out[4],
                            abs(start % w - target % w) + abs(start // w - target // w),
                        )
                        self.assertEqual(out[8], w * h)
                        self.assertEqual(out[6:8], [1, 0])
        for mask in range(65536):
            cells = [int(bool(mask & (1 << i))) for i in range(16)]
            out = m.path([4, 4, 0, 15, 0, 0, 0, 0, 0] + cells + [42] * 48)
            dist = out[25:41]
            self.assertEqual(out[8], sum(d != 255 for d in dist))
            self.assertLessEqual(out[8], 16)
            if not cells[0]:
                self.assertEqual(dist[0], 0)
            for cell, d in enumerate(dist):
                if d not in [0, 255]:
                    self.assertIn(
                        out[41 + cell],
                        [
                            n
                            for n in [cell - 4, cell + 4, cell - 1, cell + 1]
                            if 0 <= n < 16
                            and abs(n % 4 - cell % 4) + abs(n // 4 - cell // 4) == 1
                        ],
                    )
                    self.assertEqual(dist[out[41 + cell]], d - 1)
        history = m.clients("bounded-grid-path", False, False)
        self.assertEqual(history[0][9 + 4], 0)
        self.assertEqual(history[1][9 + 4], 1)
        self.assertEqual(history[0][4:7], [5, 4, 1])
        self.assertEqual(history[1][6], 0)


if __name__ == "__main__":
    unittest.main()
