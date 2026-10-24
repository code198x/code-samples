"""Algorithm invariants independent of assembly layout and example result rows."""

import importlib.util
import unittest
from pathlib import Path

p = (
    Path(__file__).resolve().parents[1]
    / "cross-platform/patterns/framework/gamekit-models/cases.py"
)
s = importlib.util.spec_from_file_location("contracts", p)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)


def call(
    topic: str, state: dict[str, int] | None = None, **values: int
) -> dict[str, int]:
    fields = M.TOPICS[topic]["fields"]
    d = dict.fromkeys(fields, 0) | (state or {}) | values
    return dict(zip(fields, M.step(topic, [d[k] for k in fields]), strict=True))


class Contracts(unittest.TestCase):
    def test_animation_finishes_after_complete_final_interval(self) -> None:
        for count in [1, 2, 7]:
            for duration in [1, 3, 255]:
                d = call("animation-timeline", FRAME_COUNT=count, DURATION=duration)
                for _ in range(count * duration - 2):
                    d = call("animation-timeline", d)
                if count * duration > 1:
                    self.assertFalse(d["FINISHED"])
                    d = call("animation-timeline", d)
                self.assertTrue(d["FINISHED"])
                self.assertEqual(d["FRAME"], count - 1)
                self.assertEqual(call("animation-timeline", d), d)

    def test_rational_schedule_preserves_total_and_remainder(self) -> None:
        for denominator in [1, 3, 5, 50, 255]:
            for numerator in [0, 1, denominator // 2, denominator]:
                d = {"NUMERATOR": numerator, "DENOMINATOR": denominator}
                count = 0
                for tick in range(1, 301):
                    d = call("rational-tick-divider", d)
                    count += d["FIRED"]
                    self.assertEqual(count * denominator + d["PHASE"], tick * numerator)

    def test_active_clock_freezes_and_reset_wins(self) -> None:
        d = call("pause-clock", TIME_LO=255, TIME_HI=255)
        self.assertEqual((d["TIME_LO"], d["TIME_HI"]), (0, 0))
        d = call("pause-clock", d, TIME_LO=17, PAUSED=1)
        self.assertEqual(d["TIME_LO"], 17)
        d = call("pause-clock", d, RESET=1)
        self.assertEqual(d["TIME_LO"], 0)

    def test_overlapping_sequence_matches_stream_suffixes(self) -> None:
        import itertools

        for events in itertools.product([1, 2], repeat=7):
            d = {}
            seen = []
            for event in events:
                seen.append(event)
                d = call("input-sequence", d, SYMBOL=event)
                self.assertEqual(bool(d["MATCHED"]), seen[-4:] == [1, 2, 1, 2])

    def test_chord_has_one_edge_until_released(self) -> None:
        d = call("input-chord", REQUIRED=3, HELD=3)
        self.assertTrue(d["PRESSED"])
        d = call("input-chord", d)
        self.assertFalse(d["PRESSED"])
        d = call("input-chord", d, HELD=2)
        d = call("input-chord", d, HELD=3)
        self.assertTrue(d["PRESSED"])

    def test_opposite_directions_cancel(self) -> None:
        for axis in [0, 1]:
            self.assertEqual(
                call("four-way-input", HELD=15, LAST_AXIS=axis)["DIRECTION"], 0
            )
        self.assertEqual(call("four-way-input", HELD=5, LAST_AXIS=1)["DIRECTION"], 3)

    def test_deadzone_is_inclusive_and_symmetric(self) -> None:
        for distance in range(128):
            a = call("analogue-deadzone", SAMPLE=128 - distance, CENTRE=128, RADIUS=8)
            b = call("analogue-deadzone", SAMPLE=128 + distance, CENTRE=128, RADIUS=8)
            self.assertEqual(a["MAGNITUDE"], b["MAGNITUDE"])
            self.assertEqual(a["MAGNITUDE"], max(0, distance - 8))

    def test_weighted_intervals_cover_exact_weights(self) -> None:
        for weights in [(0, 3, 2), (1, 1, 1), (2, 3, 1), (128, 0, 127)]:
            counts = [0, 0, 0]
            for roll in range(sum(weights)):
                d = call(
                    "weighted-choice",
                    WEIGHT0=weights[0],
                    WEIGHT1=weights[1],
                    WEIGHT2=weights[2],
                    ROLL=roll,
                )
                self.assertTrue(d["VALID"])
                counts[d["CHOICE"]] += 1
            self.assertEqual(counts, list(weights))
        self.assertFalse(call("weighted-choice", WEIGHT0=255, WEIGHT1=1)["VALID"])

    def test_bag_never_repeats_in_one_refill(self) -> None:
        for choose_last in [False, True]:
            d = call("shuffle-bag", RESET=1)
            seen = []
            for _ in range(8):
                d = call(
                    "shuffle-bag",
                    d,
                    RESET=0,
                    ROLL=d["REMAINING"] - 1 if choose_last else 0,
                )
                seen.append(d["CHOICE"])
            self.assertEqual(sorted(seen), list(range(8)))
            self.assertFalse(call("shuffle-bag", d)["VALID"])

    def test_route_reaches_each_waypoint_in_order(self) -> None:
        d = {"COUNT": 3, "SPEED": 7, "P0": 20, "P1": 3, "P2": 40}
        visited = []
        for _ in range(30):
            d = call("waypoint-route", d)
            if d["ARRIVED"]:
                visited.append(d["POSITION"])
        self.assertEqual(visited, [20, 3, 40])
        self.assertTrue(d["FINISHED"])

    def test_inventory_failed_request_preserves_slots(self) -> None:
        for remove in [0, 1]:
            d = call("inventory-stacks", SLOT=2, CAP=9, C2=5, AMOUNT=255, REMOVE=remove)
            self.assertFalse(d["SUCCESS"])
            self.assertEqual(d["C2"], 5)
        d = call("inventory-stacks", SLOT=2, CAP=9, C2=5, AMOUNT=3)
        d = call("inventory-stacks", d, REMOVE=1)
        self.assertEqual(d["C2"], 5)

    def test_recipe_is_all_or_nothing(self) -> None:
        d = call(
            "recipe-transaction",
            HAVE0=5,
            HAVE1=3,
            RESULT=4,
            NEED0=2,
            NEED1=1,
            PRODUCE=1,
            CAP=4,
        )
        self.assertFalse(d["CRAFTED"])
        self.assertEqual([d[k] for k in ["HAVE0", "HAVE1", "RESULT"]], [5, 3, 4])
        d = call("recipe-transaction", d, CAP=5)
        self.assertTrue(d["CRAFTED"])
        self.assertEqual([d[k] for k in ["HAVE0", "HAVE1", "RESULT"]], [3, 2, 5])

    def test_dialogue_preview_cannot_commit(self) -> None:
        d = call(
            "dialogue-gates", FLAGS=5, REQUIRED=5, FORBIDDEN=2, SET_MASK=2, CLEAR_MASK=1
        )
        self.assertTrue(d["AVAILABLE"])
        self.assertEqual(d["FLAGS"], 5)
        d = call("dialogue-gates", d, ACCEPT=1)
        self.assertEqual(d["FLAGS"], 6)
        self.assertFalse(call("dialogue-gates", d)["AVAILABLE"])

    def test_number_parser_preserves_good_prefix_on_error(self) -> None:
        d = {}
        for c in b"255":
            d = call("decimal-parser", d, CHARACTER=c)
        self.assertEqual(d["VALUE"], 255)
        for c in [ord("6"), ord("x")]:
            self.assertEqual(call("decimal-parser", d, CHARACTER=c)["VALUE"], 255)

    def test_depth_order_is_stable_permutation(self) -> None:
        depth = [8, 2, 8, 1, 2, 255, 0, 8]
        d = call(
            "stable-depth-order", COUNT=8, **{f"Z{i}": v for i, v in enumerate(depth)}
        )
        order = [d[f"I{i}"] for i in range(8)]
        self.assertEqual(sorted(order), list(range(8)))
        self.assertEqual([i for i in order if depth[i] == 8], [0, 2, 7])
        self.assertEqual([depth[i] for i in order], sorted(depth))

    def test_dirty_marks_coalesce_and_drain_once(self) -> None:
        d = {}
        for i in [15, 0, 7, 15, 8]:
            d = call("dirty-cells", d, CELL=i, MODE=0)
        seen = []
        for _ in range(5):
            d = call("dirty-cells", d, MODE=1)
            if d["FOUND"]:
                seen.append(d["CELL"])
        self.assertEqual(seen, [0, 7, 8, 15])
        self.assertEqual(d["MASK_LO"] + d["MASK_HI"], 0)

    def test_fill_does_not_join_preexisting_replacement_cells(self) -> None:
        cells = [1, 9, 1, 0] + [0] * 12
        d = call(
            "bounded-flood-fill",
            SEED=0,
            REPLACEMENT=9,
            **{f"C{i}": v for i, v in enumerate(cells)},
        )
        self.assertEqual(d["CHANGED"], 1)
        self.assertEqual(d["C2"], 1)
        d = call("bounded-flood-fill", SEED=0, REPLACEMENT=3)
        self.assertEqual(d["CHANGED"], 16)

    def test_sight_checks_destination_but_not_observer(self) -> None:
        d = call("cardinal-sight", FROM=0, TO=3, C0=1)
        self.assertTrue(d["VISIBLE"])
        d = call("cardinal-sight", d, C3=1)
        self.assertFalse(d["VISIBLE"])
        self.assertFalse(call("cardinal-sight", FROM=0, TO=5)["VALID"])

    def test_reflection_respects_travel_and_bounds(self) -> None:
        for position in range(11):
            for direction in [0, 1]:
                for distance in [0, 1, 2, 10, 27, 255]:
                    a = call(
                        "reflected-axis",
                        POSITION=position,
                        MINIMUM=0,
                        MAXIMUM=10,
                        DIRECTION=direction,
                        DISTANCE=distance,
                    )
                    b = call(
                        "reflected-axis",
                        POSITION=position,
                        MINIMUM=0,
                        MAXIMUM=10,
                        DIRECTION=direction,
                        DISTANCE=distance // 2,
                    )
                    b = call("reflected-axis", b, DISTANCE=distance - distance // 2)
                    self.assertEqual(
                        (a["POSITION"], a["DIRECTION"]), (b["POSITION"], b["DIRECTION"])
                    )
                    self.assertLessEqual(a["POSITION"], 10)

    def test_slope_mirror_and_overflow(self) -> None:
        heights = {f"H{i}": 7 - i for i in range(8)}
        for x in range(8):
            a = call("slope-height", LOCAL_X=x, BASE_Y=100, **heights)
            b = call("slope-height", LOCAL_X=7 - x, BASE_Y=100, MIRROR=1, **heights)
            self.assertEqual(a["SURFACE"], b["SURFACE"])
        self.assertFalse(
            call("slope-height", LOCAL_X=0, BASE_Y=255, **heights)["VALID"]
        )


if __name__ == "__main__":
    unittest.main()
