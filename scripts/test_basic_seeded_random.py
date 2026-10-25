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
TOPIC = "seeded-random"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        # Independent bit-vector feedback over GF(2), not the portable BASIC arithmetic XOR loop.
        for seed in range(256):
            d = m.random([0, seed, 0, 99])
            self.assertEqual(d, [seed or 1, seed, 0, 1])
            old = d[0]
            bits = [(old >> i) & 1 for i in range(8)]
            expected = sum((bits[i + 1] if i < 7 else 0) * 2**i for i in range(8))
            if bits[0]:
                expected = sum(
                    (((expected >> i) & 1) ^ ((180 >> i) & 1)) * 2**i for i in range(8)
                )
            d[2] = 1
            d = m.random(d)
            self.assertEqual(d, [expected, seed, 1, 1])
        d = [1, 0, 1, 0]
        cycle = []
        for _ in range(255):
            cycle.append(d[0])
            d = m.random(d)
        self.assertEqual(set(cycle), set(range(1, 256)))
        self.assertEqual(d[0], 1)
        for saved in cycle:
            first = m.random([saved, 0, 1, 0])
            restored = m.random([0, saved, 0, 0])
            restored[2] = 1
            self.assertEqual(m.random(restored)[0], first[0])
        self.assertEqual(m.random([0, 0, 1, 99]), [0, 0, 1, 0])
        for index, value in [(0, -1), (0, 256), (1, 1.5), (2, 2)]:
            d = [1, 1, 1, 99]
            d[index] = value
            self.assertEqual(m.random(d), d[:3] + [0])
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
