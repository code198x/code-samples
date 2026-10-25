"""Native observations, rejection controls and independent mask/motion invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-motion.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "fractional-position"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for raw in range(65536):
            for displacement in [64, -128]:
                v = m.word(displacement)
                before = m.word(raw) + v + [99]
                d = m.position(before)
                self.assertEqual(d[:2], m.word(raw + displacement))
                self.assertEqual(d[2:], v + [1])
        for raw in range(0, 65536, 257):
            for displacement in [-32768, -257, -256, -1, 0, 1, 255, 256, 32767]:
                d = m.position(m.word(raw) + m.word(displacement) + [99])
                self.assertEqual(d[0] + 256 * d[1], (raw + displacement) % 65536)
        for index, value in [
            (0, -1),
            (0, 256),
            (0, 1.5),
            (1, 256),
            (2, -1),
            (2, 1.5),
            (3, 256),
        ]:
            d = [0, 100, 64, 0, 99]
            d[index] = value
            self.assertEqual(m.position(d), d[:4] + [0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[3][:2], [0, 102 if custom else 101])
            self.assertEqual(bad[3][:2], [128 if custom else 64, 100])
            self.assertEqual(good[4][:2], [128, 101 if custom else 100])
            self.assertEqual(good[4][:2], good[5][:2])
            self.assertEqual(good[0][0], 128 if custom else 64)


if __name__ == "__main__":
    unittest.main()
