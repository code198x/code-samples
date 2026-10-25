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
TOPIC = "camera-shake"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for amplitude, remaining in itertools.product(range(16), [0, 1, 2, 255]):
            for n, noise_y in itertools.product(range(0, 256, 17), repeat=2):
                d = [99, 99, remaining, amplitude, 99, 0, amplitude, 9, n, noise_y]
                r = m.shake(d)
                self.assertEqual(r[4], 1)
                self.assertEqual(r[2], max(0, remaining - 1))
                self.assertEqual(r[3], amplitude)
                decoded = [v - 256 if v >= 128 else v for v in r[:2]]
                if remaining:
                    self.assertEqual(
                        decoded,
                        [
                            n % (2 * amplitude + 1) - amplitude,
                            noise_y % (2 * amplitude + 1) - amplitude,
                        ],
                    )
                else:
                    self.assertEqual(decoded, [0, 0])
                self.assertTrue(all(-amplitude <= v <= amplitude for v in decoded))
        for duration in [0, 1, 3, 255]:
            d = [0, 0, 17, 255, 0, 1, 15, duration, 0, 255]
            r = m.shake(d)
            self.assertEqual(r[2:5], [max(0, duration - 1), 15, 1])
            r[5] = 0
            active = int(duration > 0)
            while r[2]:
                active += 1
                r = m.shake(r)
            self.assertEqual(active, duration)
            self.assertEqual(m.shake(r)[:2], [0, 0])
        for index, value in [(2, 256), (3, 255), (6, 16), (7, -1), (8, 1.5)]:
            d = [99, 99, 3, 3, 99, 0, 3, 4, 0, 255]
            d[index] = value
            r = m.shake(d)
            self.assertEqual(r[:2], [0, 0])
            self.assertEqual(r[4], 0)
            self.assertEqual(r[2:4], d[2:4])
            self.assertEqual(r[5:], d[5:])
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
