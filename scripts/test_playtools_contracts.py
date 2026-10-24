"""Game-facing invariants beyond the native transport and retained records."""

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "contracts",
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/playtools-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)


def state(topic: str, **values: int) -> list[int]:
    return [values.get(f, 0) for f in M.TOPICS[topic]["fields"]]


class Contracts(unittest.TestCase):
    def test_fractional_steps_accumulate(self):
        v = state("fractional-position", POS_HI=100, VEL_LO=64)
        for _ in range(4):
            v = M.step("fractional-position", v)
        self.assertEqual(v[:2], [0, 101])
        self.assertEqual(
            M.step(
                "fractional-position",
                state("fractional-position", VEL_LO=255, VEL_HI=255),
            )[:2],
            [255, 255],
        )

    def test_signed_acceleration_uses_wide_sum(self):
        for velocity in (-32768, -32767, -1, 0, 1, 32767):
            for acceleration in (-32768, -1, 0, 1, 32767):
                for limit in (0, 1, 255, 32767):
                    v = M.step(
                        "bounded-acceleration",
                        state(
                            "bounded-acceleration",
                            VEL_LO=velocity % 256,
                            VEL_HI=(velocity % 65536) // 256,
                            ACC_LO=acceleration % 256,
                            ACC_HI=(acceleration % 65536) // 256,
                            LIMIT_LO=limit % 256,
                            LIMIT_HI=limit // 256,
                        ),
                    )
                    result = M.signed(v[0] + 256 * v[1])
                    self.assertTrue(-limit <= result <= limit)
                    self.assertEqual(
                        result, max(-limit, min(limit, velocity + acceleration))
                    )
        bad = state("bounded-acceleration", VEL_HI=255, LIMIT_HI=128)
        got = M.step("bounded-acceleration", bad)
        self.assertEqual(got[:2], bad[:2])
        self.assertEqual(got[-1], 0)

    def test_jump_buffer_expires(self):
        for custom, count in ((False, 1), (True, 0)):
            fields = M.TOPICS["jump-windows"]["fields"]
            v = [0] * len(fields)
            fired = 0
            for changes in M.trace("jump-windows", custom):
                for f, value in changes.items():
                    v[fields.index(f)] = value
                v = M.step("jump-windows", v, custom)
                fired += v[0]
            self.assertEqual(fired, count)
        # Last positive coyote call expires before testing; fresh ground reloads it.
        self.assertEqual(M.step("jump-windows", [0, 1, 2, 0, 0])[0], 0)
        self.assertEqual(M.step("jump-windows", [0, 2, 2, 0, 0])[0], 1)

    def test_platform_crossing_and_horizontal_touch(self):
        good = state(
            "one-way-platform",
            ACTOR_X=20,
            ACTOR_W=16,
            PREV_BOTTOM=90,
            NEW_BOTTOM=110,
            PLATFORM_X=10,
            PLATFORM_W=64,
            PLATFORM_Y=100,
        )
        self.assertEqual(M.step("one-way-platform", good)[:2], [1, 100])
        good[2] = 74
        self.assertEqual(M.step("one-way-platform", good)[0], 0)
        good[2], good[6] = 250, 250
        self.assertEqual(M.step("one-way-platform", good)[0], 1)

    def test_camera_clamps_and_preserves_invalid_input(self):
        for camera in (0, 40, 155):
            for player in range(256):
                v = M.step("camera-deadzone", [camera, player, 40, 80, 155, 255, 255])
                self.assertTrue(0 <= v[0] <= 155)
                self.assertEqual(v[-1], 1)
        self.assertEqual(
            M.step("camera-deadzone", [40, 100, 81, 80, 155, 255, 255]),
            [40, 100, 81, 80, 155, 0, 0],
        )

    def test_menu_never_selects_a_disabled_option(self):
        for count in range(1, 9):
            for enabled in range(256):
                for direction in (1, 255):
                    v = M.step(
                        "menu-navigation",
                        [count - 1, count, enabled, direction, 255, 255],
                    )
                    self.assertTrue(0 <= v[0] < count)
                    self.assertEqual(v[-1], 1)
                    if enabled & ((1 << count) - 1):
                        self.assertTrue(enabled & (1 << v[0]))
                    else:
                        self.assertEqual(v[0], count - 1)
                        self.assertEqual(v[4], 0)

    def test_text_capacity_and_empty_backspace(self):
        for custom, cap in ((False, 8), (True, 4)):
            v = state("text-entry-buffer", KEY=65)
            for _ in range(cap + 2):
                v = M.step("text-entry-buffer", v, custom)
            self.assertEqual(v[0], cap)
            self.assertEqual(v[1], 0)
            v[3] = 1
            for _ in range(cap + 2):
                v = M.step("text-entry-buffer", v, custom)
            self.assertEqual(v[0], 0)
            self.assertEqual(v[4:], [0] * 8)
        v = state("text-entry-buffer", LENGTH=255, MODE=2)
        self.assertEqual(M.step("text-entry-buffer", v)[0:2], [0, 1])

    def test_tile_bounds_and_any_bit_semantics(self):
        for tile in range(256):
            v = M.step("tile-properties", [255, 255, 255, tile, 255])
            self.assertEqual(v[2], int(tile < 16))
            if tile >= 16:
                self.assertEqual(v[:3], [0, 0, 0])
        self.assertEqual(M.step("tile-properties", [0, 0, 0, 6, 0])[0:3], [8, 0, 1])

    def test_rle_output_bounds_and_partial_prefix(self):
        for start in range(15):
            for end in range(15):
                for limit in range(10):
                    original = state(
                        "bounded-rle",
                        INPUT_START=start,
                        INPUT_END=end,
                        OUTPUT_LIMIT=limit,
                        **{f"BUF{i}": 90 for i in range(8)},
                    )
                    v = M.step("bounded-rle", original)
                    self.assertTrue(0 <= v[0] <= min(limit, 8))
                    self.assertEqual(v[5 + v[0] :], [90] * (8 - v[0]))
                    self.assertIn(v[1], range(5))
        v = M.step(
            "bounded-rle",
            state("bounded-rle", INPUT_START=0, INPUT_END=6, OUTPUT_LIMIT=5),
        )
        self.assertEqual(v[:2], [5, 4])
        self.assertEqual(v[5:10], [65, 65, 65, 66, 66])

    def test_crc_message_and_streaming_reset(self):
        for custom, expected in ((False, 0xF4), (True, 0xA2)):
            v = [0, 0]
            for byte in b"123456789":
                v[1] = byte
                v = M.step("streaming-crc8", v, custom)
            self.assertEqual(v[0], expected)
            fresh = M.step("streaming-crc8", [0, ord("9")], custom)
            self.assertNotEqual(fresh[0], v[0])


if __name__ == "__main__":
    unittest.main()
