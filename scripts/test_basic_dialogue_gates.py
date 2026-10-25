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
        C.select("dialogue-gates")
        C.qualify()

    def test_query_commit_and_masks(self) -> None:
        C.select("dialogue-gates")
        m = C.M.M
        history = m.clients("dialogue-gates", False, False)
        self.assertEqual(history[0], [1, 1, 2, 2, 1, 0, 1, 0, 0])
        self.assertEqual(history[1], [2, 1, 2, 2, 1, 1, 1, 1, 0])
        self.assertEqual(history[2][6:8], [0, 0])
        for flags in range(256):
            for required in range(256):
                out = m.talk([flags, required, 0, 128, 1, 0, 0, 0, 0])
                self.assertEqual(out[0], flags)
                self.assertEqual(out[6], int((flags & required) == required))
                self.assertEqual(out[7], 0)
        self.assertEqual(m.talk([1, 1, 1, 0, 0, 1, 9, 9, 9])[-3:], [0, 0, 2])
        self.assertEqual(m.talk([1, 0, 0, 1, 1, 1, 0, 0, 0])[0], 1)


if __name__ == "__main__":
    unittest.main()
