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
TOPIC = "contact-pair-cache"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        d = m.initial(TOPIC)
        seen = set()
        for a, b in itertools.product(range(8), repeat=2):
            if a == b:
                continue
            key = tuple(sorted([a, b]))
            d[2:5] = [2, a, b]
            before = list(d)
            query = m.cache(d)
            self.assertEqual(query[:2], [int(key not in seen), 1])
            self.assertEqual(query[5:], before[5:])
            d[2] = 1
            d = m.cache(d)
            self.assertEqual(d[:2], [int(key not in seen), 1])
            seen.add(key)
        self.assertEqual(len(seen), 28)
        for a in range(8):
            for b in range(8):
                d[2:5] = [1, a, b]
                before = list(d)
                r = m.cache(d)
                self.assertEqual(r[:2], [0, int(a != b)])
                self.assertEqual(r[5:], before[5:])
        d = [99, 99, 1, 0, 3] + [1] * 8
        r = m.cache(d)
        self.assertEqual(r[5:], [9] + [1] * 7)
        for index, value in [(3, 8), (4, 255), (2, 3), (7, 256)]:
            d = [99, 99, 1, 0, 3] + [0] * 8
            d[index] = value
            r = m.cache(d)
            self.assertEqual(r[:2], [0, 0])
            self.assertEqual(r[2:], d[2:])
            d[2] = 0
            self.assertEqual(m.cache(d)[5:], [0] * 8)
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
