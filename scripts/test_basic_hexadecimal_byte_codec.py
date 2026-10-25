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
TOPIC = "hexadecimal-byte-codec"


class Contract(unittest.TestCase):
    def test_native_evidence_and_rejections(self) -> None:
        C.select(TOPIC)
        C.qualify()

    def test_independent_invariants(self) -> None:
        C.select(TOPIC)
        m = C.M.M
        for value, case in itertools.product(range(256), [0, 1, 255]):
            d = m.codec([value, 99, 99, case, 0, 99])
            digits = "0123456789abcdef" if case else "0123456789ABCDEF"
            self.assertEqual(
                d,
                [value, ord(digits[value // 16]), ord(digits[value % 16]), case, 0, 1],
            )
            d[4] = 1
            parsed = m.codec(d)
            self.assertEqual(parsed, [value, d[1], d[2], case, 1, 1])
        alphabet = {ord(c): i for i, c in enumerate("0123456789ABCDEF")}
        alphabet.update({ord(c.lower()): i for i, c in enumerate("0123456789ABCDEF")})
        for first, second in itertools.product(range(256), repeat=2):
            d = m.codec([199, first, second, 255, 1, 99])
            valid = first in alphabet and second in alphabet
            self.assertEqual(
                d,
                [
                    16 * alphabet[first] + alphabet[second] if valid else 0,
                    first,
                    second,
                    255,
                    1,
                    int(valid),
                ],
            )
        self.assertEqual(m.codec([165.0, 0, 0, 1.0, 0, 99]), [165, 97, 53, 1, 0, 1])
        self.assertEqual(m.codec([0, 65.0, 53.0, 0, 1, 99]), [165, 65, 53, 0, 1, 1])
        for value, case in [
            (-1, 0),
            (256, 0),
            (1.5, 0),
            (165, -1),
            (165, 256),
            (165, 1.5),
        ]:
            self.assertEqual(
                m.codec([value, 99, 99, case, 0, 99]), [value, 0, 0, case, 0, 0]
            )
        self.assertEqual(m.codec([165, 65, 53, 0, 2, 99]), [165, 65, 53, 0, 2, 0])
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
