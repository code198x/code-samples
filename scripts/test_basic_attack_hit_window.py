"""Independent policy invariants and native evidence rejection controls."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-combat-focus.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "attack-hit-window"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for mask in range(256):
            for target in range(8):
                for frame in [0, 1, 2, 4, 5, 254, 255]:
                    for contact in [0, 1, 255]:
                        d = [99, 99, mask, frame, 2, 5, target, contact, 0]
                        r = m.attack(d)
                        hit = int(
                            2 <= frame < 5
                            and contact != 0
                            and not (mask & (1 << target))
                        )
                        self.assertEqual(
                            r, [hit, 1, mask | (1 << target) if hit else mask] + d[3:]
                        )
                        reset = m.attack(d[:8] + [1])
                        expected = int(2 <= frame < 5 and contact != 0)
                        self.assertEqual(reset[2], (1 << target) if expected else 0)
                        self.assertEqual(reset[0], expected)
        for index, value in [
            (2, -1),
            (3, 256),
            (4, 1.5),
            (5, -1),
            (6, 8),
            (7, 256),
            (8, -1),
        ]:
            d = [99, 99, 7, 2, 2, 5, 1, 1, 1]
            d[index] = value
            self.assertEqual(m.attack(d), [0, 0] + d[2:])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertNotEqual(good, bad)
        for variant in ["demo", "custom", "wrong", "repaired"]:
            self.assertEqual(len(m.packet(TOPIC, variant)), 198)
        self.assertEqual(m.packet(TOPIC, "demo"), m.packet(TOPIC, "repaired"))


if __name__ == "__main__":
    unittest.main()
