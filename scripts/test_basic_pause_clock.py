"""Native records, rejection controls and independent temporal invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-temporal.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "pause-clock"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for counter in range(65536):
            for paused, reset in [(0, 0), (1, 0), (1, 1), (0, 1)]:
                d = m.clock([counter % 256, counter // 256, paused, reset, 99])
                expected = 0 if reset else counter if paused else (counter + 1) % 65536
                self.assertEqual(d[:2], [expected % 256, expected // 256])
                self.assertEqual(d[2:], [paused, reset, 1])
        for index, value in [(0, -1), (1, 256), (2, 1.5), (3, -1)]:
            d = [255, 255, 1, 1, 99]
            d[index] = value
            self.assertEqual(m.clock(d), d[:4] + [0])
        self.assertEqual(m.clock([255, 255, 0, 0, 99])[:2], [0, 0])
        self.assertEqual(m.clock([1, 1, 255, 255, 99]), [0, 0, 255, 255, 1])
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
