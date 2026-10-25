"""Native evidence, rejection controls and independent world-policy invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-contacts.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "spatial-bucket"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for x, y in itertools.product(range(16), repeat=2):
            d = m.bucketrow(1, x, y, 255)
            r = m.buckets(d)
            b = x // 8 + 2 * (y // 8)
            self.assertEqual(r[:5], [b, 1, 1, 0, 1])
            self.assertEqual(r[9 + b], 1)
            self.assertEqual(r[13 + 4 * b], 255)
            self.assertEqual(sum(r[9:13]), 1)
            for item in [0, 17, 99]:
                r[8] = item
                r = m.buckets(r)
            before = list(r)
            r[8] = 88
            full = m.buckets(r)
            self.assertEqual(full[:5], [b, 4, 0, 1, 1])
            self.assertEqual(full[9:], before[9:])
            full[5] = 2
            query = m.buckets(full)
            self.assertEqual(query[:5], [b, 4, 0, 0, 1])
            self.assertEqual(query[9:], full[9:])
        for index, value in [(6, 16), (7, -1), (8, 256), (9, 5), (12, 5), (28, 256)]:
            d = m.bucketrow(1, 0, 0, 3)
            d[index] = value
            r = m.buckets(d)
            self.assertEqual(r[:5], [255, 0, 0, 0, 0])
            self.assertEqual(r[5:], d[5:])
            d[5] = 0
            cleared = m.buckets(d)
            self.assertEqual(cleared[9:], [0] * 20)
            self.assertEqual(cleared[:5], [0, 0, 0, 0, 1])
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
