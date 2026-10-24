"""Independent state/queue invariants and retained native rejection controls."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-components.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)


class Queues(unittest.TestCase):
    def test_all_native_evidence_and_rejections(self) -> None:
        C.select("event-queue")
        C.qualify()

    def test_fifo_wrap_and_full_preservation(self) -> None:
        C.select("event-queue")
        m = C.M
        for cap in range(1, 9):
            for head in range(cap):
                for count in range(cap + 1):
                    row = [cap, head, (head + count) % cap, count, 255, 1, 0, 0] + list(
                        range(8)
                    )
                    out = m.call(row)
                    self.assertEqual(out[3], min(count + 1, cap))
                    if count == cap:
                        self.assertEqual(out[:6] + out[8:], row[:6] + row[8:])
                    else:
                        self.assertEqual(out[8 + row[2]], 255)
                    row[5] = 2
                    out = m.call(row)
                    self.assertEqual(out[3], max(0, count - 1))
                    if count:
                        self.assertEqual(out[4], head)
        for cap in [4, 8]:
            self.assertNotEqual(m.packet("demo"), m.packet("wrong"))
        self.assertEqual(m.packet("demo"), m.packet("repaired"))


if __name__ == "__main__":
    unittest.main()
