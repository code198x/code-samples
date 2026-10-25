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
        C.select("animation-timeline")
        C.qualify()

    def test_durations_loops_and_frozen_completion(self) -> None:
        C.select("animation-timeline")
        m = C.M.M
        for count in range(1, 9):
            for duration in range(1, 9):
                for loop in [0, 1]:
                    row = [0, 0, count, duration, loop, 0, 0]
                    for _ in range(count * duration):
                        row = m.animation(row)
                    self.assertEqual(row[:2], [0, 0] if loop else [count - 1, 0])
                    self.assertEqual(row[5], 1 - loop)
                    if not loop:
                        self.assertEqual(m.animation(row), row)
        history = m.clients("animation-timeline", False, True)
        self.assertEqual([r[1] for r in history], [1] * 12)


if __name__ == "__main__":
    unittest.main()
