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
TOPIC = "text-entry-buffer"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for cap in [1, 4, 8]:
            for events in itertools.product(
                [(65, 0), (66, 0), (0, 1), (0, 2), (31, 0)], repeat=5
            ):
                d = [0, 0, 0, 0, cap] + [0] * 8
                live = []
                for key, mode in events:
                    status = 0
                    if mode == 2:
                        live = []
                        status = 1
                    elif mode == 1:
                        if live:
                            live.pop()
                            status = 1
                    elif key < 32 or key > 126:
                        status = 2
                    elif len(live) < cap:
                        live.append(key)
                        status = 1
                    d[2:4] = [key, mode]
                    d = m.text(d)
                    self.assertEqual(d[:5], [len(live), status, key, mode, cap])
                    self.assertEqual(d[5:], live + [0] * (8 - len(live)))
        for length, data in [(255, [255] * 8), (-1, [-1] * 8), (1.5, [256] * 8)]:
            self.assertEqual(
                m.text([length, 99, 255, 2, 4] + data), [0, 1, 255, 2, 4] + [0] * 8
            )
        for index, value in [
            (0, 9),
            (0, 1.5),
            (3, 3),
            (4, 0),
            (4, 9),
            (5, -1),
            (12, 256),
        ]:
            d = [0, 99, 65, 0, 8] + [0] * 8
            d[index] = value
            expected = list(d)
            expected[1] = 3
            self.assertEqual(m.text(d), expected)
        before = [1, 99, 66, 0, 8] + [65] + [7] * 7
        out = m.text(before)
        self.assertEqual(out, [2, 1, 66, 0, 8, 65, 66] + [7] * 6)
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
