"""Native evidence, rejection controls and independent world-policy invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-traversal.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "viewport-world-transform"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for cx, cy in itertools.product(
            [0, 1, 255, 256, 32768, 65534, 65535], repeat=2
        ):
            for dx, dy in itertools.product(
                [-256, -1, 0, 1, 23, 24, 31, 32, 254, 255], repeat=2
            ):
                wx, wy = cx + dx, cy + dy
                if not 0 <= wx <= 65535 or not 0 <= wy <= 65535:
                    continue
                d = m.viewrow(wx, wy, cx, cy, 32, 24)
                r = m.viewport(d)
                visible = 0 <= dx <= 31 and 0 <= dy <= 23
                self.assertEqual(r[:4], [dx, dy, 1, 1] if visible else [0, 0, 0, 1])
                self.assertEqual(r[4:], d[4:])
        for index, value in [(4, -1), (5, 256), (6, 1.5), (12, 0), (13, 0)]:
            d = m.viewrow(261, 266, 250, 256, 32, 24)
            d[index] = value
            self.assertEqual(m.viewport(d), [0] * 4 + d[4:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertTrue(all(m.byte(v) for v in m.packet(TOPIC, variant)))
            self.assertLess(len(m.packet(TOPIC, variant)), 995)
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
