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
TOPIC = "menu-navigation"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for count in range(1, 9):
            for selected, enabled, delta in itertools.product(
                range(count), range(256), [0, 1, 255]
            ):
                d = m.menu([selected, count, enabled, delta, 99, 99])
                choices = {i for i in range(count) if enabled & (1 << i)}
                if not choices or not delta:
                    expected = selected
                else:

                    def distance(
                        i: int,
                        start: int = selected,
                        size: int = count,
                        request: int = delta,
                    ) -> int:
                        n = (i - start) % size if request == 1 else (start - i) % size
                        return n or size

                    expected = min(choices, key=distance)
                self.assertEqual(
                    d, [expected, count, enabled, delta, int(expected != selected), 1]
                )
        for index, value in [
            (0, -1),
            (0, 3),
            (0, 1.5),
            (1, 0),
            (1, 9),
            (2, 256),
            (3, 2),
        ]:
            d = [2, 3, 5, 1, 99, 99]
            d[index] = value
            self.assertEqual(m.menu(d), d[:4] + [0, 0])
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
