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
TOPIC = "moving-platform-carry"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for x, old, new in itertools.product(
            range(0, 256, 7), range(0, 256, 11), range(0, 256, 13)
        ):
            for supported in [0, 1, 255]:
                d = [99, 99, 99, x, old, new, supported, 0, 255]
                r = m.carry(d)
                raw = x + new - old
                expected = x if not supported else max(0, min(255, raw))
                self.assertEqual(
                    r[:3], [expected, int(bool(supported) and expected != raw), 1]
                )
                self.assertEqual(r[3:], d[3:])
        for lo, hi, x in [(10, 200, 10), (10, 200, 200), (50, 50, 50)]:
            for old, new in [(0, 0), (0, 255), (255, 0)]:
                r = m.carry([99] * 3 + [x, old, new, 1, lo, hi])
                raw = x + new - old
                self.assertEqual(r[0], max(lo, min(hi, raw)))
                self.assertEqual(r[1], int(raw < lo or raw > hi))
        for vals in [
            (100, 1, 2, 1, 200, 10),
            (9, 1, 2, 1, 10, 200),
            (201, 1, 2, 0, 10, 200),
            (100, 256, 2, 0, 0, 255),
            (100, 1.5, 2, 1, 0, 255),
        ]:
            d = [99] * 3 + list(vals)
            self.assertEqual(m.carry(d), [d[3], 0, 0] + d[3:])
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
