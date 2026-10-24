"""Cross-operation and boundary invariants for the toolkit contracts."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "models",
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/toolkit-models/cases.py",
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
    def test_signed_order_antisymmetric(self) -> None:
        for a in range(256):
            for b in [0, 127, 128, 255]:
                x = call("signed-byte-order", LEFT=a, RIGHT=b)
                y = call("signed-byte-order", LEFT=b, RIGHT=a)
                self.assertEqual(x["ORDER"] + y["ORDER"], 2)
                self.assertEqual(x["ORDER"] == 1, a == b)

    def test_saturation_commutes_and_never_decreases(self) -> None:
        for a in [0, 1, 255, 256, 32768, 65535]:
            for b in [0, 1, 255, 256, 65535]:
                x = call(
                    "saturating-word-add",
                    LEFT_LO=a % 256,
                    LEFT_HI=a // 256,
                    RIGHT_LO=b % 256,
                    RIGHT_HI=b // 256,
                )
                y = call(
                    "saturating-word-add",
                    LEFT_LO=b % 256,
                    LEFT_HI=b // 256,
                    RIGHT_LO=a % 256,
                    RIGHT_HI=a // 256,
                )
                result = x["SUM_LO"] + 256 * x["SUM_HI"]
                self.assertGreaterEqual(result, max(a, b))
                self.assertEqual((x["SUM_LO"], x["SUM_HI"]), (y["SUM_LO"], y["SUM_HI"]))

    def test_hex_roundtrip(self) -> None:
        for value in range(256):
            for lower in [0, 1]:
                a = call("hexadecimal-format", VALUE=value, LOWERCASE=lower)
                b = call(
                    "hexadecimal-parser", FIRST=a["HIGH_CHAR"], SECOND=a["LOW_CHAR"]
                )
                self.assertEqual((b["VALID"], b["VALUE"]), (1, value))

    def test_hex_rejects_non_ascii_and_punctuation(self) -> None:
        for char in range(256):
            d = call("hexadecimal-parser", FIRST=char, SECOND=48)
            self.assertEqual(bool(d["VALID"]), chr(char) in "0123456789abcdefABCDEF")

    def test_bit_writer_preserves_untouched_bits(self) -> None:
        for start in range(33):
            for count in range(9):
                d = call(
                    "bounded-bit-writer",
                    CURSOR=start,
                    COUNT=count,
                    VALUE=0,
                    B0=255,
                    B1=255,
                    B2=255,
                    B3=255,
                )
                bits = "".join(format(d[f"B{i}"], "08b") for i in range(4))
                self.assertEqual(
                    bits,
                    "1" * start + "0" * count + "1" * (32 - start - count)
                    if start + count <= 32
                    else "1" * 32,
                )

    def test_slot_allocator_fills_and_releases(self) -> None:
        state = None
        for slot in range(8):
            state = call("bitset-slot-allocation", state)
            self.assertEqual(state["SLOT"], slot)
        self.assertEqual(call("bitset-slot-allocation", state)["RESULT"], 0)
        state = call("bitset-slot-allocation", state, MODE=1, REQUEST=3)
        self.assertEqual(call("bitset-slot-allocation", state, MODE=0)["SLOT"], 3)

    def test_priority_equal_order_is_fifo(self) -> None:
        state = None
        for event in [9, 3, 7, 1]:
            state = call("priority-event-queue", state, NEW_EVENT=event, NEW_PRIORITY=8)
        events = []
        for _ in range(4):
            state = call("priority-event-queue", state, MODE=1)
            events.append(state["EVENT"])
        self.assertEqual(events, [9, 3, 7, 1])

    def test_scores_preserve_ties_and_drop_worst(self) -> None:
        state = None
        for score, tag in [(10, 1), (20, 2), (20, 3), (5, 4), (15, 5)]:
            state = call("high-score-insertion", state, SCORE=score, TAG=tag)
        self.assertEqual([state[f"S{i}"] for i in range(4)], [20, 20, 15, 10])
        self.assertEqual([state[f"I{i}"] for i in range(4)], [2, 3, 5, 1])

    def test_dictionary_first_duplicate_and_zero(self) -> None:
        d = call("dictionary-lookup", COUNT=2, K0=255, K1=255, Q0=0, Q1=4, KEY=255)
        self.assertEqual((d["FOUND"], d["VALUE"]), (1, 0))
        self.assertFalse(call("dictionary-lookup", d, KEY=3)["FOUND"])

    def test_wrap_makes_progress_and_keeps_words(self) -> None:
        state = dict(
            COUNT=16, WIDTH=5, **{f"C{i}": v for i, v in enumerate(b"ONE TWO THREE   ")}
        )
        lines = []
        while state.get("START", 0) < 16:
            d = call("bounded-text-wrap", state)
            self.assertGreater(d["NEXT"], state.get("START", 0))
            lines.append(
                bytes(d[f"C{i}"] for i in range(d["START"], d["START"] + d["LENGTH"]))
            )
            state = d | {"START": d["NEXT"]}
        self.assertEqual(lines, [b"ONE", b"TWO", b"THREE"])

    def test_clip_is_commutative(self) -> None:
        for left in [0, 5, 10, 15]:
            x = call(
                "rectangle-clipping",
                LEFT=left,
                TOP=0,
                RIGHT=20,
                BOTTOM=20,
                VIEW_LEFT=5,
                VIEW_TOP=5,
                VIEW_RIGHT=15,
                VIEW_BOTTOM=15,
            )
            y = call(
                "rectangle-clipping",
                VIEW_LEFT=left,
                VIEW_TOP=0,
                VIEW_RIGHT=20,
                VIEW_BOTTOM=20,
                LEFT=5,
                TOP=5,
                RIGHT=15,
                BOTTOM=15,
            )
            self.assertEqual(
                [
                    x[k]
                    for k in [
                        "OUT_LEFT",
                        "OUT_TOP",
                        "OUT_RIGHT",
                        "OUT_BOTTOM",
                        "VISIBLE",
                    ]
                ],
                [
                    y[k]
                    for k in [
                        "OUT_LEFT",
                        "OUT_TOP",
                        "OUT_RIGHT",
                        "OUT_BOTTOM",
                        "VISIBLE",
                    ]
                ],
            )

    def test_sweep_stops_at_contact_without_overlap(self) -> None:
        for target in range(31):
            d = call(
                "swept-axis-collision",
                OLD_POSITION=0,
                TARGET=target,
                SIZE=3,
                WALL_START=10,
                WALL_END=12,
            )
            self.assertEqual(d["POSITION"], min(target, 7))
            self.assertLessEqual(d["POSITION"] + 3, 10)

    def test_nearest_retains_ninth_distance_bit(self) -> None:
        d = call("nearest-target", ACTIVE=3, PX0=255, PY0=255, PX1=128, PY1=129)
        self.assertEqual((d["SLOT"], d["DISTANCE_HI"], d["DISTANCE_LO"]), (1, 1, 1))

    def test_direction_opposites(self) -> None:
        opposite = {1: 5, 2: 6, 3: 7, 4: 8, 5: 1, 6: 2, 7: 3, 8: 4}
        for x, y in [
            (5, 0),
            (5, 5),
            (0, 5),
            (-5, 5),
            (-5, 0),
            (-5, -5),
            (0, -5),
            (5, -5),
        ]:
            a = call(
                "eight-way-direction",
                FROM_X=128,
                FROM_Y=128,
                TO_X=128 + x,
                TO_Y=128 + y,
            )
            b = call(
                "eight-way-direction",
                FROM_X=128,
                FROM_Y=128,
                TO_X=128 - x,
                TO_Y=128 - y,
            )
            self.assertEqual(b["DIRECTION"], opposite[a["DIRECTION"]])

    def test_mirror_is_involution(self) -> None:
        for row in range(256):
            self.assertEqual(
                call("bitmap-mirror", ROW=call("bitmap-mirror", ROW=row)["MIRRORED"])[
                    "MIRRORED"
                ],
                row,
            )

    def test_transpose_is_involution(self) -> None:
        for bit in range(64):
            rows = [0] * 8
            rows[bit // 8] = 128 >> (bit % 8)
            a = call("bitmap-transpose", **{f"C{i}": v for i, v in enumerate(rows)})
            b = call("bitmap-transpose", **{f"C{i}": a[f"R{i}"] for i in range(8)})
            self.assertEqual([b[f"R{i}"] for i in range(8)], rows)

    def test_colour_converges_and_stays(self) -> None:
        for target in range(256):
            state = {"TARGET": target}
            for _ in range(8):
                state = call("packed-colour-step", state)
            self.assertEqual(state["COLOUR"], target)

    def test_delta_reconstructs_modulo_path(self) -> None:
        values = [255, 0, 128, 127, 1, 254, 255, 0]
        previous = 17
        deltas = []
        for value in values:
            deltas.append((value - previous) % 256)
            previous = value
        d = call(
            "bounded-delta-decoder",
            BASE=17,
            COUNT=8,
            **{f"Q{i}": v for i, v in enumerate(deltas)},
        )
        self.assertEqual([d[f"R{i}"] for i in range(8)], values)

    def test_debounce_requires_consecutive_samples(self) -> None:
        state = {"THRESHOLD": 3}
        for raw in [1, 1, 0, 1, 1]:
            state = call("input-debounce", state, RAW=raw)
            self.assertEqual(state["STABLE"], 0)
        state = call("input-debounce", state, RAW=1)
        self.assertEqual((state["STABLE"], state["CHANGED"]), (1, 1))
        self.assertEqual(call("input-debounce", state, RAW=1)["CHANGED"], 0)

    def test_round_robin_fairness(self) -> None:
        state = {"READY": 165}
        slots = []
        for _ in range(8):
            state = call("round-robin-service", state)
            slots.append(state["SLOT"])
        self.assertEqual(slots, [0, 2, 5, 7, 0, 2, 5, 7])


if __name__ == "__main__":
    unittest.main()
