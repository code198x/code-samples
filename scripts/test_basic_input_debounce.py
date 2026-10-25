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
TOPIC = "input-debounce"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for threshold in [0, 1, 2, 3, 255]:
            for events in itertools.product([0, 1, 255], repeat=6):
                d = [0, 0, 0, 0, 0, threshold, 0]
                history = []
                stable = candidate = run = 0
                for raw in events:
                    pulse = 0
                    if not threshold:
                        history = []
                        run = 0
                    else:
                        history.append(raw)
                        candidate = raw
                        run = 0
                        for old in reversed(history):
                            if old != raw:
                                break
                            run += 1
                        run = min(255, run)
                        if run >= threshold and stable != candidate:
                            stable = candidate
                            pulse = 1
                    d[4] = raw
                    d = m.debounce(d)
                    self.assertEqual(
                        d, [stable, pulse, candidate, run, raw, threshold, 1]
                    )
        self.assertEqual(
            m.debounce([0, 99, 1, 255, 1, 255, 99]), [1, 1, 1, 255, 1, 255, 1]
        )
        self.assertEqual(m.debounce([5, 99, 7, 12, 9, 0, 99]), [5, 0, 7, 0, 9, 0, 1])
        for index, value in [
            (0, -1),
            (0, 256),
            (2, 1.5),
            (3, -1),
            (3, 256),
            (4, 1.5),
            (5, 256),
        ]:
            d = [0, 99, 1, 2, 1, 3, 99]
            d[index] = value
            expected = list(d)
            expected[1] = expected[6] = 0
            self.assertEqual(m.debounce(d), expected)
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
