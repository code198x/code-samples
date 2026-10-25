"""Native evidence, rejection controls and independent decision/codec invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-decisions.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "bitset-slot-allocation"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for used, mode, request in itertools.product(
            range(256), [0, 1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 255]
        ):
            d = m.slots([99, 99, 99, used, mode, request])
            self.assertEqual(d[4:], [mode, request])
            occupied = {i for i in range(8) if used & (1 << i)}
            if mode == 1 and request > 7:
                self.assertEqual(d, [255, 0, 0, used, mode, request])
                continue
            free = [i for i in range(8) if i not in occupied]
            if mode == 0 and free:
                chosen = free[0]
                expected = used + 2**chosen
                success = 1
            elif mode == 1 and request in occupied:
                chosen = request
                expected = used - 2**chosen
                success = 1
            else:
                chosen = 255
                expected = used
                success = 0
            self.assertEqual(d[:4], [chosen, success, 1, expected])
        for index, value in [(3, -1), (3, 256), (3, 1.5), (4, 2), (5, -1), (5, 256)]:
            d = [99, 99, 99, 3, 0, 0]
            d[index] = value
            self.assertEqual(m.slots(d), [255, 0, 0] + d[3:])
        self.assertEqual(m.slots([99, 99, 99, 3.0, 0, 0])[:4], [2, 1, 1, 7])
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
