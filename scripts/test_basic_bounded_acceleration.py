"""Native observations, rejection controls and independent mask/motion invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-motion.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "bounded-acceleration"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        values = [
            -32768,
            -32767,
            -513,
            -512,
            -128,
            -1,
            0,
            1,
            128,
            512,
            513,
            32766,
            32767,
        ]
        for velocity, accel, limit in itertools.product(
            values, values, [0, 1, 128, 256, 512, 32767]
        ):
            before = m.word(velocity) + m.word(accel) + m.word(limit) + [99, 99]
            d = m.acceleration(before)
            expected = max(-limit, min(limit, velocity + accel))
            self.assertEqual(m.signed(d[0] + 256 * d[1]), expected)
            self.assertEqual(d[2:6], before[2:6])
            self.assertEqual(d[6:], [int(expected != velocity + accel), 1])
        self.assertEqual(
            m.acceleration(m.word(32767) + m.word(32767) + m.word(32767) + [99, 99])[
                :2
            ],
            [255, 127],
        )
        self.assertEqual(
            m.acceleration(m.word(-32768) + m.word(-32768) + m.word(32767) + [99, 99])[
                :2
            ],
            [1, 128],
        )
        for index, value in [
            (0, -1),
            (1, 256),
            (2, 1.5),
            (3, -1),
            (4, 256),
            (5, 128),
            (5, 255),
            (5, 1.5),
        ]:
            d = [0, 0, 128, 255, 0, 2, 99, 99]
            d[index] = value
            self.assertEqual(m.acceleration(d), d[:6] + [0, 0])
        for custom in [False, True]:
            good, c = m.clients(TOPIC, custom, False)
            bad, b = m.clients(TOPIC, custom, True)
            self.assertEqual(c, [1, 1])
            self.assertEqual(b, [0, 0])
            self.assertEqual(good[3][:2], [0, 255 if custom else 254])
            self.assertEqual(good[3][6], 1 if custom else 0)
            self.assertEqual(good[4][6:], [1, 1])
            self.assertEqual(good[5][:2], good[4][:2])
            self.assertEqual(good[5][6:], [0, 0])
            self.assertEqual(good[6][:2], [0, 0])
            self.assertNotEqual(good[3][:2], bad[3][:2])


if __name__ == "__main__":
    unittest.main()
