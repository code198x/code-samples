"""Native records, rejection controls and independent interface/data invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-interfaces.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "packed-nibble-map"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for cell, old, new in itertools.product(range(16), range(256), range(16)):
            data = list(m.BYTES)
            data[cell // 2] = old
            d = m.packed([99, 99, cell, 1, new] + data)
            expected = list(data)
            expected[cell // 2] = (
                16 * new + old % 16 if cell % 2 == 0 else 16 * (old // 16) + new
            )
            self.assertEqual(d, [new, 1, cell, 1, new] + expected)
            d[3] = 0
            d[4] = 255
            self.assertEqual(m.packed(d)[:2], [new, 1])
            d[2] = cell ^ 1
            neighbor = m.packed(d)[0]
            self.assertEqual(neighbor, old % 16 if cell % 2 == 0 else old // 16)
        for index, value in [
            (2, -1),
            (2, 16),
            (2, 1.5),
            (3, 256),
            (4, 16),
            (5, -1),
            (12, 256),
        ]:
            d = [99, 99, 9, 1, 3] + m.BYTES
            d[index] = value
            self.assertEqual(m.packed(d), [0, 0] + d[2:])
        self.assertEqual(m.packed([99, 99, 0, 0, 255] + m.BYTES)[:2], [1, 1])
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
