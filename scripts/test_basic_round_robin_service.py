"""Native records, negative controls and independent service/data invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-services.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "round-robin-service"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for start in range(256):
            for mask in range(256):
                d = m.robin([99, 99, start, mask, 99])
                self.assertEqual(d[3:], [mask, 1])
                ready = [
                    (start + j) % 8 for j in range(8) if mask & (1 << ((start + j) % 8))
                ]
                self.assertEqual(
                    d[:3],
                    [ready[0], 1, (ready[0] + 1) % 8] if ready else [255, 0, start % 8],
                )
        for mask in range(1, 256):
            d = [0, 0, 7, mask, 0]
            actual = []
            for _ in range(mask.bit_count()):
                d = m.robin(d)
                actual.append(d[0])
            self.assertEqual(set(actual), {i for i in range(8) if mask & (1 << i)})
            self.assertEqual(len(set(actual)), len(actual))
        for index, value in [(2, -1), (2, 256), (2, 1.5), (3, -1), (3, 256), (3, 1.5)]:
            d = [99, 99, 7, 129, 99]
            d[index] = value
            self.assertEqual(m.robin(d), [255, 0] + d[2:4] + [0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(
                [d[0] for d in good],
                [7, 0, 7, 0, 7, 0] if custom else [0, 2, 4, 0, 2, 4],
            )
            self.assertEqual([d[0] for d in bad], [0] * 6)


if __name__ == "__main__":
    unittest.main()
