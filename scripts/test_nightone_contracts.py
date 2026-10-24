"""Behaviour invariants and transactions independent of native instruction sequences."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "models",
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/nightone-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)


def call(
    topic: str, state: dict[str, int] | None = None, **values: int
) -> dict[str, int]:
    fields = M.TOPICS[topic]["fields"]
    d = dict.fromkeys(fields, 0) | (state or {}) | values
    return dict(zip(fields, M.step(topic, [d[k] for k in fields]), strict=True))


class Contracts(unittest.TestCase):
    def test_layers_are_symmetric_and_need_both_permissions(self) -> None:
        for a in [0, 1, 2, 3, 128, 255]:
            for b in [0, 1, 2, 3, 128, 255]:
                for mask in range(256):
                    x = call(
                        "collision-layer-filter",
                        GROUP_A=a,
                        GROUP_B=b,
                        MASK_A=mask,
                        MASK_B=255,
                        SOLID_A=1,
                        SOLID_B=0,
                    )
                    y = call(
                        "collision-layer-filter",
                        GROUP_A=b,
                        GROUP_B=a,
                        MASK_B=mask,
                        MASK_A=255,
                        SOLID_A=0,
                        SOLID_B=1,
                    )
                    self.assertEqual(x["PAIR_KIND"], y["PAIR_KIND"])
                    self.assertLessEqual(x["PAIR_KIND"], 1)
        self.assertEqual(
            call(
                "collision-layer-filter",
                GROUP_A=1,
                GROUP_B=2,
                MASK_A=2,
                MASK_B=0,
                SOLID_A=1,
                SOLID_B=1,
            )["PAIR_KIND"],
            0,
        )

    def test_buffered_turn_waits_for_junction_and_cannot_wrap(self) -> None:
        state = call("grid-turn-buffer", CELL=8, DIRECTION=2, REQUEST=3, C4=1)
        self.assertEqual((state["CELL"], state["PENDING"]), (9, 3))
        state = call("grid-turn-buffer", state, REQUEST=0)
        self.assertEqual(
            (state["CELL"], state["DIRECTION"], state["PENDING"]), (5, 3, 0)
        )
        for cell in [3, 7, 11, 15]:
            self.assertFalse(call("grid-turn-buffer", CELL=cell, DIRECTION=2)["MOVED"])

    def test_push_failure_is_atomic_and_success_preserves_crate_count(self) -> None:
        for beyond in [0, 1, 2, 255]:
            before = {"CELL": 4, "REQUEST": 2, "C5": 2, "C6": beyond}
            after = call("push-block-transaction", **before)
            if beyond == 0:
                self.assertEqual(
                    (after["CELL"], after["C5"], after["C6"], after["RESULT"]),
                    (5, 0, 2, 2),
                )
            else:
                self.assertEqual(
                    (after["CELL"], after["C5"], after["C6"], after["RESULT"]),
                    (4, 2, beyond, 0),
                )
        self.assertEqual(
            call("push-block-transaction", CELL=7, REQUEST=2, C8=2)["CELL"], 7
        )

    def test_spatial_bucket_reports_overflow_without_erasing_candidates(self) -> None:
        state = None
        for item in [5, 6, 7, 8]:
            state = call(
                "spatial-bucket", state, MODE=1, INPUT_X=15, INPUT_Y=15, ITEM=item
            )
        state = call("spatial-bucket", state, MODE=1, ITEM=9)
        self.assertEqual((state["INSERTED"], state["FULL"], state["COUNT"]), (0, 1, 4))
        self.assertEqual([state[f"S{i}"] for i in range(12, 16)], [5, 6, 7, 8])
        state = call("spatial-bucket", state, MODE=0)
        self.assertTrue(all(state[f"C{i}"] == 0 for i in range(4)))

    def test_contact_pair_order_and_frame_reset(self) -> None:
        for a in range(8):
            for b in range(a + 1, 8):
                state = call("contact-pair-cache", MODE=1, OBJECT_A=a, OBJECT_B=b)
                self.assertEqual(state["FIRST"], 1)
                state = call("contact-pair-cache", state, OBJECT_A=b, OBJECT_B=a)
                self.assertEqual(state["FIRST"], 0)
                state = call("contact-pair-cache", state, MODE=0)
                self.assertEqual(call("contact-pair-cache", state, MODE=1)["FIRST"], 1)

    def test_platform_carry_preserves_relative_coordinate_until_clamp(self) -> None:
        for old in range(0, 256, 17):
            for new in range(0, 256, 17):
                d = call(
                    "moving-platform-carry",
                    PASSENGER=128,
                    PLATFORM_OLD=old,
                    PLATFORM_NEW=new,
                    SUPPORTED=1,
                    MINIMUM=0,
                    MAXIMUM=255,
                )
                if not d["CLAMPED"]:
                    self.assertEqual(d["POSITION"] - new, 128 - old)
                self.assertEqual(
                    call(
                        "moving-platform-carry",
                        PASSENGER=128,
                        PLATFORM_OLD=old,
                        PLATFORM_NEW=new,
                        SUPPORTED=0,
                        MINIMUM=0,
                        MAXIMUM=255,
                    )["POSITION"],
                    128,
                )

    def test_shake_is_bounded_and_expires_without_world_mutation(self) -> None:
        for strength in range(16):
            state = call(
                "camera-shake",
                TRIGGER=1,
                STRENGTH=strength,
                DURATION=3,
                NOISE_X=255,
                NOISE_Y=0,
            )
            for remaining in [2, 1, 0]:
                self.assertEqual(state["REMAINING"], remaining)
                for key in ["OFFSET_X", "OFFSET_Y"]:
                    value = state[key] if state[key] < 128 else state[key] - 256
                    self.assertLessEqual(abs(value), strength)
                state = call("camera-shake", state, TRIGGER=0)
            self.assertEqual((state["OFFSET_X"], state["OFFSET_Y"]), (0, 0))

    def test_moving_solid_pushes_to_contact_or_reports_blocked(self) -> None:
        for destination in range(8, 31):
            d = call(
                "moving-solid-push",
                ACTOR_POSITION=10,
                ACTOR_SIZE=2,
                SOLID_OLD=0,
                SOLID_NEW=destination,
                SOLID_SIZE=2,
                MINIMUM=0,
                MAXIMUM=20,
            )
            if destination == 8:
                self.assertEqual((d["POSITION"], d["PUSHED"]), (10, 0))
            elif destination + 2 <= 20:
                self.assertEqual((d["POSITION"], d["PUSHED"]), (destination + 2, 1))
            else:
                self.assertEqual((d["POSITION"], d["BLOCKED"]), (10, 1))

    def test_world_projection_survives_byte_boundaries_and_excludes_far_edge(
        self,
    ) -> None:
        for camera in [0, 250, 255, 256, 32768, 65500]:
            for offset in [-1, 0, 1, 31, 32, 255]:
                world = camera + offset
                if not 0 <= world <= 65535:
                    continue
                d = call(
                    "viewport-world-transform",
                    WORLD_X_LO=world % 256,
                    WORLD_X_HI=world // 256,
                    CAMERA_X_LO=camera % 256,
                    CAMERA_X_HI=camera // 256,
                    WIDTH=32,
                    HEIGHT=24,
                )
                self.assertEqual(bool(d["VISIBLE"]), 0 <= offset < 32)
                if d["VISIBLE"]:
                    self.assertEqual(d["SCREEN_X"], offset)

    def test_restitution_does_not_increase_normal_speed_or_change_tangent(self) -> None:
        for speed in range(256):
            for coefficient in range(5):
                d = call(
                    "surface-response",
                    NORMAL_IN=speed,
                    DIRECTION_IN=1,
                    TANGENT_IN=128,
                    RESTITUTION=coefficient,
                )
                self.assertLessEqual(d["NORMAL_OUT"], speed)
                self.assertEqual((d["TANGENT_OUT"], d["DIRECTION_OUT"]), (128, 0))
                if coefficient == 4:
                    self.assertEqual(d["NORMAL_OUT"], speed)
                if coefficient == 0:
                    self.assertEqual(d["NORMAL_OUT"], 0)


if __name__ == "__main__":
    unittest.main()
