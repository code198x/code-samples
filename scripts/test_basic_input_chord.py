"""Native records, rejection controls and independent logical-input invariants."""

from __future__ import annotations

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gate", Path(__file__).with_name("check-basic-input-models.py")
)
C = importlib.util.module_from_spec(s)
s.loader.exec_module(C)
TOPIC = "input-chord"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for held, required, forbidden, previous in itertools.product(
            range(256), [0, 1, 3, 128, 129, 255], [0, 2, 4, 127, 255], [0, 1]
        ):
            d = m.chord([previous, held, required, forbidden, 99, 99, 99])
            self.assertEqual(d[1:4], [held, required, forbidden])
            if not required or required & forbidden:
                self.assertEqual(d, [0, held, required, forbidden, 0, 0, 0])
                continue
            active = int((held & required) == required and (held & forbidden) == 0)
            self.assertEqual(d[0], active)
            self.assertEqual(d[4:], [active, int(active and not previous), 1])
        for index, value in [
            (0, 2),
            (0, 1.5),
            (1, -1),
            (1, 256),
            (2, -1),
            (2, 1.5),
            (3, 256),
        ]:
            d = [1, 3, 3, 4, 99, 99, 99]
            d[index] = value
            self.assertEqual(m.chord(d), [0] + d[1:4] + [0, 0, 0])
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
