"""Qualify native observations and independent game-rule invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-rules.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select("priority-arbiter")
        C.qualify()

    def test_stable_maximum_and_reset(self) -> None:
        C.select("priority-arbiter")
        m = C.M
        for priority in range(256):
            for request in range(256):
                out = m.call([1, 17, priority, 23, request, 0, 0])
                self.assertEqual(out[1], 23 if request > priority else 17)
                self.assertEqual(out[2], max(priority, request))
        self.assertEqual(m.call([0, 255, 255, 0, 0, 0, 0]), [1, 0, 0, 0, 0, 1, 0])
        self.assertEqual(m.call([2, 17, 3, 23, 9, 9, 9]), [2, 17, 3, 23, 9, 0, 1])


if __name__ == "__main__":
    unittest.main()
