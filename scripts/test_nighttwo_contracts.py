"""Gameplay invariants independent of the native instruction sequences."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "models",
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/nighttwo-models/cases.py",
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
    def test_ladder_suppresses_gravity_until_jump_or_contact_loss(self) -> None:
        state = call("ladder-controller", POSITION=10, MAXIMUM=20, ON_LADDER=1, UP=1)
        self.assertEqual((state["POSITION"], state["GRAVITY"]), (9, 0))
        same = call("ladder-controller", state, DOWN=1)
        self.assertEqual(same["POSITION"], 9)
        for values in [{"JUMP": 1}, {"ON_LADDER": 0}]:
            out = call("ladder-controller", state, **values)
            self.assertEqual((out["MODE"], out["GRAVITY"]), (0, 1))
        state = call("ladder-controller", POSITION=0, MAXIMUM=20, ON_LADDER=1, UP=1)
        self.assertEqual(state["POSITION"], 0)

    def test_transfer_conserves_items_and_never_overfills(self) -> None:
        for source in range(11):
            for dest in range(11):
                for request in [0, 1, 5, 255]:
                    out = call(
                        "inventory-transfer",
                        SOURCE_KIND=2 if source else 0,
                        SOURCE_COUNT=source,
                        DEST_KIND=2 if dest else 0,
                        DEST_COUNT=dest,
                        CAPACITY=10,
                        AMOUNT=request,
                    )
                    self.assertEqual(
                        out["SOURCE_COUNT"] + out["DEST_COUNT"], source + dest
                    )
                    self.assertLessEqual(out["DEST_COUNT"], 10)
                    self.assertEqual(out["MOVED"], min(source, 10 - dest, request))
        out = call(
            "inventory-transfer",
            SOURCE_KIND=1,
            SOURCE_COUNT=3,
            DEST_KIND=2,
            DEST_COUNT=2,
            CAPACITY=10,
            AMOUNT=3,
        )
        self.assertEqual(
            (out["SOURCE_COUNT"], out["DEST_COUNT"], out["MOVED"]), (3, 2, 0)
        )

    def test_aim_signs_dominant_speed_and_coincident_target(self) -> None:
        signed = lambda v: v if v < 128 else v - 256
        for dx in [-128, -127, -1, 0, 1, 126, 127]:
            for dy in [-128, -1, 0, 1, 127]:
                for speed in range(16):
                    out = call(
                        "aimed-projectile",
                        ORIGIN_X=128,
                        ORIGIN_Y=128,
                        TARGET_X=128 + dx,
                        TARGET_Y=128 + dy,
                        SPEED=speed,
                    )
                    vx, vy = signed(out["VELOCITY_X"]), signed(out["VELOCITY_Y"])
                    self.assertEqual(max(abs(vx), abs(vy)), speed if dx or dy else 0)
                    self.assertGreaterEqual(vx * dx, 0)
                    self.assertGreaterEqual(vy * dy, 0)
                    if abs(dx) == abs(dy):
                        self.assertEqual(abs(vx), abs(vy))

    def test_attack_only_once_per_target_and_end_is_exclusive(self) -> None:
        state = call(
            "attack-hit-window",
            START_FRAME=2,
            END_FRAME=4,
            FRAME=2,
            TARGET=7,
            CONTACT=1,
            NEW_ATTACK=1,
        )
        self.assertEqual(state["HIT"], 1)
        self.assertEqual(call("attack-hit-window", state, NEW_ATTACK=0)["HIT"], 0)
        self.assertEqual(
            call("attack-hit-window", state, NEW_ATTACK=0, TARGET=0)["HIT"], 1
        )
        self.assertEqual(
            call("attack-hit-window", state, NEW_ATTACK=1, FRAME=4)["HIT"], 0
        )
        self.assertEqual(
            call("attack-hit-window", state, NEW_ATTACK=1, FRAME=2)["HIT"], 1
        )

    def test_focus_margin_and_range_have_separate_boundaries(self) -> None:
        for nearest in [0, 1, 10, 253, 254, 255]:
            for margin in [0, 1, 2, 255]:
                current = min(255, nearest + 2)
                out = call(
                    "interaction-focus",
                    CURRENT=1,
                    ACTIVE=3,
                    RANGE=255,
                    MARGIN=margin,
                    D0=nearest,
                    D1=current,
                )
                self.assertEqual(
                    out["SELECTED"], 1 if current - nearest <= margin else 0
                )
        self.assertEqual(
            call(
                "interaction-focus",
                CURRENT=1,
                ACTIVE=3,
                RANGE=9,
                MARGIN=255,
                D0=9,
                D1=10,
            )["SELECTED"],
            0,
        )

    def test_menu_window_contains_selection_without_overflow(self) -> None:
        for count in [1, 2, 20, 254, 255]:
            for page in [1, 4, 8, 255]:
                for selected in [0, count // 2, count - 1]:
                    for top in [0, 128, 255]:
                        out = call(
                            "menu-page-window",
                            ITEM_COUNT=count,
                            PAGE_ROWS=page,
                            SELECTED=selected,
                            TOP=top,
                        )
                        self.assertLessEqual(out["TOP"], selected)
                        self.assertLess(selected, out["TOP"] + out["VISIBLE"])
                        self.assertEqual(out["ROW"], selected - out["TOP"])
                        self.assertLessEqual(out["TOP"] + out["VISIBLE"], count)

    def test_text_reveals_at_interval_and_skip_completes(self) -> None:
        state = call("typewriter-text", LENGTH=3, INTERVAL=2)
        for expected in [1, 1, 2, 2, 3, 3, 3]:
            state = call("typewriter-text", state)
            self.assertEqual(state["REVEALED"], expected)
        self.assertEqual(state["ADDED"], 0)
        self.assertEqual(state["DONE"], 1)
        state = call("typewriter-text", LENGTH=255, INTERVAL=255, SKIP=1)
        self.assertEqual(
            (state["REVEALED"], state["ADDED"], state["DONE"]), (255, 255, 1)
        )

    def test_music_holds_then_stops_once_and_rejects_bad_pair(self) -> None:
        state = call("music-command-stream", COUNT=2, N0=40, U0=2, N1=0, U1=1)
        events = [(state["EVENT"], state["NOTE"])]
        for _ in range(4):
            state = call("music-command-stream", state)
            events.append((state["EVENT"], state["NOTE"]))
        self.assertEqual(events, [(1, 40), (0, 40), (1, 0), (2, 0), (0, 0)])
        for note, duration in [(96, 1), (1, 0)]:
            bad = call("music-command-stream", COUNT=1, N0=note, U0=duration)
            self.assertEqual((bad["VALID"], bad["INDEX"], bad["EVENT"]), (0, 0, 0))

    def test_save_rejection_is_atomic_and_single_byte_changes_fail(self) -> None:
        record = [198, 1, 4, 7, 20, 3, 2, 209]
        values = {f"C{i}": v for i, v in enumerate(record)}
        valid = call("save-record-validation", MODE=1, **values)
        self.assertEqual([valid[f"L{i}"] for i in range(4)], record[3:7])
        for index in range(8):
            for bit in range(8):
                bad = values.copy()
                bad[f"C{index}"] ^= 1 << bit
                out = call(
                    "save-record-validation", MODE=1, L0=9, L1=8, L2=7, L3=6, **bad
                )
                self.assertEqual(out["ACCEPTED"], 0)
                self.assertEqual([out[f"L{i}"] for i in range(4)], [9, 8, 7, 6])
        out = call("save-record-validation", MODE=0, L0=9, **values)
        self.assertEqual((out["ACCEPTED"], out["L0"]), (1, 9))

    def test_deferred_objects_keep_traversal_stable_and_reject_stale_handles(
        self,
    ) -> None:
        state = call("object-command-buffer", MODE=1, SLOT=2)
        self.assertEqual((state["ACTIVE"], state["COUNT"]), (0, 1))
        state = call("object-command-buffer", state, MODE=3)
        self.assertEqual((state["ACTIVE"], state["G2"], state["APPLIED"]), (4, 1, 1))
        state = call("object-command-buffer", state, MODE=2, SLOT=2, GENERATION=0)
        self.assertEqual(state["ACTIVE"], 4)
        state = call("object-command-buffer", state, MODE=3)
        self.assertEqual((state["ACTIVE"], state["REJECTED"]), (4, 1))
        for _ in range(5):
            state = call("object-command-buffer", state, MODE=1, SLOT=0)
        self.assertEqual((state["COUNT"], state["FULL"]), (4, 1))
        bad = call("object-command-buffer", state, MODE=3, O3=3)
        self.assertEqual((bad["VALID"], bad["ACTIVE"], bad["COUNT"]), (0, 4, 4))


if __name__ == "__main__":
    unittest.main()
