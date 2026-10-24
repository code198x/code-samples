"""Independent integer, geometry and container reference contracts."""

from __future__ import annotations

import math
import random
from collections import deque

TOPICS = {
    "byte-product": {
        "title": "Multiply Two Bytes into a Word",
        "category": "framework",
        "fields": ["PRODUCT_LO", "PRODUCT_HI", "LEFT", "RIGHT"],
        "trace": [{"LEFT": 200, "RIGHT": 3}],
        "custom_trace": [{"LEFT": 255, "RIGHT": 255}],
    },
    "word-division": {
        "title": "Divide a Word by a Byte",
        "category": "framework",
        "fields": [
            "QUOTIENT_LO",
            "QUOTIENT_HI",
            "REMAINDER",
            "VALID",
            "NUMERATOR_LO",
            "NUMERATOR_HI",
            "DIVISOR",
        ],
        "trace": [{"NUMERATOR_LO": 232, "NUMERATOR_HI": 3, "DIVISOR": 7}],
        "custom_trace": [{"NUMERATOR_LO": 255, "NUMERATOR_HI": 255, "DIVISOR": 255}],
    },
    "integer-square-root": {
        "title": "Find an Integer Square Root",
        "category": "framework",
        "fields": ["ROOT", "REMAINDER_LO", "REMAINDER_HI", "NUMBER_LO", "NUMBER_HI"],
        "trace": [{"NUMBER_LO": 232, "NUMBER_HI": 3}],
        "custom_trace": [{"NUMBER_LO": 255, "NUMBER_HI": 255}],
    },
    "point-circle": {
        "title": "Test a Point Against a Circle",
        "category": "physics",
        "fields": [
            "HIT",
            "DX",
            "DY",
            "POINT_X",
            "POINT_Y",
            "CENTRE_X",
            "CENTRE_Y",
            "RADIUS",
        ],
        "trace": [{"POINT_X": 4, "POINT_Y": 4, "RADIUS": 5}],
        "custom_trace": [{"POINT_X": 3, "POINT_Y": 4, "RADIUS": 5}],
    },
    "byte-interpolation": {
        "title": "Interpolate Between Byte Endpoints",
        "category": "physics",
        "fields": ["VALUE", "START", "END", "FRACTION"],
        "trace": [{"START": 10, "END": 210, "FRACTION": 128}],
        "custom_trace": [{"START": 210, "END": 10, "FRACTION": 255}],
    },
    "grid-line-sight": {
        "title": "Trace a Thin Grid Line of Sight",
        "category": "ai",
        "fields": [
            "VISIBLE",
            "VALID",
            "FROM",
            "TO",
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
        "trace": [{"FROM": 0, "TO": 15, "C5": 1}],
        "custom_trace": [{"FROM": 0, "TO": 14, "C5": 0}],
    },
    "bounded-grid-path": {
        "title": "Find the First Step Along a Shortest Grid Path",
        "category": "ai",
        "fields": [
            "MOVE",
            "DISTANCE",
            "FOUND",
            "VALID",
            "FROM",
            "TO",
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
        "trace": [{"FROM": 0, "TO": 3, "C1": 1}],
        "custom_trace": [{"FROM": 0, "TO": 15}],
    },
    "trigger-transitions": {
        "title": "Report Trigger Enter, Stay and Exit Events",
        "category": "framework",
        "fields": ["ENTERED", "STAYED", "EXITED", "PREVIOUS", "CURRENT"],
        "trace": [{"CURRENT": 3}, {"CURRENT": 6}, {}],
        "custom_trace": [{"CURRENT": 128}, {"CURRENT": 0}, {"CURRENT": 128}],
    },
    "timed-status": {
        "title": "Service a Timed Status Effect",
        "category": "framework",
        "fields": [
            "PULSE",
            "REMAINING",
            "PHASE",
            "DURATION",
            "PERIOD",
            "APPLY",
            "VALID",
        ],
        "trace": [{"DURATION": 5, "PERIOD": 2, "APPLY": 1}, {"APPLY": 0}, {}, {}, {}],
        "custom_trace": [
            {"DURATION": 6, "PERIOD": 3, "APPLY": 1},
            {"APPLY": 0},
            {},
            {},
            {},
            {},
        ],
    },
    "checkpoint-state": {
        "title": "Capture and Restore a Checked Checkpoint",
        "category": "framework",
        "fields": [
            "RESULT",
            "SAVED",
            "LIVE_X",
            "LIVE_Y",
            "LIVE_RESOURCE",
            "MODE",
            "SAVED_X",
            "SAVED_Y",
            "SAVED_RESOURCE",
            "CHECKSUM",
        ],
        "trace": [
            {"LIVE_X": 20, "LIVE_Y": 30, "LIVE_RESOURCE": 4},
            {"LIVE_X": 99, "LIVE_Y": 88, "LIVE_RESOURCE": 0, "MODE": 1},
        ],
        "custom_trace": [
            {"LIVE_X": 250, "LIVE_Y": 1, "LIVE_RESOURCE": 255},
            {"LIVE_X": 0, "MODE": 1},
        ],
    },
    "spawn-timeline": {
        "title": "Service a Small Spawn Timeline",
        "category": "framework",
        "fields": [
            "EVENT",
            "FIRED",
            "INDEX",
            "WAIT",
            "COUNT",
            "DONE",
            "VALID",
            "E0",
            "E1",
            "E2",
            "E3",
            "L0",
            "L1",
            "L2",
            "L3",
        ],
        "trace": [
            {"COUNT": 3, "E0": 2, "E1": 4, "E2": 7, "L0": 0, "L1": 2, "L2": 1},
            {},
            {},
            {},
            {},
            {},
            {},
        ],
        "custom_trace": [{"COUNT": 2, "E0": 9, "E1": 3, "L0": 1, "L1": 0}, {}, {}, {}],
    },
    "packed-nibble-map": {
        "title": "Read and Update Packed Four-bit Cells",
        "category": "rendering",
        "fields": [
            "VALUE",
            "VALID",
            "CELL",
            "WRITE",
            "NEW_VALUE",
            "B0",
            "B1",
            "B2",
            "B3",
            "B4",
            "B5",
            "B6",
            "B7",
        ],
        "trace": [
            {"B1": 171, "CELL": 3},
            {"WRITE": 1, "NEW_VALUE": 5},
            {"WRITE": 0, "CELL": 2},
        ],
        "custom_trace": [{"CELL": 15, "WRITE": 1, "NEW_VALUE": 15}, {"WRITE": 0}],
    },
    "bounded-rle-encoder": {
        "title": "Encode a Small Run-length Block",
        "category": "framework",
        "fields": [
            "WRITTEN",
            "ERROR",
            "VALID",
            "INPUT_COUNT",
            "CAPACITY",
            "B0",
            "B1",
            "B2",
            "B3",
            "B4",
            "B5",
            "B6",
            "B7",
            "R0",
            "R1",
            "R2",
            "R3",
            "R4",
            "R5",
            "R6",
            "R7",
            "R8",
            "R9",
            "R10",
            "R11",
            "R12",
            "R13",
            "R14",
            "R15",
        ],
        "trace": [
            {
                "INPUT_COUNT": 6,
                "CAPACITY": 16,
                "B0": 65,
                "B1": 65,
                "B2": 65,
                "B3": 66,
                "B4": 66,
                "B5": 67,
            }
        ],
        "custom_trace": [
            {
                "INPUT_COUNT": 8,
                "CAPACITY": 16,
                "B0": 0,
                "B1": 1,
                "B2": 2,
                "B3": 3,
                "B4": 4,
                "B5": 5,
                "B6": 6,
                "B7": 7,
            }
        ],
    },
    "generation-handles": {
        "title": "Reject Stale Object Handles",
        "category": "framework",
        "fields": [
            "RESULT",
            "OUT_SLOT",
            "OUT_GENERATION",
            "VALID",
            "MODE",
            "SLOT",
            "GENERATION",
            "ACTIVE",
            "G0",
            "G1",
            "G2",
            "G3",
        ],
        "trace": [
            {},
            {"MODE": 1, "SLOT": 0, "GENERATION": 1},
            {"MODE": 0},
            {"MODE": 2, "SLOT": 0, "GENERATION": 2},
        ],
        "custom_trace": [{"G0": 255}, {"MODE": 2, "SLOT": 0, "GENERATION": 0}],
    },
    "stable-compaction": {
        "title": "Compact a Live Object Prefix",
        "category": "framework",
        "fields": [
            "COUNT",
            "REMOVED",
            "VALID",
            "F0",
            "F1",
            "F2",
            "F3",
            "F4",
            "F5",
            "F6",
            "F7",
            "I0",
            "I1",
            "I2",
            "I3",
            "I4",
            "I5",
            "I6",
            "I7",
        ],
        "trace": [
            {
                "COUNT": 6,
                "F0": 1,
                "F2": 1,
                "F4": 1,
                "F7": 1,
                "I0": 10,
                "I1": 11,
                "I2": 12,
                "I3": 13,
                "I4": 14,
                "I5": 15,
                "I6": 16,
                "I7": 99,
            }
        ],
        "custom_trace": [
            {
                "COUNT": 4,
                "F1": 1,
                "F3": 1,
                "I0": 20,
                "I1": 21,
                "I2": 22,
                "I3": 23,
                "I4": 24,
                "I5": 25,
                "I6": 26,
                "I7": 27,
            }
        ],
    },
    "motion-history": {
        "title": "Keep a Small Position History",
        "category": "framework",
        "fields": [
            "OUT_X",
            "OUT_Y",
            "VALID",
            "HEAD",
            "COUNT",
            "INPUT_X",
            "INPUT_Y",
            "LAG",
            "PUSH",
            "HX0",
            "HX1",
            "HX2",
            "HX3",
            "HX4",
            "HX5",
            "HX6",
            "HX7",
            "HY0",
            "HY1",
            "HY2",
            "HY3",
            "HY4",
            "HY5",
            "HY6",
            "HY7",
        ],
        "trace": [
            {"INPUT_X": 10, "INPUT_Y": 20, "PUSH": 1},
            {"INPUT_X": 30, "INPUT_Y": 40},
            {"INPUT_X": 50, "INPUT_Y": 60},
            {"PUSH": 0, "LAG": 2},
        ],
        "custom_trace": [
            {"INPUT_X": 0, "INPUT_Y": 1, "PUSH": 1},
            {"INPUT_X": 1, "INPUT_Y": 2, "PUSH": 1},
            {"INPUT_X": 2, "INPUT_Y": 3, "PUSH": 1},
            {"INPUT_X": 3, "INPUT_Y": 4, "PUSH": 1},
            {"INPUT_X": 4, "INPUT_Y": 5, "PUSH": 1},
            {"INPUT_X": 5, "INPUT_Y": 6, "PUSH": 1},
            {"INPUT_X": 6, "INPUT_Y": 7, "PUSH": 1},
            {"INPUT_X": 7, "INPUT_Y": 8, "PUSH": 1},
            {"INPUT_X": 8, "INPUT_Y": 9, "PUSH": 1},
            {"PUSH": 0, "LAG": 7},
        ],
    },
    "bounded-bit-reader": {
        "title": "Read Bits from a Bounded Data Block",
        "category": "framework",
        "fields": ["VALUE", "VALID", "CURSOR", "COUNT", "B0", "B1", "B2", "B3"],
        "trace": [{"B0": 171, "B1": 192, "COUNT": 4}, {}, {}],
        "custom_trace": [{"B0": 171, "B1": 192, "COUNT": 8}, {}],
    },
    "pixel-mask-collision": {
        "title": "Test Two Small Opaque Pixel Masks",
        "category": "physics",
        "fields": [
            "HIT",
            "ROW",
            "SHIFT_X",
            "SHIFT_Y",
            "P0",
            "P1",
            "P2",
            "P3",
            "P4",
            "P5",
            "P6",
            "P7",
            "Q0",
            "Q1",
            "Q2",
            "Q3",
            "Q4",
            "Q5",
            "Q6",
            "Q7",
        ],
        "trace": [{"SHIFT_X": 1, "P0": 128, "Q0": 128}],
        "custom_trace": [{"SHIFT_X": 0, "P0": 128, "Q0": 128}],
    },
    "logical-envelope": {
        "title": "Service a Logical Attack–Decay–Sustain–Release Envelope",
        "category": "audio",
        "fields": [
            "LEVEL",
            "PHASE",
            "PREVIOUS",
            "VALID",
            "GATE",
            "ATTACK",
            "DECAY",
            "SUSTAIN",
            "RELEASE",
        ],
        "trace": [
            {"GATE": 1, "ATTACK": 3, "DECAY": 2, "SUSTAIN": 6, "RELEASE": 4},
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
            {"GATE": 1, "ATTACK": 15, "DECAY": 4, "SUSTAIN": 4, "RELEASE": 4},
            {},
            {},
            {"GATE": 0},
            {},
            {},
        ],
    },
    "bounded-undo": {
        "title": "Keep a Bounded Cell-edit Undo Log",
        "category": "framework",
        "fields": [
            "RESULT",
            "VALID",
            "COUNT",
            "MODE",
            "CELL",
            "VALUE",
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
            "J0",
            "J1",
            "J2",
            "J3",
            "K0",
            "K1",
            "K2",
            "K3",
        ],
        "trace": [{"CELL": 0, "VALUE": 7}, {"CELL": 1, "VALUE": 9}, {"MODE": 1}, {}],
        "custom_trace": [{"CELL": 0, "VALUE": 7}, {"VALUE": 9}, {"MODE": 1}],
    },
}


def step(
    topic: str, row: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    fields = TOPICS[topic]["fields"]
    d = dict(zip(fields, row, strict=True))
    if wrong:
        if topic == "byte-product":
            d["RIGHT"] = 1
        elif topic == "word-division":
            d["NUMERATOR_HI"] = 0
        elif topic == "integer-square-root":
            d["NUMBER_HI"] = 0
        elif topic == "point-circle":
            d["POINT_Y"] = d["CENTRE_Y"]
        elif topic == "byte-interpolation":
            d["FRACTION"] = 0
        elif topic == "grid-line-sight":
            d["C5"] = 0
        elif topic == "bounded-grid-path":
            d["C1"] = 0
        elif topic == "trigger-transitions":
            d["PREVIOUS"] = 0
        elif topic == "timed-status":
            d["APPLY"] = 1
        elif topic == "checkpoint-state":
            d["SAVED_RESOURCE"] = 0
        elif topic == "spawn-timeline":
            d["INDEX"] = 0
        elif topic == "packed-nibble-map":
            d["CELL"] = 0
        elif topic == "bounded-rle-encoder":
            d["CAPACITY"] = 0
        elif topic == "generation-handles":
            d["GENERATION"] = 0
        elif topic == "stable-compaction":
            d["COUNT"] = 8
        elif topic == "motion-history":
            d["HEAD"] = 0
        elif topic == "bounded-bit-reader":
            d["CURSOR"] = 0
        elif topic == "pixel-mask-collision":
            d["SHIFT_X"] = 0
        elif topic == "logical-envelope":
            d["PREVIOUS"] = 0
        elif topic == "bounded-undo":
            d["COUNT"] = 0
    if topic == "byte-product":
        d["PRODUCT_HI"], d["PRODUCT_LO"] = divmod(d["LEFT"] * d["RIGHT"], 256)
    elif topic == "word-division":
        n = d["NUMERATOR_LO"] + 256 * d["NUMERATOR_HI"]
        q, rem = divmod(n, d["DIVISOR"]) if d["DIVISOR"] else (0, 0)
        d["QUOTIENT_HI"], d["QUOTIENT_LO"] = divmod(q, 256)
        d.update(REMAINDER=rem, VALID=int(d["DIVISOR"] != 0))
    elif topic == "integer-square-root":
        n = d["NUMBER_LO"] + 256 * d["NUMBER_HI"]
        v = math.isqrt(n)
        d["REMAINDER_HI"], d["REMAINDER_LO"] = divmod(n - v * v, 256)
        d["ROOT"] = v
    elif topic == "point-circle":
        dx = abs(d["POINT_X"] - d["CENTRE_X"])
        dy = abs(d["POINT_Y"] - d["CENTRE_Y"])
        d.update(DX=dx, DY=dy, HIT=int(dx * dx + dy * dy <= d["RADIUS"] ** 2))
    elif topic == "byte-interpolation":
        delta = d["END"] - d["START"]
        travel = abs(delta) * d["FRACTION"] // 255
        d["VALUE"] = d["START"] + (travel if delta >= 0 else -travel)
    elif topic == "grid-line-sight":
        a, b = d["FROM"], d["TO"]
        d.update(VISIBLE=0, VALID=int(a < 16 and b < 16))
        if d["VALID"]:
            x, y = a % 4, a // 4
            tx, ty = b % 4, b // 4
            dx, dy = abs(tx - x), abs(ty - y)
            sx = 1 if tx >= x else -1
            sy = 1 if ty >= y else -1
            # Sample the dominant-axis ideal line. Exact halves round towards the source.
            points = []
            if dx >= dy and dx:
                points = [
                    (x + sx * k, y + sy * ((2 * k * dy + dx - 1) // (2 * dx)))
                    for k in range(1, dx + 1)
                ]
            elif dy:
                points = [
                    (x + sx * ((2 * k * dx + dy - 1) // (2 * dy)), y + sy * k)
                    for k in range(1, dy + 1)
                ]
            d["VISIBLE"] = int(all(d[f"C{py * 4 + px}"] == 0 for px, py in points))
    elif topic == "bounded-grid-path":
        a, b = d["FROM"], d["TO"]
        d.update(MOVE=0, DISTANCE=255, FOUND=0, VALID=int(a < 16 and b < 16))
        if d["VALID"] and d[f"C{a}"] == 0 and d[f"C{b}"] == 0:
            distance = {b: 0}
            q = deque([b])
            while q:
                cell = q.popleft()
                x, y = cell % 4, cell // 4
                for nx, ny in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]:
                    n = ny * 4 + nx
                    if (
                        0 <= nx < 4
                        and 0 <= ny < 4
                        and n not in distance
                        and d[f"C{n}"] == 0
                    ):
                        distance[n] = distance[cell] + 1
                        q.append(n)
            if a in distance:
                d.update(DISTANCE=distance[a], FOUND=1)
                if a != b:
                    x, y = a % 4, a // 4
                    choices = [
                        (1, x - 1, y),
                        (2, x + 1, y),
                        (3, x, y - 1),
                        (4, x, y + 1),
                    ]
                    d["MOVE"] = next(
                        move
                        for move, nx, ny in choices
                        if 0 <= nx < 4
                        and 0 <= ny < 4
                        and distance.get(ny * 4 + nx, 255) == distance[a] - 1
                    )
    elif topic == "trigger-transitions":
        previous = {i for i in range(8) if d["PREVIOUS"] & (1 << i)}
        current = {i for i in range(8) if d["CURRENT"] & (1 << i)}
        for name, items in [
            ("ENTERED", current - previous),
            ("STAYED", current & previous),
            ("EXITED", previous - current),
        ]:
            d[name] = sum(1 << i for i in items)
        d["PREVIOUS"] = d["CURRENT"]
    elif topic == "timed-status":
        ok = d["PERIOD"] != 0 and d["PHASE"] < d["PERIOD"]
        d.update(VALID=int(ok), PULSE=0)
        if ok:
            remaining = d["DURATION"] if d["APPLY"] else d["REMAINING"]
            phase = 0 if d["APPLY"] else d["PHASE"]
            if remaining:
                remaining -= 1
                elapsed = phase + 1
                d["PULSE"] = int(elapsed == d["PERIOD"])
                phase = elapsed % d["PERIOD"]
            d.update(REMAINING=remaining, PHASE=phase if remaining else 0)
    elif topic == "checkpoint-state":
        d["RESULT"] = 0
        if d["MODE"] == 0:
            d.update(
                SAVED_X=d["LIVE_X"],
                SAVED_Y=d["LIVE_Y"],
                SAVED_RESOURCE=d["LIVE_RESOURCE"],
                SAVED=1,
            )
            d["CHECKSUM"] = d["SAVED_X"] ^ d["SAVED_Y"] ^ d["SAVED_RESOURCE"]
            d["RESULT"] = 1
        elif (
            d["MODE"] == 1
            and d["SAVED"] == 1
            and d["CHECKSUM"] == d["SAVED_X"] ^ d["SAVED_Y"] ^ d["SAVED_RESOURCE"]
        ):
            d.update(
                LIVE_X=d["SAVED_X"],
                LIVE_Y=d["SAVED_Y"],
                LIVE_RESOURCE=d["SAVED_RESOURCE"],
                RESULT=1,
            )
    elif topic == "spawn-timeline":
        ok = 0 < d["COUNT"] <= 4 and d["INDEX"] < d["COUNT"]
        d.update(EVENT=255, FIRED=0, VALID=int(ok))
        if ok and not d["DONE"]:
            if d["WAIT"] < d[f"L{d['INDEX']}"]:
                d["WAIT"] += 1
            else:
                d.update(EVENT=d[f"E{d['INDEX']}"], FIRED=1, WAIT=0)
                if d["INDEX"] + 1 < d["COUNT"]:
                    d["INDEX"] += 1
                else:
                    d["DONE"] = 1
    elif topic == "packed-nibble-map":
        ok = d["CELL"] < 16 and (not d["WRITE"] or d["NEW_VALUE"] < 16)
        d.update(VALUE=0, VALID=int(ok))
        if ok:
            cells = [n for i in range(8) for n in divmod(d[f"B{i}"], 16)]
            if d["WRITE"]:
                cells[d["CELL"]] = d["NEW_VALUE"]
                d.update(
                    {f"B{i}": 16 * cells[2 * i] + cells[2 * i + 1] for i in range(8)}
                )
            d["VALUE"] = cells[d["CELL"]]
    elif topic == "bounded-rle-encoder":
        ok = d["INPUT_COUNT"] <= 8 and d["CAPACITY"] <= 16
        d.update(WRITTEN=0, ERROR=0 if ok else 1, VALID=int(ok))
        if ok:
            import itertools

            pairs = [
                (len(list(items)), value)
                for value, items in itertools.groupby(
                    d[f"B{i}"] for i in range(d["INPUT_COUNT"])
                )
            ]
            encoded = [n for pair in pairs for n in pair]
            if len(encoded) > d["CAPACITY"]:
                d["ERROR"] = 2
            else:
                d.update({f"R{i}": v for i, v in enumerate(encoded)})
                d["WRITTEN"] = len(encoded)
    elif topic == "generation-handles":
        ok = d["ACTIVE"] <= 15 and d["MODE"] < 3 and (d["MODE"] == 0 or d["SLOT"] < 4)
        d.update(RESULT=0, OUT_SLOT=255, OUT_GENERATION=0, VALID=int(ok))
        if ok:
            active = {i for i in range(4) if d["ACTIVE"] & (1 << i)}
            if d["MODE"] == 0:
                free = sorted(set(range(4)) - active)
                if free:
                    slot = free[0]
                    d[f"G{slot}"] = (d[f"G{slot}"] + 1) % 256
                    d.update(RESULT=1, OUT_SLOT=slot, OUT_GENERATION=d[f"G{slot}"])
                    active.add(slot)
            elif d["SLOT"] in active and d["GENERATION"] == d[f"G{d['SLOT']}"]:
                d.update(RESULT=1, OUT_SLOT=d["SLOT"], OUT_GENERATION=d["GENERATION"])
                if d["MODE"] == 1:
                    active.remove(d["SLOT"])
            d["ACTIVE"] = sum(1 << i for i in active)
    elif topic == "stable-compaction":
        n = d["COUNT"]
        ok = n <= 8
        d.update(REMOVED=0, VALID=int(ok))
        if ok:
            pairs = [(d[f"F{i}"], d[f"I{i}"]) for i in range(n) if d[f"F{i}"]]
            d.update(COUNT=len(pairs), REMOVED=n - len(pairs))
            pairs += [(0, 0)] * (n - len(pairs))
            for i, (flag, item) in enumerate(pairs):
                d[f"F{i}"] = flag
                d[f"I{i}"] = item
    elif topic == "motion-history":
        d.update(OUT_X=0, OUT_Y=0, VALID=0)
        if d["HEAD"] < 8 and d["COUNT"] <= 8:
            if d["PUSH"]:
                d[f"HX{d['HEAD']}"] = d["INPUT_X"]
                d[f"HY{d['HEAD']}"] = d["INPUT_Y"]
                d["HEAD"] = (d["HEAD"] + 1) % 8
                d["COUNT"] = min(8, d["COUNT"] + 1)
            if d["LAG"] < d["COUNT"]:
                chronological = [
                    (d[f"HX{i}"], d[f"HY{i}"])
                    for i in [
                        (d["HEAD"] - d["COUNT"] + k) % 8 for k in range(d["COUNT"])
                    ]
                ]
                x, y = chronological[-1 - d["LAG"]]
                d.update(OUT_X=x, OUT_Y=y, VALID=1)
    elif topic == "bounded-bit-reader":
        ok = d["COUNT"] <= 8 and d["CURSOR"] <= 32 and d["CURSOR"] + d["COUNT"] <= 32
        d.update(VALUE=0, VALID=int(ok))
        if ok:
            bits = "".join(f"{d[f'B{i}']:08b}" for i in range(4))
            part = bits[d["CURSOR"] : d["CURSOR"] + d["COUNT"]]
            d["VALUE"] = int(part, 2) if part else 0
            d["CURSOR"] += d["COUNT"]
    elif topic == "pixel-mask-collision":
        d.update(HIT=0, ROW=255)
        points = {(x, y) for y in range(8) for x in range(8) if d[f"P{y}"] & (128 >> x)}
        other = {
            (x + d["SHIFT_X"], y + d["SHIFT_Y"])
            for y in range(8)
            for x in range(8)
            if d[f"Q{y}"] & (128 >> x)
        }
        intersection = points & other
        if intersection:
            d.update(HIT=1, ROW=min(y for x, y in intersection))
    elif topic == "logical-envelope":
        ok = (
            d["LEVEL"] <= 15
            and d["PHASE"] <= 4
            and all(1 <= d[k] <= 15 for k in ["ATTACK", "DECAY", "RELEASE"])
            and d["SUSTAIN"] <= 15
        )
        d["VALID"] = int(ok)
        if ok:
            gate = bool(d["GATE"])
            level, phase = d["LEVEL"], d["PHASE"]
            if gate and not d["PREVIOUS"]:
                level, phase = 0, 1
            elif not gate and phase:
                phase = 4
            if phase == 0:
                level = 0
            elif phase == 1:
                level = min(15, level + d["ATTACK"])
                phase = 2 if level == 15 else 1
            elif phase == 2:
                level = max(d["SUSTAIN"], level - d["DECAY"])
                phase = 3 if level == d["SUSTAIN"] else 2
            elif phase == 3:
                level = d["SUSTAIN"]
            else:
                level = max(0, level - d["RELEASE"])
                phase = 0 if level == 0 else 4
            d.update(LEVEL=level, PHASE=phase, PREVIOUS=int(gate))
    elif topic == "bounded-undo":
        d.update(RESULT=0, VALID=0)
        count = d["COUNT"]
        mode = d["MODE"]
        if count <= 4 and mode < 3:
            if mode == 2:
                d.update(COUNT=0, RESULT=1, VALID=1)
            elif mode == 0:
                if d["CELL"] < 16:
                    d["VALID"] = 1
                    if count < 4:
                        d[f"J{count}"] = d["CELL"]
                        d[f"K{count}"] = d[f"C{d['CELL']}"]
                        d[f"C{d['CELL']}"] = d["VALUE"]
                        d.update(COUNT=count + 1, RESULT=1)
            else:
                d["VALID"] = 1
                if count:
                    cell = d[f"J{count - 1}"]
                    if cell >= 16:
                        d["VALID"] = 0
                    else:
                        d[f"C{cell}"] = d[f"K{count - 1}"]
                        d.update(COUNT=count - 1, RESULT=1)
    else:
        raise ValueError(topic)
    assert all(0 <= v < 256 for v in d.values()), (topic, d)
    return [d[k] for k in fields]


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    fields = TOPICS[topic]["fields"]
    n = min(64, max(16, 1000 // len(fields)))
    rng = random.Random(1981 + list(TOPICS).index(topic))
    rows = []
    for i in range(n):
        d = {k: rng.randrange(256) for k in fields}
        if topic == "byte-product":
            d.update(
                LEFT=[0, 1, 15, 127, 128, 129, 254, 255][i % 8],
                RIGHT=[0, 1, 2, 3, 127, 128, 254, 255][i // 8],
            )
        elif topic == "word-division":
            num = [0, 1, 255, 256, 257, 32768, 65534, 65535][i % 8]
            d.update(
                NUMERATOR_LO=num % 256,
                NUMERATOR_HI=num // 256,
                DIVISOR=[0, 1, 2, 7, 128, 254, 255, 3][i // 8],
            )
        elif topic == "integer-square-root":
            num = (
                [
                    0,
                    1,
                    2,
                    3,
                    4,
                    15,
                    16,
                    17,
                    254,
                    255,
                    256,
                    257,
                    65024,
                    65025,
                    65534,
                    65535,
                ][i % 16]
                if i < 32
                else rng.randrange(65536)
            )
            d.update(NUMBER_LO=num % 256, NUMBER_HI=num // 256)
        elif topic == "point-circle":
            d.update(
                POINT_X=[0, 3, 4, 5, 127, 128, 254, 255][i % 8],
                POINT_Y=[0, 4, 5, 127, 128, 254, 255, 255][i // 8],
                CENTRE_X=0 if i % 3 else 128,
                CENTRE_Y=0 if i % 3 else 128,
                RADIUS=[0, 1, 5, 127, 128, 254, 255, 255][i // 8],
            )
            if i < 8:
                d.update(
                    POINT_X=[3, 4, 255, 255, 0, 128, 255, 5][i],
                    POINT_Y=[4, 4, 255, 0, 0, 128, 255, 0][i],
                    CENTRE_X=0,
                    CENTRE_Y=0,
                    RADIUS=[5, 5, 255, 255, 0, 128, 254, 5][i],
                )
        elif topic == "byte-interpolation":
            d.update(
                START=[0, 255, 10, 210][i % 4],
                END=[255, 0, 210, 10][i % 4],
                FRACTION=[0, 1, 2, 63, 127, 128, 254, 255][i // 4 % 8],
            )
        elif topic in ["grid-line-sight", "bounded-grid-path"]:
            d.update(FROM=i % 16, TO=15 - i % 16)
            d.update(
                {
                    f"C{j}": int(
                        (i // 8) % 4 == 1
                        and j in [1, 5, 9]
                        or (i // 8) % 4 == 2
                        and j in [4, 5, 6, 7]
                    )
                    for j in range(16)
                }
            )
            if i == n - 1:
                d["FROM"] = 255
            if i == n - 2:
                d["TO"] = 16
            if i == n - 3:
                d.update(FROM=0, TO=15, **{f"C{j}": 0 for j in range(16)})
        elif topic == "trigger-transitions":
            d.update(
                PREVIOUS=[0, 1, 128, 255][i % 4],
                CURRENT=[0, 1, 2, 3, 127, 128, 254, 255][i // 4 % 8],
            )
        elif topic == "timed-status":
            d.update(
                REMAINING=[0, 1, 5, 255][i % 4],
                PHASE=[0, 1, 254, 255][i // 4 % 4],
                DURATION=[0, 1, 5, 255][i // 4 % 4],
                PERIOD=[0, 1, 2, 255][i // 16 % 4],
                APPLY=i % 2,
            )
        elif topic == "checkpoint-state":
            d.update(
                MODE=i % 4,
                SAVED=i // 4 % 3,
                SAVED_X=i,
                SAVED_Y=255 - i,
                SAVED_RESOURCE=4,
            )
            d["CHECKSUM"] = d["SAVED_X"] ^ d["SAVED_Y"] ^ d["SAVED_RESOURCE"]
            if i % 7 == 0:
                d["CHECKSUM"] ^= 1
        elif topic == "spawn-timeline":
            d.update(
                COUNT=i % 6,
                INDEX=i // 6 % 6,
                WAIT=[0, 1, 254, 255][i % 4],
                DONE=int(i % 5 == 0),
                E0=0,
                E1=2,
                E2=255,
                E3=7,
                L0=0,
                L1=1,
                L2=2,
                L3=255,
            )
        elif topic == "packed-nibble-map":
            d.update(
                CELL=i % 20, WRITE=i // 4 % 2, NEW_VALUE=[0, 1, 15, 16, 255][i // 8 % 5]
            )
        elif topic == "bounded-rle-encoder":
            d.update(
                INPUT_COUNT=i % 10,
                CAPACITY=[0, 1, 2, 3, 4, 6, 8, 15, 16, 17, 255][i // 3 % 11],
            )
            d.update(
                {
                    f"B{j}": 65 if i % 3 == 0 else 65 + j % 2 if i % 3 == 1 else j
                    for j in range(8)
                }
            )
            d.update({f"R{j}": 144 + j for j in range(16)})
            if i < 6:
                d.update(INPUT_COUNT=8, CAPACITY=[16, 15, 0, 2, 1, 17][i])
        elif topic == "generation-handles":
            d.update(
                MODE=i % 5,
                SLOT=i // 5 % 6,
                ACTIVE=[0, 1, 5, 15, 16, 255][i // 6 % 6],
                GENERATION=[0, 1, 255][i % 3],
                G0=0,
                G1=255,
                G2=1,
                G3=14,
            )
            if i < 4:
                d.update(MODE=0, ACTIVE=[0, 1, 7, 15][i], G0=255)
        elif topic == "stable-compaction":
            d.update(COUNT=i % 11)
            d.update({f"F{j}": ([0, 1, 255][(i + j) % 3]) for j in range(8)})
            d.update({f"I{j}": 10 + j for j in range(8)})
        elif topic == "motion-history":
            d.update(
                HEAD=i % 10,
                COUNT=i // 2 % 11,
                LAG=i // 3 % 10,
                PUSH=i % 2,
                INPUT_X=i,
                INPUT_Y=255 - i,
            )
            d.update({f"HX{j}": j for j in range(8)})
            d.update({f"HY{j}": 100 + j for j in range(8)})
        elif topic == "bounded-bit-reader":
            d.update(
                CURSOR=[0, 1, 7, 8, 15, 24, 31, 32, 33, 255][i % 10],
                COUNT=[0, 1, 4, 7, 8, 9, 255][i // 10 % 7],
                B0=171,
                B1=192,
                B2=0,
                B3=255,
            )
        elif topic == "pixel-mask-collision":
            d.update(SHIFT_X=i % 10, SHIFT_Y=i // 5 % 10)
            d.update({f"P{j}": [0, 128, 170, 255][i % 4] for j in range(8)})
            d.update({f"Q{j}": [0, 128, 85, 255][i // 4 % 4] for j in range(8)})
        elif topic == "logical-envelope":
            d.update(
                LEVEL=[0, 1, 6, 15, 16, 255][i % 6],
                PHASE=i // 6 % 7,
                PREVIOUS=i % 2,
                GATE=i // 2 % 2,
                ATTACK=[0, 1, 3, 15, 16, 255][i // 6 % 6],
                DECAY=2,
                SUSTAIN=[0, 6, 15, 16][i // 3 % 4],
                RELEASE=4,
            )
        elif topic == "bounded-undo":
            d.update(
                COUNT=i % 6,
                MODE=i // 6 % 4,
                CELL=i % 18,
                VALUE=77,
                J0=0,
                J1=1,
                J2=15,
                J3=16,
                K0=10,
                K1=11,
                K2=12,
                K3=13,
            )
        rows.append([d[k] for k in fields])
    return rows


def trace(topic: str, custom: bool = False) -> list[dict[str, int]]:
    return TOPICS[topic]["custom_trace" if custom else "trace"]


def packet(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    fields = TOPICS[topic]["fields"]
    out = [165, list(TOPICS).index(topic), int(custom)] + [0] * len(fields)
    for row in cases(topic, custom):
        out += step(topic, row, custom)
    state = [0] * len(fields)
    for change in trace(topic, custom):
        for field, value in change.items():
            state[fields.index(field)] = value
        state = step(topic, state, custom, wrong)
        out += state
    return out + [239]


def preview(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    n = len(TOPICS[topic]["fields"])
    return (packet(topic, custom, wrong)[-1 - n : -1] + [0] * 8)[:8]
