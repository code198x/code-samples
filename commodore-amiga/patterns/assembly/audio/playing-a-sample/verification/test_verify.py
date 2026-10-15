"""Independent cycle-count controls for the one-shot observer."""
import math
import unittest

from verify import count_cycles

CYCLE = 92


def burst(cycles, tail=False):
    samples = [round(20000 * math.sin(2 * math.pi * i / CYCLE))
               for i in range(cycles * CYCLE)]
    samples.extend(round(3500 * math.exp(-i / (10 * CYCLE))) if tail else 0
                   for i in range((42 - cycles) * CYCLE))
    return samples


class CycleCountTests(unittest.TestCase):
    def test_eight_cycles_with_or_without_filter_decay(self):
        for tail in (False, True):
            with self.subTest(tail=tail):
                self.assertEqual(count_cycles(burst(8, tail), 0, CYCLE), 8)

    def test_missing_extra_and_continuing_cycles_are_distinguished(self):
        for cycles in (7, 9, 40):
            with self.subTest(cycles=cycles):
                measured = count_cycles(burst(cycles, True), 0, CYCLE)
                self.assertEqual(measured, cycles)
                self.assertNotEqual(measured, 8)

    def test_dc_or_decay_alone_is_not_a_cycle(self):
        self.assertEqual(count_cycles([20000] * (42 * CYCLE), 0, CYCLE), 0)
        decay = [round(20000 * math.exp(-i / CYCLE)) for i in range(42 * CYCLE)]
        self.assertEqual(count_cycles(decay, 0, CYCLE), 0)


if __name__ == '__main__':
    unittest.main()
