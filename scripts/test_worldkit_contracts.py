"""Properties and boundary invariants for the new reusable components."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

p = (
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/worldkit-models/cases.py"
)
s = importlib.util.spec_from_file_location("models", p)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)


def call(
    topic: str, state: dict[str, int] | None = None, **values: int
) -> dict[str, int]:
    f = M.TOPICS[topic]["fields"]
    d = dict.fromkeys(f, 0) | (state or {}) | values
    return dict(zip(f, M.step(topic, [d[k] for k in f]), strict=True))


class Contracts(unittest.TestCase):
    def test_product_retains_full_width_and_is_commutative(self) -> None:
        for a in range(256):
            for b in [0, 1, 127, 128, 255]:
                d = call("byte-product", LEFT=a, RIGHT=b)
                e = call("byte-product", LEFT=b, RIGHT=a)
                self.assertEqual(d["PRODUCT_LO"] + 256 * d["PRODUCT_HI"], a * b)
                self.assertEqual(
                    (d["PRODUCT_LO"], d["PRODUCT_HI"]),
                    (e["PRODUCT_LO"], e["PRODUCT_HI"]),
                )

    def test_division_reconstructs_numerator(self) -> None:
        for n in [0, 1, 255, 256, 257, 32768, 65535]:
            for v in range(1, 256):
                d = call(
                    "word-division",
                    NUMERATOR_LO=n % 256,
                    NUMERATOR_HI=n // 256,
                    DIVISOR=v,
                )
                q = d["QUOTIENT_LO"] + 256 * d["QUOTIENT_HI"]
                self.assertEqual(q * v + d["REMAINDER"], n)
                self.assertLess(d["REMAINDER"], v)
        self.assertFalse(call("word-division", DIVISOR=0)["VALID"])

    def test_root_satisfies_adjacent_square_bounds(self) -> None:
        for n in range(0, 65536, 113):
            d = call("integer-square-root", NUMBER_LO=n % 256, NUMBER_HI=n // 256)
            root = d["ROOT"]
            self.assertLessEqual(root * root, n)
            self.assertGreater((root + 1) ** 2, n)
            self.assertEqual(
                root * root + d["REMAINDER_LO"] + 256 * d["REMAINDER_HI"], n
            )

    def test_circle_boundary_and_large_sum(self) -> None:
        self.assertTrue(call("point-circle", POINT_X=3, POINT_Y=4, RADIUS=5)["HIT"])
        self.assertFalse(call("point-circle", POINT_X=4, POINT_Y=4, RADIUS=5)["HIT"])
        self.assertFalse(
            call("point-circle", POINT_X=255, POINT_Y=255, RADIUS=255)["HIT"]
        )

    def test_interpolation_endpoints_bounds_and_monotonicity(self) -> None:
        for a, b in [(0, 255), (255, 0), (10, 210), (7, 7)]:
            values = [
                call("byte-interpolation", START=a, END=b, FRACTION=t)["VALUE"]
                for t in range(256)
            ]
            self.assertEqual(values[0], a)
            self.assertEqual(values[-1], b)
            self.assertTrue(all(min(a, b) <= v <= max(a, b) for v in values))
            self.assertEqual(values, sorted(values, reverse=a > b))

    def test_line_queries_respect_blockers_and_do_not_mutate_grid(self) -> None:
        for a in range(16):
            for b in range(16):
                d = call("grid-line-sight", FROM=a, TO=b)
                self.assertTrue(d["VISIBLE"])
                self.assertTrue(d["VALID"])
                if a != b:
                    self.assertFalse(
                        call("grid-line-sight", FROM=a, TO=b, **{f"C{b}": 1})["VISIBLE"]
                    )
        self.assertFalse(call("grid-line-sight", FROM=16)["VALID"])

    def test_path_first_step_reduces_shortest_distance(self) -> None:
        for a in range(16):
            for b in range(16):
                d = call("bounded-grid-path", FROM=a, TO=b)
                self.assertTrue(d["FOUND"])
                self.assertEqual(
                    d["DISTANCE"], abs(a % 4 - b % 4) + abs(a // 4 - b // 4)
                )
                if a != b:
                    n = a + {1: -1, 2: 1, 3: -4, 4: 4}[d["MOVE"]]
                    e = call("bounded-grid-path", FROM=n, TO=b)
                    self.assertEqual(e["DISTANCE"], d["DISTANCE"] - 1)
        self.assertFalse(
            call("bounded-grid-path", FROM=0, TO=15, C4=1, C5=1, C6=1, C7=1)["FOUND"]
        )

    def test_trigger_events_partition_snapshots(self) -> None:
        for previous in range(256):
            for current in [0, 1, 85, 170, 255]:
                d = call("trigger-transitions", PREVIOUS=previous, CURRENT=current)
                self.assertEqual(d["ENTERED"] | d["STAYED"], current)
                self.assertEqual(d["EXITED"] | d["STAYED"], previous)
                self.assertFalse(d["ENTERED"] & d["EXITED"])
                self.assertFalse(d["ENTERED"] & d["STAYED"])

    def test_status_expires_and_has_exact_pulse_count(self) -> None:
        for duration in [0, 1, 5, 255]:
            for period in [1, 2, 7, 255]:
                d = call("timed-status", DURATION=duration, PERIOD=period, APPLY=1)
                pulses = d["PULSE"]
                for _ in range(duration):
                    d = call("timed-status", d, APPLY=0)
                    pulses += d["PULSE"]
                self.assertEqual(d["REMAINING"], 0)
                self.assertEqual(pulses, duration // period)

    def test_checkpoint_failure_cannot_partially_restore(self) -> None:
        d = call("checkpoint-state", LIVE_X=20, LIVE_Y=30, LIVE_RESOURCE=4)
        e = call("checkpoint-state", d, MODE=1, LIVE_X=99, CHECKSUM=d["CHECKSUM"] ^ 1)
        self.assertFalse(e["RESULT"])
        self.assertEqual(e["LIVE_X"], 99)
        e = call("checkpoint-state", d, MODE=1, LIVE_X=99)
        self.assertTrue(e["RESULT"])
        self.assertEqual(e["LIVE_X"], 20)

    def test_timeline_emits_once_in_order_and_finishes(self) -> None:
        d = {"COUNT": 3, "E0": 2, "E1": 4, "E2": 7, "L0": 0, "L1": 2, "L2": 1}
        events = []
        for _ in range(20):
            d = call("spawn-timeline", d)
            if d["FIRED"]:
                events.append(d["EVENT"])
        self.assertEqual(events, [2, 4, 7])
        self.assertTrue(d["DONE"])

    def test_nibble_write_preserves_neighbour(self) -> None:
        for cell in range(16):
            d = call(
                "packed-nibble-map",
                CELL=cell,
                WRITE=1,
                NEW_VALUE=5,
                **{f"B{i}": 171 for i in range(8)},
            )
            self.assertEqual(d["VALUE"], 5)
            other = cell ^ 1
            e = call("packed-nibble-map", d, CELL=other, WRITE=0)
            self.assertEqual(e["VALUE"], 10 if other % 2 == 0 else 11)

    def test_rle_round_trip_and_full_output_failure(self) -> None:
        for data in [[7] * 8, list(range(8)), [1, 1, 2, 2, 2, 3, 1, 1]]:
            d = call(
                "bounded-rle-encoder",
                INPUT_COUNT=8,
                CAPACITY=16,
                **{f"B{i}": v for i, v in enumerate(data)},
            )
            decoded = []
            for i in range(0, d["WRITTEN"], 2):
                decoded += [d[f"R{i + 1}"]] * d[f"R{i}"]
            self.assertEqual(decoded, data)
            e = call(
                "bounded-rle-encoder", d, CAPACITY=1, **{f"R{i}": 99 for i in range(16)}
            )
            self.assertEqual(e["ERROR"], 2)
            self.assertTrue(all(e[f"R{i}"] == 99 for i in range(16)))

    def test_handle_reuse_rejects_old_generation(self) -> None:
        d = call("generation-handles")
        old = d["OUT_GENERATION"]
        d = call("generation-handles", d, MODE=1, SLOT=0, GENERATION=old)
        d = call("generation-handles", d, MODE=0)
        self.assertNotEqual(d["OUT_GENERATION"], old)
        e = call("generation-handles", d, MODE=2, SLOT=0, GENERATION=old)
        self.assertFalse(e["RESULT"])
        self.assertEqual(e["ACTIVE"], d["ACTIVE"])

    def test_compaction_is_stable_and_preserves_unused_tail(self) -> None:
        d = call(
            "stable-compaction",
            COUNT=6,
            F0=1,
            F2=1,
            F4=1,
            F7=1,
            I0=10,
            I1=11,
            I2=12,
            I3=13,
            I4=14,
            I5=15,
            I7=99,
        )
        self.assertEqual(d["COUNT"], 3)
        self.assertEqual([d[f"I{i}"] for i in range(3)], [10, 12, 14])
        self.assertEqual(d["I7"], 99)
        self.assertEqual(d["F7"], 1)

    def test_history_wrap_retains_latest_eight(self) -> None:
        d = {}
        for i in range(12):
            d = call("motion-history", d, PUSH=1, INPUT_X=i, INPUT_Y=100 + i, LAG=0)
        for age in range(8):
            e = call("motion-history", d, PUSH=0, LAG=age)
            self.assertEqual((e["OUT_X"], e["OUT_Y"]), (11 - age, 111 - age))
        self.assertFalse(call("motion-history", d, PUSH=0, LAG=8)["VALID"])

    def test_bit_reads_cross_bytes_and_reject_without_advancing(self) -> None:
        d = call("bounded-bit-reader", B0=171, B1=192, CURSOR=4, COUNT=8)
        self.assertEqual(d["VALUE"], 188)
        self.assertEqual(d["CURSOR"], 12)
        e = call("bounded-bit-reader", d, CURSOR=31, COUNT=2)
        self.assertFalse(e["VALID"])
        self.assertEqual(e["CURSOR"], 31)

    def test_mask_boxes_can_overlap_without_opaque_contact(self) -> None:
        self.assertFalse(call("pixel-mask-collision", P0=128, Q0=128, SHIFT_X=1)["HIT"])
        self.assertTrue(call("pixel-mask-collision", P0=128, Q0=128)["HIT"])
        self.assertFalse(call("pixel-mask-collision", P0=255, Q0=255, SHIFT_X=8)["HIT"])

    def test_envelope_stays_bounded_then_releases_to_zero(self) -> None:
        d = {"GATE": 1, "ATTACK": 3, "DECAY": 2, "SUSTAIN": 6, "RELEASE": 4}
        for _ in range(30):
            d = call("logical-envelope", d)
            self.assertTrue(0 <= d["LEVEL"] <= 15)
        self.assertEqual(d["LEVEL"], 6)
        self.assertEqual(d["PHASE"], 3)
        for _ in range(5):
            d = call("logical-envelope", d, GATE=0)
        self.assertEqual((d["LEVEL"], d["PHASE"]), (0, 0))

    def test_undo_lifo_and_capacity_failure(self) -> None:
        d = call("bounded-undo", CELL=0, VALUE=7)
        d = call("bounded-undo", d, VALUE=9)
        d = call("bounded-undo", d, MODE=1)
        self.assertEqual(d["C0"], 7)
        d = call("bounded-undo", d)
        self.assertEqual(d["C0"], 0)
        for i in range(4):
            d = call("bounded-undo", d, MODE=0, CELL=i, VALUE=10 + i)
        e = call("bounded-undo", d, MODE=0, CELL=0, VALUE=99)
        self.assertFalse(e["RESULT"])
        self.assertEqual(e["C0"], d["C0"])


if __name__ == "__main__":
    unittest.main()
