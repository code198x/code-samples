"""Independent contracts: mathematical/container models, not assembly emulation."""

from __future__ import annotations

import random

TOPICS = {
    "animation-timeline": {
        "title": "Advance a Timed Animation",
        "category": "rendering",
        "fields": [
            "FRAME",
            "TICKS",
            "FRAME_COUNT",
            "DURATION",
            "LOOP",
            "FINISHED",
            "VALID",
        ],
        "trace": [
            {"FRAME_COUNT": 3, "DURATION": 3, "LOOP": 1},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
        "custom_trace": [
            {"FRAME_COUNT": 3, "DURATION": 2, "LOOP": 1},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
    },
    "rational-tick-divider": {
        "title": "Divide Ticks Without Losing the Remainder",
        "category": "framework",
        "fields": ["PHASE", "NUMERATOR", "DENOMINATOR", "FIRED", "VALID"],
        "trace": [
            {"NUMERATOR": 3, "DENOMINATOR": 5},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
        "custom_trace": [
            {"NUMERATOR": 1, "DENOMINATOR": 3},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
    },
    "pause-clock": {
        "title": "Count Active Play Time",
        "category": "framework",
        "fields": ["TIME_LO", "TIME_HI", "PAUSED", "RESET"],
        "trace": [{}, {}, {"PAUSED": 1}, {}, {"PAUSED": 0}, {}],
        "custom_trace": [{"TIME_LO": 255}, {}, {"PAUSED": 1}, {}, {"PAUSED": 0}, {}],
    },
    "input-sequence": {
        "title": "Recognise a Short Input Sequence",
        "category": "input",
        "fields": ["PROGRESS", "SYMBOL", "MATCHED", "VALID"],
        "trace": [
            {"SYMBOL": 1},
            {"SYMBOL": 2},
            {"SYMBOL": 1},
            {"SYMBOL": 2},
            {"SYMBOL": 1},
            {"SYMBOL": 2},
        ],
        "custom_trace": [
            {"SYMBOL": 1},
            {"SYMBOL": 1},
            {"SYMBOL": 2},
            {"SYMBOL": 1},
            {"SYMBOL": 2},
        ],
    },
    "input-chord": {
        "title": "Detect a Button Chord Once",
        "category": "input",
        "fields": [
            "PREVIOUS",
            "HELD",
            "REQUIRED",
            "FORBIDDEN",
            "ACTIVE",
            "PRESSED",
            "VALID",
        ],
        "trace": [
            {"REQUIRED": 3, "FORBIDDEN": 4, "HELD": 3},
            {},
            {"HELD": 7},
            {"HELD": 3},
            {},
        ],
        "custom_trace": [{"REQUIRED": 5, "FORBIDDEN": 2, "HELD": 5}, {}, {}],
    },
    "four-way-input": {
        "title": "Resolve Input to Four Directions",
        "category": "input",
        "fields": ["HELD", "LAST_AXIS", "DIRECTION", "VALID"],
        "trace": [{"HELD": 5}, {"HELD": 8}, {"HELD": 5}, {"HELD": 3}],
        "custom_trace": [
            {"HELD": 5, "LAST_AXIS": 1},
            {"HELD": 8},
            {"HELD": 5},
            {"HELD": 3},
        ],
    },
    "analogue-deadzone": {
        "title": "Turn an Analogue Axis into Intent",
        "category": "input",
        "fields": ["SAMPLE", "CENTRE", "RADIUS", "DIRECTION", "MAGNITUDE", "VALID"],
        "trace": [
            {"SAMPLE": 130, "CENTRE": 128, "RADIUS": 4},
            {"SAMPLE": 140},
            {"SAMPLE": 118},
        ],
        "custom_trace": [
            {"SAMPLE": 130, "CENTRE": 128, "RADIUS": 8},
            {"SAMPLE": 140},
            {"SAMPLE": 118},
        ],
    },
    "weighted-choice": {
        "title": "Choose from Weighted Outcomes",
        "category": "ai",
        "fields": ["WEIGHT0", "WEIGHT1", "WEIGHT2", "ROLL", "CHOICE", "TOTAL", "VALID"],
        "trace": [
            {"WEIGHT0": 2, "WEIGHT1": 3, "WEIGHT2": 1, "ROLL": 0},
            {"ROLL": 2},
            {"ROLL": 5},
        ],
        "custom_trace": [
            {"WEIGHT0": 1, "WEIGHT1": 1, "WEIGHT2": 4, "ROLL": 0},
            {"ROLL": 2},
            {"ROLL": 5},
        ],
    },
    "shuffle-bag": {
        "title": "Draw Without Repeating from a Bag",
        "category": "ai",
        "fields": [
            "REMAINING",
            "ROLL",
            "RESET",
            "CHOICE",
            "VALID",
            "B0",
            "B1",
            "B2",
            "B3",
            "B4",
            "B5",
            "B6",
            "B7",
        ],
        "trace": [{"RESET": 1}, {"RESET": 0, "ROLL": 0}, {}, {}, {}, {}, {}, {}, {}],
        "custom_trace": [
            {"RESET": 1},
            {"RESET": 0, "ROLL": 7},
            {"RESET": 0, "ROLL": 6},
            {"RESET": 0, "ROLL": 5},
            {"RESET": 0, "ROLL": 4},
            {"RESET": 0, "ROLL": 3},
            {"RESET": 0, "ROLL": 2},
            {"RESET": 0, "ROLL": 1},
            {"RESET": 0, "ROLL": 0},
        ],
    },
    "waypoint-route": {
        "title": "Walk an Ordered Waypoint Route",
        "category": "ai",
        "fields": [
            "POSITION",
            "TARGET_INDEX",
            "COUNT",
            "SPEED",
            "LOOP",
            "ARRIVED",
            "FINISHED",
            "VALID",
            "P0",
            "P1",
            "P2",
            "P3",
        ],
        "trace": [
            {"COUNT": 3, "SPEED": 4, "P0": 6, "P1": 2, "P2": 9},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
        "custom_trace": [
            {"COUNT": 3, "SPEED": 4, "P0": 6, "P1": 2, "P2": 9, "LOOP": 1},
            {},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
    },
    "inventory-stacks": {
        "title": "Add and Remove Inventory Stacks",
        "category": "framework",
        "fields": [
            "SLOT",
            "AMOUNT",
            "REMOVE",
            "CAP",
            "SUCCESS",
            "VALID",
            "C0",
            "C1",
            "C2",
            "C3",
        ],
        "trace": [
            {"CAP": 9, "SLOT": 1, "AMOUNT": 6},
            {"AMOUNT": 5},
            {"REMOVE": 1, "AMOUNT": 2},
        ],
        "custom_trace": [
            {"CAP": 7, "SLOT": 1, "AMOUNT": 6},
            {"AMOUNT": 5},
            {"REMOVE": 1, "AMOUNT": 2},
        ],
    },
    "recipe-transaction": {
        "title": "Commit a Crafting Recipe Atomically",
        "category": "framework",
        "fields": [
            "HAVE0",
            "HAVE1",
            "RESULT",
            "NEED0",
            "NEED1",
            "PRODUCE",
            "CAP",
            "CRAFTED",
            "VALID",
        ],
        "trace": [
            {"HAVE0": 3, "HAVE1": 2, "NEED0": 2, "NEED1": 1, "PRODUCE": 1, "CAP": 4},
            {},
            {},
        ],
        "custom_trace": [
            {"HAVE0": 3, "HAVE1": 2, "NEED0": 2, "NEED1": 1, "PRODUCE": 2, "CAP": 4},
            {},
            {},
        ],
    },
    "dialogue-gates": {
        "title": "Gate a Dialogue Choice with Flags",
        "category": "framework",
        "fields": [
            "FLAGS",
            "REQUIRED",
            "FORBIDDEN",
            "SET_MASK",
            "CLEAR_MASK",
            "ACCEPT",
            "AVAILABLE",
            "TAKEN",
            "VALID",
        ],
        "trace": [
            {
                "FLAGS": 1,
                "REQUIRED": 1,
                "FORBIDDEN": 2,
                "SET_MASK": 2,
                "CLEAR_MASK": 1,
                "ACCEPT": 0,
            },
            {"ACCEPT": 1},
            {},
        ],
        "custom_trace": [
            {
                "FLAGS": 5,
                "REQUIRED": 5,
                "FORBIDDEN": 2,
                "SET_MASK": 2,
                "CLEAR_MASK": 1,
                "ACCEPT": 0,
            },
            {"ACCEPT": 1},
            {},
        ],
    },
    "decimal-parser": {
        "title": "Parse a Bounded Decimal Number",
        "category": "framework",
        "fields": ["VALUE", "CHARACTER", "STATUS"],
        "trace": [
            {"CHARACTER": 50},
            {"CHARACTER": 53},
            {"CHARACTER": 54},
            {"CHARACTER": 53},
        ],
        "custom_trace": [{"CHARACTER": 49}, {"CHARACTER": 48}, {"CHARACTER": 52}],
    },
    "stable-depth-order": {
        "title": "Sort a Small Draw Order Stably",
        "category": "rendering",
        "fields": [
            "COUNT",
            "VALID",
            "Z0",
            "Z1",
            "Z2",
            "Z3",
            "Z4",
            "Z5",
            "Z6",
            "Z7",
            "I0",
            "I1",
            "I2",
            "I3",
            "I4",
            "I5",
            "I6",
            "I7",
        ],
        "trace": [{"COUNT": 5, "Z0": 8, "Z1": 2, "Z2": 8, "Z3": 1, "Z4": 2}],
        "custom_trace": [{"COUNT": 5, "Z0": 1, "Z1": 8, "Z2": 1, "Z3": 8, "Z4": 2}],
    },
    "dirty-cells": {
        "title": "Remember Which Cells Need Redrawing",
        "category": "rendering",
        "fields": ["MASK_LO", "MASK_HI", "CELL", "MODE", "FOUND", "VALID"],
        "trace": [{"CELL": 3}, {"CELL": 12}, {"CELL": 3}, {"MODE": 1}],
        "custom_trace": [{"MODE": 2}, {"MODE": 1}, {}, {}],
    },
    "bounded-flood-fill": {
        "title": "Fill a Connected Grid Region",
        "category": "ai",
        "fields": [
            "SEED",
            "REPLACEMENT",
            "CHANGED",
            "VALID",
            "C0",
            "C1",
            "C2",
            "C3",
            "C4",
            "C5",
            "C6",
            "C7",
            "C8",
            "C9",
            "C10",
            "C11",
            "C12",
            "C13",
            "C14",
            "C15",
        ],
        "trace": [
            {"SEED": 0, "REPLACEMENT": 9, "C0": 1, "C1": 1, "C4": 1, "C5": 2, "C15": 1}
        ],
        "custom_trace": [
            {"SEED": 15, "REPLACEMENT": 9, "C0": 1, "C1": 1, "C4": 1, "C5": 2, "C15": 1}
        ],
    },
    "cardinal-sight": {
        "title": "Test Sight Along a Grid Row or Column",
        "category": "ai",
        "fields": [
            "FROM",
            "TO",
            "VISIBLE",
            "VALID",
            "C0",
            "C1",
            "C2",
            "C3",
            "C4",
            "C5",
            "C6",
            "C7",
            "C8",
            "C9",
            "C10",
            "C11",
            "C12",
            "C13",
            "C14",
            "C15",
        ],
        "trace": [{"FROM": 0, "TO": 3, "C2": 1}],
        "custom_trace": [{"FROM": 0, "TO": 12, "C2": 1, "C8": 1}],
    },
    "reflected-axis": {
        "title": "Reflect Movement at Axis Bounds",
        "category": "physics",
        "fields": [
            "POSITION",
            "MINIMUM",
            "MAXIMUM",
            "DISTANCE",
            "DIRECTION",
            "BOUNCES",
            "VALID",
        ],
        "trace": [
            {"POSITION": 8, "MINIMUM": 0, "MAXIMUM": 10, "DISTANCE": 7, "DIRECTION": 1},
            {"DISTANCE": 14},
        ],
        "custom_trace": [
            {"POSITION": 2, "MINIMUM": 0, "MAXIMUM": 3, "DISTANCE": 7, "DIRECTION": 1},
            {"DISTANCE": 14},
        ],
    },
    "slope-height": {
        "title": "Query a Small Slope Height Profile",
        "category": "physics",
        "fields": [
            "LOCAL_X",
            "BASE_Y",
            "MIRROR",
            "SURFACE",
            "VALID",
            "H0",
            "H1",
            "H2",
            "H3",
            "H4",
            "H5",
            "H6",
            "H7",
        ],
        "trace": [
            {
                "LOCAL_X": 1,
                "BASE_Y": 100,
                "H0": 7,
                "H1": 6,
                "H2": 5,
                "H3": 4,
                "H4": 3,
                "H5": 2,
                "H6": 1,
                "H7": 0,
            },
            {"LOCAL_X": 6},
        ],
        "custom_trace": [
            {
                "LOCAL_X": 1,
                "BASE_Y": 100,
                "H0": 7,
                "H1": 6,
                "H2": 5,
                "H3": 4,
                "H4": 3,
                "H5": 2,
                "H6": 1,
                "H7": 0,
                "MIRROR": 1,
            },
            {"LOCAL_X": 6},
        ],
    },
}


def step(
    topic: str, row: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    f = TOPICS[topic]["fields"]
    d = dict(zip(f, row, strict=True))
    before = d.copy()
    if wrong:
        if topic == "animation-timeline":
            d["TICKS"] = 0
        elif topic == "rational-tick-divider":
            d["PHASE"] = 0
        elif topic == "pause-clock":
            d["PAUSED"] = 0
        elif topic == "input-sequence":
            d["PROGRESS"] = 0
        elif topic == "input-chord":
            d["PREVIOUS"] = 0
        elif topic == "four-way-input":
            d["LAST_AXIS"] = 0
        elif topic == "analogue-deadzone":
            d["RADIUS"] = 0
        elif topic == "weighted-choice":
            d["ROLL"] = 0
        elif topic == "shuffle-bag":
            d["RESET"] = 1
        elif topic == "waypoint-route":
            d["TARGET_INDEX"] = 0
        elif topic == "inventory-stacks":
            d["REMOVE"] = 1
        elif topic == "recipe-transaction":
            d["HAVE0"] = 0
        elif topic == "dialogue-gates":
            d["FLAGS"] = 0
        elif topic == "decimal-parser":
            d["VALUE"] = 0
        elif topic == "stable-depth-order":
            d["COUNT"] = 0
        elif topic == "dirty-cells":
            d["MASK_LO"] = d["MASK_HI"] = 0
        elif topic == "bounded-flood-fill":
            d["SEED"] = 15
        elif topic == "cardinal-sight":
            d["C2"] = 0
        elif topic == "reflected-axis":
            d["DISTANCE"] = 1
        elif topic == "slope-height":
            d["LOCAL_X"] = 0
    if topic == "animation-timeline":
        ok = (
            0 < d["FRAME_COUNT"]
            and 0 < d["DURATION"]
            and d["FRAME"] < d["FRAME_COUNT"]
            and d["TICKS"] < d["DURATION"]
        )
        d["VALID"] = int(ok)
        if ok and not d["FINISHED"]:
            total = d["TICKS"] + 1
            frame = d["FRAME"]
            if total == d["DURATION"]:
                total = 0
                if frame + 1 < d["FRAME_COUNT"]:
                    frame += 1
                elif d["LOOP"]:
                    frame = 0
                else:
                    d["FINISHED"] = 1
            d.update(FRAME=frame, TICKS=total)
    elif topic == "rational-tick-divider":
        ok = (
            0 < d["DENOMINATOR"]
            and d["NUMERATOR"] <= d["DENOMINATOR"]
            and d["PHASE"] < d["DENOMINATOR"]
        )
        d.update(VALID=int(ok), FIRED=0)
        if ok:
            d["FIRED"], d["PHASE"] = divmod(
                d["PHASE"] + d["NUMERATOR"], d["DENOMINATOR"]
            )
    elif topic == "pause-clock":
        value = d["TIME_LO"] + 256 * d["TIME_HI"]
        value = 0 if d["RESET"] else (value + int(not d["PAUSED"])) % 65536
        d["TIME_HI"], d["TIME_LO"] = divmod(value, 256)
    elif topic == "input-sequence":
        p = d["PROGRESS"]
        s = d["SYMBOL"]
        ok = p < 4 and s < 3
        d.update(VALID=int(ok), MATCHED=0)
        if ok and s:
            prefix = [1, 2, 1, 2][:p] + [s]
            d["MATCHED"] = int(prefix[-4:] == [1, 2, 1, 2])
            d["PROGRESS"] = max(
                [n for n in range(4) if n == 0 or prefix[-n:] == [1, 2, 1, 2][:n]]
            )
    elif topic == "input-chord":
        ok = d["REQUIRED"] != 0 and not d["REQUIRED"] & d["FORBIDDEN"]
        active = bool(
            ok
            and d["HELD"] & d["REQUIRED"] == d["REQUIRED"]
            and not d["HELD"] & d["FORBIDDEN"]
        )
        d.update(
            VALID=int(ok),
            ACTIVE=int(active),
            PRESSED=int(active and not d["PREVIOUS"]),
            PREVIOUS=int(active),
        )
    elif topic == "four-way-input":
        d.update(DIRECTION=0, VALID=int(d["LAST_AXIS"] < 2))
        if d["VALID"]:
            horizontal = {1: 1, 2: 2}.get(d["HELD"] & 3, 0)
            vertical = {4: 3, 8: 4}.get(d["HELD"] & 12, 0)
            pick = (
                vertical
                if vertical and (not horizontal or d["LAST_AXIS"])
                else horizontal
            )
            d["DIRECTION"] = pick
            if pick:
                d["LAST_AXIS"] = int(pick >= 3)
    elif topic == "analogue-deadzone":
        ok = d["RADIUS"] < 128
        delta = d["SAMPLE"] - d["CENTRE"]
        m = max(0, abs(delta) - d["RADIUS"]) if ok else 0
        d.update(
            VALID=int(ok), MAGNITUDE=m, DIRECTION=(1 if delta < 0 else 2) if m else 0
        )
    elif topic == "weighted-choice":
        weights = [d["WEIGHT" + str(i)] for i in range(3)]
        total = sum(weights)
        ok = 0 < total < 256 and d["ROLL"] < total
        d.update(CHOICE=255, TOTAL=total if total < 256 else 0, VALID=int(ok))
        if ok:
            intervals = [i for i in range(3) for _ in range(weights[i])]
            d["CHOICE"] = intervals[d["ROLL"]]
    elif topic == "shuffle-bag":
        d.update(CHOICE=255, VALID=0)
        if d["RESET"]:
            d.update({f"B{i}": i for i in range(8)})
            d.update(REMAINING=8, VALID=1)
        elif 0 < d["REMAINING"] <= 8 and d["ROLL"] < d["REMAINING"]:
            bag = [d[f"B{i}"] for i in range(d["REMAINING"])]
            d["CHOICE"] = bag[d["ROLL"]]
            bag[d["ROLL"]] = bag[-1]
            d["REMAINING"] -= 1
            d[f"B{d['ROLL']}"] = bag[d["ROLL"]]
            d["VALID"] = 1
    elif topic == "waypoint-route":
        ok = 0 < d["COUNT"] <= 4 and d["TARGET_INDEX"] < d["COUNT"] and d["SPEED"] != 0
        d.update(VALID=int(ok), ARRIVED=0)
        if ok and not d["FINISHED"]:
            target = d["P" + str(d["TARGET_INDEX"])]
            delta = target - d["POSITION"]
            distance = min(abs(delta), d["SPEED"])
            d["POSITION"] += distance if delta >= 0 else -distance
            if d["POSITION"] == target:
                d["ARRIVED"] = 1
                if d["TARGET_INDEX"] + 1 < d["COUNT"]:
                    d["TARGET_INDEX"] += 1
                elif d["LOOP"]:
                    d["TARGET_INDEX"] = 0
                else:
                    d["FINISHED"] = 1
    elif topic == "inventory-stacks":
        ok = (
            d["SLOT"] < 4
            and d["CAP"] != 0
            and (d["SLOT"] >= 4 or d["C" + str(d["SLOT"])] <= d["CAP"])
        )
        d.update(VALID=int(ok), SUCCESS=0)
        if ok:
            key = "C" + str(d["SLOT"])
            value = d[key] + (-d["AMOUNT"] if d["REMOVE"] else d["AMOUNT"])
            if 0 <= value <= d["CAP"]:
                d[key] = value
                d["SUCCESS"] = 1
    elif topic == "recipe-transaction":
        ok = d["CAP"] != 0 and d["RESULT"] <= d["CAP"]
        d.update(VALID=int(ok), CRAFTED=0)
        if (
            ok
            and d["HAVE0"] >= d["NEED0"]
            and d["HAVE1"] >= d["NEED1"]
            and d["RESULT"] + d["PRODUCE"] <= d["CAP"]
        ):
            d["HAVE0"] -= d["NEED0"]
            d["HAVE1"] -= d["NEED1"]
            d["RESULT"] += d["PRODUCE"]
            d["CRAFTED"] = 1
    elif topic == "dialogue-gates":
        ok = not d["REQUIRED"] & d["FORBIDDEN"]
        available = (
            ok
            and d["FLAGS"] & d["REQUIRED"] == d["REQUIRED"]
            and not d["FLAGS"] & d["FORBIDDEN"]
        )
        d.update(
            VALID=int(ok),
            AVAILABLE=int(bool(available)),
            TAKEN=int(bool(available and d["ACCEPT"])),
        )
        if d["TAKEN"]:
            d["FLAGS"] = (d["FLAGS"] & ~d["CLEAR_MASK"]) | d["SET_MASK"]
    elif topic == "decimal-parser":
        character = chr(d["CHARACTER"])
        new = str(d["VALUE"]) + character
        digit = "0" <= character <= "9"
        n = int(new) if digit else 256
        d["STATUS"] = 2 if not digit else 3 if n > 255 else 1
        if d["STATUS"] == 1:
            d["VALUE"] = n
    elif topic == "stable-depth-order":
        ok = d["COUNT"] <= 8
        d["VALID"] = int(ok)
        if ok:
            indices = sorted(range(d["COUNT"]), key=lambda i: d["Z" + str(i)]) + list(
                range(d["COUNT"], 8)
            )
            d.update({f"I{i}": value for i, value in enumerate(indices)})
    elif topic == "dirty-cells":
        mask = d["MASK_LO"] + 256 * d["MASK_HI"]
        d.update(FOUND=0, VALID=0)
        if d["MODE"] == 0 and d["CELL"] < 16:
            mask |= 1 << d["CELL"]
            d["VALID"] = 1
        elif d["MODE"] == 2:
            mask = 65535
            d["VALID"] = 1
        elif d["MODE"] == 1:
            indices = [i for i in range(16) if mask & (1 << i)]
            d.update(
                VALID=1, CELL=indices[0] if indices else 255, FOUND=int(bool(indices))
            )
            if indices:
                mask &= ~(1 << indices[0])
        d["MASK_HI"], d["MASK_LO"] = divmod(mask, 256)
    elif topic == "bounded-flood-fill":
        d.update(VALID=int(d["SEED"] < 16), CHANGED=0)
        if d["VALID"]:
            cells = [d[f"C{i}"] for i in range(16)]
            source = cells[d["SEED"]]
            if source != d["REPLACEMENT"]:
                pending = [d["SEED"]]
                seen = set()
                while pending:
                    i = pending.pop()
                    if i in seen or cells[i] != source:
                        continue
                    seen.add(i)
                    x, y = i % 4, i // 4
                    pending.extend(
                        ny * 4 + nx
                        for nx, ny in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
                        if 0 <= nx < 4 and 0 <= ny < 4
                    )
                d.update({f"C{i}": d["REPLACEMENT"] for i in seen})
                d["CHANGED"] = len(seen)
    elif topic == "cardinal-sight":
        a, b = d["FROM"], d["TO"]
        ok = a < 16 and b < 16 and (a // 4 == b // 4 or a % 4 == b % 4)
        d.update(VALID=int(ok), VISIBLE=0)
        if ok:
            stride = (1 if a // 4 == b // 4 else 4) * (1 if b >= a else -1)
            cells = range(a + stride, b + stride, stride) if a != b else []
            d["VISIBLE"] = int(all(d[f"C{i}"] == 0 for i in cells))
    elif topic == "reflected-axis":
        lo, hi, p = d["MINIMUM"], d["MAXIMUM"], d["POSITION"]
        ok = lo < hi and lo <= p <= hi and d["DIRECTION"] < 2
        d.update(VALID=int(ok), BOUNCES=0)
        if ok and d["DISTANCE"]:
            width = hi - lo
            z = p - lo if d["DIRECTION"] else 2 * width - (p - lo)
            end = z + d["DISTANCE"]
            fold = end % (2 * width)
            d["POSITION"] = lo + min(fold, 2 * width - fold)
            # Count boundaries crossed before a unit step, including the starting endpoint only when facing out.
            first = hi - p if d["DIRECTION"] else p - lo
            n = (
                0
                if d["DISTANCE"] <= first
                else 1 + (d["DISTANCE"] - first - 1) // width
            )
            d["BOUNCES"] = n
            d["DIRECTION"] ^= n % 2
    elif topic == "slope-height":
        d.update(SURFACE=255, VALID=0)
        if d["LOCAL_X"] < 8:
            heights = [d[f"H{i}"] for i in range(8)]
            value = (
                d["BASE_Y"] + heights[7 - d["LOCAL_X"] if d["MIRROR"] else d["LOCAL_X"]]
            )
            if value < 256:
                d.update(SURFACE=value, VALID=1)
    else:
        raise ValueError(topic)
    assert all(0 <= v < 256 for v in d.values()), (topic, before, d)
    return [d[k] for k in f]


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    fields = TOPICS[topic]["fields"]
    n = min(64, max(16, 1000 // len(fields)))
    rng = random.Random(1980 + list(TOPICS).index(topic))
    rows = []
    for i in range(n):
        d = {k: rng.randrange(256) for k in fields}
        if topic == "animation-timeline":
            d.update(
                FRAME_COUNT=3,
                DURATION=2 if custom else 3,
                FRAME=i % 5,
                TICKS=i % 4,
                FINISHED=0,
                LOOP=i % 2,
            )
        elif topic == "rational-tick-divider":
            d.update(
                PHASE=i % 7,
                NUMERATOR=[0, 1, 3, 5, 255][i % 5],
                DENOMINATOR=[1, 3, 5, 255, 0][i // 5 % 5],
            )
        elif topic == "pause-clock":
            d.update(
                TIME_LO=[0, 1, 254, 255][i % 4],
                TIME_HI=[0, 1, 255][i // 4 % 3],
                PAUSED=i % 2,
                RESET=int(i % 7 == 0),
            )
        elif topic == "input-sequence":
            d.update(PROGRESS=i % 6, SYMBOL=i // 6 % 5)
        elif topic == "input-chord":
            d.update(
                PREVIOUS=i % 2,
                REQUIRED=[0, 3, 5, 128][i // 2 % 4],
                FORBIDDEN=[0, 4, 1, 128][i // 8 % 4],
            )
        elif topic == "four-way-input":
            d.update(HELD=i % 16, LAST_AXIS=i // 16 % 4)
        elif topic == "analogue-deadzone":
            d.update(
                CENTRE=128,
                RADIUS=[0, 4, 8, 127, 128, 255][i % 6],
                SAMPLE=[0, 119, 120, 124, 128, 132, 136, 137, 255][i // 6 % 9],
            )
        elif topic == "weighted-choice":
            d.update(
                WEIGHT0=[0, 1, 2, 128, 255][i % 5],
                WEIGHT1=[0, 3, 128][i // 5 % 3],
                WEIGHT2=1,
                ROLL=[0, 1, 2, 3, 5, 255][i // 3 % 6],
            )
        elif topic == "shuffle-bag":
            d.update(REMAINING=i % 11, ROLL=i // 11 % 6, RESET=int(i % 9 == 0))
            d.update({f"B{j}": j for j in range(8)})
        elif topic == "waypoint-route":
            d.update(
                POSITION=i * 7 % 256,
                COUNT=i % 6,
                TARGET_INDEX=i // 6 % 6,
                SPEED=[0, 1, 4, 255][i % 4],
                LOOP=i % 2,
                FINISHED=0,
                P0=0,
                P1=17,
                P2=240,
                P3=255,
            )
        elif topic == "inventory-stacks":
            d.update(
                SLOT=i % 6,
                CAP=[0, 7, 9, 255][i // 6 % 4],
                AMOUNT=[0, 1, 6, 255][i % 4],
                REMOVE=i % 2,
            )
            d.update({f"C{j}": [0, 6, 9, 255][j] for j in range(4)})
        elif topic == "recipe-transaction":
            d.update(
                HAVE0=i % 5,
                HAVE1=i // 5 % 4,
                RESULT=i % 6,
                NEED0=2,
                NEED1=1,
                PRODUCE=[0, 1, 2, 255][i % 4],
                CAP=[0, 4, 255][i // 4 % 3],
            )
        elif topic == "dialogue-gates":
            d.update(
                FLAGS=i % 16,
                REQUIRED=1,
                FORBIDDEN=2 if i % 7 else 1,
                SET_MASK=2,
                CLEAR_MASK=1,
                ACCEPT=i % 2,
            )
        elif topic == "decimal-parser":
            d.update(
                VALUE=[0, 1, 24, 25, 26, 255][i % 6],
                CHARACTER=[0, 47, 48, 49, 53, 54, 57, 58, 255][i // 6 % 9],
            )
        elif topic == "stable-depth-order":
            d.update(COUNT=i % 11)
            d.update(
                {
                    f"Z{j}": (j if i % 3 == 0 else 7 - j if i % 3 == 1 else j % 2)
                    for j in range(8)
                }
            )
        elif topic == "dirty-cells":
            d.update(
                MODE=i % 4,
                CELL=i // 4 % 20,
                MASK_LO=[0, 1, 128, 255][i % 4],
                MASK_HI=[0, 1, 128, 255][i // 4 % 4],
            )
        elif topic == "bounded-flood-fill":
            d.update(SEED=i % 18, REPLACEMENT=i % 4)
            d.update(
                {
                    f"C{j}": 0
                    if i % 4 == 0
                    else (
                        j // 4
                        if i % 4 == 1
                        else j % 4
                        if i % 4 == 2
                        else (j + j // 4) % 2
                    )
                    for j in range(16)
                }
            )
        elif topic == "cardinal-sight":
            d.update(FROM=i % 18, TO=[0, 3, 12, 15][i // 4 % 4])
            d.update({f"C{j}": int(j == i % 16 and i % 3 == 0) for j in range(16)})
        elif topic == "reflected-axis":
            d.update(
                MINIMUM=[0, 1, 254][i % 3],
                MAXIMUM=[0, 2, 10, 255][i // 3 % 4],
                POSITION=[0, 1, 2, 8, 10, 254, 255][i // 4 % 7],
                DISTANCE=[0, 1, 2, 7, 255][i % 5],
                DIRECTION=i % 3,
            )
        elif topic == "slope-height":
            d.update(
                LOCAL_X=i % 10, BASE_Y=[0, 100, 250, 255][i // 10 % 4], MIRROR=i % 2
            )
            d.update({f"H{j}": 7 - j for j in range(8)})
        rows.append([d[k] for k in fields])
    return rows


def trace(topic: str, custom: bool = False) -> list[dict[str, int]]:
    return TOPICS[topic]["custom_trace" if custom else "trace"]


def packet(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    fields = TOPICS[topic]["fields"]
    n = len(fields)
    out = [165, list(TOPICS).index(topic), int(custom)] + [0] * n
    for row in cases(topic, custom):
        out += step(topic, row, custom)
    state = [0] * n
    for change in trace(topic, custom):
        for k, v in change.items():
            state[fields.index(k)] = v
        state = step(topic, state, custom, wrong)
        out += state
    return out + [239]


def preview(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    n = len(TOPICS[topic]["fields"])
    return (packet(topic, custom, wrong)[-1 - n : -1] + [0] * 8)[:8]
