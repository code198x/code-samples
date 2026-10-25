"""Native records, altered evidence and independent snapshot/timing invariants."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-timelines.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "timed-status"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for period in [1, 2, 3, 255]:
            for phase in range(period):
                for remaining in range(256):
                    d = m.status([remaining, phase, 6, period, 0, 9, 9, 9])
                    self.assertEqual(d[6:], [1, 0])
                    self.assertEqual(d[0], max(0, remaining - 1))
                    self.assertEqual(d[5], int(remaining > 0 and phase + 1 == period))
                    self.assertEqual(d[1], (phase + 1) % period if remaining > 1 else 0)
        final = m.status([1, 1, 6, 2, 0, 9, 9, 9])
        self.assertEqual(final[:2], [0, 0])
        self.assertEqual(final[5], 1)
        cancel = m.status([99, 1, 0, 2, 1, 9, 9, 9])
        self.assertEqual(cancel[:2], [0, 0])
        self.assertEqual(cancel[5:], [0, 1, 0])
        invalid = [4, 2, 6, 2, 1, 9, 9, 9]
        out = m.status(invalid)
        self.assertEqual(out[:2], invalid[:2])
        self.assertEqual(out[5:], [0, 0, 1])
        for custom in [False, True]:
            good = m.clients(TOPIC, custom, False)
            bad = m.clients(TOPIC, custom, True)
            self.assertEqual(good[-1][0], 0)
            self.assertEqual(sum(d[5] for d in good), 1 if custom else 3)
            self.assertGreater(bad[-1][0], 0)
            self.assertEqual(sum(d[5] for d in bad), 0)
            self.assertEqual(good[0][0], 4 if custom else 5)


if __name__ == "__main__":
    unittest.main()
