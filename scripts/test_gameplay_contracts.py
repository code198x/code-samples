"""Cross-check game-facing invariants independently of native byte paths."""

import importlib.util
import itertools
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "contracts",
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/gameplay-patterns/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)


class Contracts(unittest.TestCase):
    def test_wallet_conservation(self):
        for value in range(256):
            for amount in (0, 1, value, 255):
                result = M.step("resource-wallet", [value, amount, 1, 255])
                self.assertEqual(result[0] + (amount if result[3] else 0), value)
                self.assertEqual(bool(result[3]), amount <= value)

    def test_queue_order_and_rejection(self):
        for custom, capacity in ((False, 4), (True, 2)):
            state = [0] * 10
            for value in range(capacity + 1):
                state[3:5] = [value + 17, 1]
                before = state.copy()
                state = M.step("event-queue", state, custom)
                self.assertEqual(state[5], int(value < capacity))
                if value == capacity:
                    self.assertEqual(state[:3] + state[6:], before[:3] + before[6:])
            got = []
            for _ in range(capacity + 1):
                state[4] = 2
                state = M.step("event-queue", state, custom)
                if state[5]:
                    got.append(state[3])
            self.assertEqual(got, list(range(17, 17 + capacity)))

    def test_approach_monotonicity(self):
        for position, target, speed in itertools.product((0, 1, 127, 255), repeat=3):
            result = M.step("approach-target", [position, target, speed, 255])
            self.assertLessEqual(abs(result[0] - position), speed)
            self.assertLessEqual(abs(result[0] - target), abs(position - target))
            self.assertTrue(min(position, target) <= result[0] <= max(position, target))
            self.assertEqual(bool(result[3]), result[0] == target)

    def test_patrol_stays_in_range(self):
        for low, high in ((0, 0), (0, 1), (0, 255), (127, 255)):
            state = [low, low, high, 255]
            for _ in range(1024):
                state = M.step("endpoint-patrol", state)
                self.assertTrue(low <= state[0] <= high)
                self.assertIn(state[3], (0, 1))

    def test_decimal_round_trip(self):
        for value in range(65536):
            result = M.step("decimal-format", [value % 256, value // 256] + [255] * 7)
            self.assertEqual(int(bytes(result[2:7])), value)
            self.assertEqual(result[:2], [value % 256, value // 256])

    def test_distance_symmetry_and_corners(self):
        for ax, ay, bx, by in itertools.product((0, 127, 255), repeat=4):
            forward = M.step("manhattan-distance", [ax, ay, bx, by, 255, 255])
            reverse = M.step("manhattan-distance", [bx, by, ax, ay, 255, 255])
            self.assertEqual(forward[4:6], reverse[4:6])
            self.assertTrue(0 <= forward[4] + 256 * forward[5] <= 510)
        self.assertEqual(
            M.step("manhattan-distance", [0, 0, 255, 255, 0, 0])[4:], [254, 1]
        )

    def test_repeat_timeline(self):
        for custom, expected in ((False, [0, 4, 6]), (True, [0, 6])):
            state = [0] * 4
            pulses = []
            for tick in range(8):
                state[0] = 255
                state = M.step("input-repeat", state, custom)
                if state[3]:
                    pulses.append(tick)
            self.assertEqual(pulses, expected)
            state[0] = 0
            self.assertEqual(M.step("input-repeat", state, custom), [0, 0, 0, 0])

    def test_arbiter_highest_and_first_tie(self):
        requests = [(7, 8), (9, 8), (5, 2), (0, 0)]
        for ordering in itertools.permutations(requests):
            state = [0] * 6
            for request_id, priority in ordering:
                state[3:5] = [request_id, priority]
                state = M.step("priority-arbiter", state)
            expected = next(
                request_id for request_id, priority in ordering if priority == 8
            )
            self.assertEqual(state[:3], [1, expected, 8])

    def test_flags_preserve_unselected_bits(self):
        for value in range(256):
            for mask in (0, 1, 3, 8, 128, 255):
                for mode in (0, 1, 2, 255):
                    result = M.step("quest-flags", [value, mask, mode, 255])
                    self.assertEqual(result[0] & (255 - mask), value & (255 - mask))
                    self.assertEqual(result[1:3], [mask, mode])

    def test_score_boundaries(self):
        for custom, cap in ((False, 65535), (True, 999)):
            for current in (0, 1, cap - 1, cap):
                for award in (0, 1, 255, 256, 65535):
                    s = [current % 256, current // 256, award % 256, award // 256, 255]
                    result = M.step("score-counter", s, custom)
                    self.assertEqual(
                        result[0] + 256 * result[1], min(cap, current + award)
                    )
                    self.assertEqual(result[4], int(current + award > cap))


if __name__ == "__main__":
    unittest.main()
