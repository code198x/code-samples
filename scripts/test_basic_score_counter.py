"""Native records, rejection controls and independent resource/action invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-resources.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "score-counter"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for cap in [0, 1, 255, 256, 999, 65535]:
            for old in sorted({0, cap // 2, cap}):
                for award in [0, 1, 255, 256, 300, 65535]:
                    before = [
                        old % 256,
                        old // 256,
                        award % 256,
                        award // 256,
                        cap % 256,
                        cap // 256,
                        99,
                        99,
                    ]
                    d = m.score(before)
                    new = d[0] + 256 * d[1]
                    self.assertEqual(d[2:6], before[2:6])
                    self.assertEqual(new, min(cap, old + award))
                    self.assertEqual(d[6:], [int(award > cap - old), 1])
                    self.assertTrue(old <= new <= cap)
        for award in range(65536):
            d = m.score([255, 0, award % 256, award // 256, 255, 255, 0, 0])
            self.assertEqual(d[0] + 256 * d[1], min(65535, 255 + award))
            self.assertEqual(d[6], int(award > 65280))
        self.assertEqual(
            m.score([0, 4, 0, 0, 231, 3, 99, 99]), [0, 4, 0, 0, 231, 3, 0, 0]
        )
        for index, value in [(0, -1), (1, 256), (2, 1.5), (3, -1), (4, 256), (5, 1.5)]:
            d = [250, 0, 44, 1, 255, 255, 99, 99]
            d[index] = value
            self.assertEqual(m.score(d), d[:6] + [0, 0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertTrue(all(m.byte(v) for v in m.packet(TOPIC, variant)))
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
