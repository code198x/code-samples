"""Integer contracts for the ten reusable gameplay components.

The native callers contain their own byte arithmetic. This model describes
outcomes with unbounded integers, lists and sets; no emulator state is injected.
"""

from __future__ import annotations

TOPICS = {
    "resource-wallet": ("Resource Counters", ["BALANCE", "AMOUNT", "MODE", "OK"]),
    "score-counter": (
        "A Saturating 16-bit Score",
        ["SCORE_LO", "SCORE_HI", "ADD_LO", "ADD_HI", "CLIPPED"],
    ),
    "quest-flags": ("Quest and Inventory Flags", ["FLAGS", "MASK", "MODE", "ALL_SET"]),
    "event-queue": (
        "A Bounded Event Queue",
        ["HEAD", "TAIL", "COUNT", "VALUE", "MODE", "OK", "B0", "B1", "B2", "B3"],
    ),
    "input-repeat": ("Menu Key Repeat", ["HELD", "WAS_HELD", "TIMER", "PULSE"]),
    "approach-target": (
        "Approach a Target Without Overshoot",
        ["POSITION", "TARGET", "STEP", "ARRIVED"],
    ),
    "endpoint-patrol": (
        "Patrol Between Two Endpoints",
        ["POSITION", "LOWER", "UPPER", "DIRECTION"],
    ),
    "manhattan-distance": (
        "Manhattan Distance",
        ["AX", "AY", "BX", "BY", "DIST_LO", "DIST_HI"],
    ),
    "priority-arbiter": (
        "Choose the Highest-priority Request",
        ["PRESENT", "ID", "PRIORITY", "REQUEST_ID", "REQUEST_PRIORITY", "ACCEPTED"],
    ),
    "decimal-format": (
        "Format a 16-bit Decimal Number",
        [
            "VALUE_LO",
            "VALUE_HI",
            "DIGIT0",
            "DIGIT1",
            "DIGIT2",
            "DIGIT3",
            "DIGIT4",
            "WORK_LO",
            "WORK_HI",
        ],
    ),
}


def step(
    topic: str, state: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    s = list(state)
    if wrong:
        if topic == "resource-wallet":
            s[2] = 0
        elif topic == "score-counter":
            s[3] = 0
        elif topic == "quest-flags":
            s[1] = 3
        elif topic == "event-queue" and s[4] == 1:
            s[0:3] = [0, 0, 0]
        elif topic == "input-repeat":
            s[1:3] = [0, 0]
        elif topic == "approach-target":
            s[0] = (s[0] + s[2]) % 256
            s[3] = int(s[0] == s[1])
            return s
        elif topic == "endpoint-patrol":
            s[0] = (s[0] + (-1 if s[3] else 1)) % 256
            if s[0] > s[2] or s[0] < s[1]:
                s[3] = 1 - int(bool(s[3]))
            return s
        elif topic == "priority-arbiter":
            s[0] = 0
        elif topic == "decimal-format":
            s[1] = 0
    if topic == "resource-wallet":
        value, amount, mode, _ = s
        ok = 0
        if mode == 0:
            value = min(255, value + amount)
            ok = 1
        elif mode == 1 and value >= amount:
            value -= amount
            ok = 1
        s = [value, amount, mode, ok]
    elif topic == "score-counter":
        value = s[0] + 256 * s[1]
        amount = s[2] + 256 * s[3]
        cap = 999 if custom else 65535
        total = value + amount
        s[0:2] = [min(cap, total) % 256, min(cap, total) // 256]
        s[4] = int(total > cap)
    elif topic == "quest-flags":
        if s[2] == 1:
            s[0] |= s[1]
        elif s[2] == 2:
            s[0] &= 255 - s[1]
        s[3] = int((s[0] & s[1]) == s[1])
    elif topic == "event-queue":
        cap = 2 if custom else 4
        s[5] = 0
        if s[4] == 1 and s[2] < cap:
            s[6 + s[1]] = s[3]
            s[1] = (s[1] + 1) % cap
            s[2] += 1
            s[5] = 1
        elif s[4] == 2 and s[2] > 0:
            s[3] = s[6 + s[0]]
            s[0] = (s[0] + 1) % cap
            s[2] -= 1
            s[5] = 1
    elif topic == "input-repeat":
        held = bool(s[0])
        previous = bool(s[1])
        timer = s[2]
        pulse = 0
        if not held:
            timer = 0
        elif not previous:
            timer = 6 if custom else 4
            pulse = 1
        else:
            timer = max(0, timer - 1)
            if timer == 0:
                timer = 3 if custom else 2
                pulse = 1
        s = [s[0], int(held), timer, pulse]
    elif topic == "approach-target":
        pos, target, amount, _ = s
        pos += (1 if target > pos else -1 if target < pos else 0) * min(
            amount, abs(target - pos)
        )
        s = [pos, target, amount, int(pos == target)]
    elif topic == "endpoint-patrol":
        pos, lo, hi, direction = s
        if lo == hi:
            s = [lo, lo, hi, 0]
        else:
            direction = int(bool(direction))
            if pos == lo:
                direction = 0
            elif pos == hi:
                direction = 1
            s = [pos + (-1 if direction else 1), lo, hi, direction]
    elif topic == "manhattan-distance":
        total = abs(s[0] - s[2]) + abs(s[1] - s[3])
        s[4:6] = [total % 256, 0 if wrong else total // 256]
    elif topic == "priority-arbiter":
        s[5] = 0
        if not s[0] or s[4] > s[2]:
            s[0:3] = [1, s[3], s[4]]
            s[5] = 1
    elif topic == "decimal-format":
        value = s[0] + 256 * s[1]
        s[2:7] = list(f"{value:05d}".encode("ascii"))
        s[7:9] = [0, 0]
    else:
        raise ValueError(topic)
    return s


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    import random

    rng = random.Random(1980 + list(TOPICS).index(topic))
    edges = [0, 1, 2, 3, 127, 128, 254, 255]
    rows = []
    for i in range(96):
        s = [rng.randrange(256) for _ in TOPICS[topic][1]]
        a = edges[i % 8]
        b = edges[(i // 8) % 8]
        if topic == "resource-wallet":
            s = [a, b, (i // 32) % 3, 255]
        elif topic == "score-counter":
            cap = 999 if custom else 65535
            values = [0, 1, 255, 256, cap - 1, cap]
            value = values[i % 6] if i < 36 else rng.randrange(cap + 1)
            amount = (
                [0, 1, 255, 256, 32768, 65535][(i // 6) % 6]
                if i < 36
                else rng.randrange(65536)
            )
            s = [value % 256, value // 256, amount % 256, amount // 256, 255]
        elif topic == "quest-flags":
            s = [a, b, (i // 32) % 3, 255]
        elif topic == "event-queue":
            cap = 2 if custom else 4
            head = i % cap
            count = (i // cap) % (cap + 1)
            s = [
                head,
                (head + count) % cap,
                count,
                a,
                (i // 24) % 4,
                255,
                17,
                34,
                51,
                68,
            ]
        elif topic == "input-repeat" or topic == "approach-target":
            s = [a, b, edges[(i // 16) % 8], 255]
        elif topic == "endpoint-patrol":
            lo, hi = sorted((a, b))
            pos = lo if i % 3 == 0 else hi if i % 3 == 1 else (lo + hi) // 2
            s = [pos, lo, hi, edges[(i // 16) % 8]]
        elif topic == "manhattan-distance":
            s = (
                [a, b, 255 - a, 255 - b, 255, 255]
                if i < 64
                else [rng.randrange(256) for _ in range(4)] + [255, 255]
            )
        elif topic == "priority-arbiter":
            s = [i % 2, a, b, 255 - a, edges[(i // 16) % 8], 255]
        elif topic == "decimal-format":
            values = [
                0,
                1,
                9,
                10,
                99,
                100,
                255,
                256,
                999,
                1000,
                9999,
                10000,
                32767,
                32768,
                65534,
                65535,
            ]
            value = values[i % 16] if i < 16 else rng.randrange(65536)
            s = [value % 256, value // 256, 255, 255, 255, 255, 255, 255, 255]
        rows.append(s)
    return rows


def trace(topic: str, custom: bool = False) -> list[dict[int, int]]:
    if topic == "resource-wallet":
        return [
            {0: 3, 1: 2 if custom else 5, 2: 1},
            {1: 255, 2: 0},
            {1: 250, 2: 1},
            {1: 6, 2: 1},
        ]
    if topic == "score-counter":
        return [{0: 250, 1: 0, 2: 44, 3: 1}, {2: 255, 3: 255}]
    if topic == "quest-flags":
        return [{0: 1, 1: 16 if custom else 8, 2: 1}, {2: 0}, {2: 2}]
    if topic == "event-queue":
        return [{3: 17, 4: 1}, {3: 34, 4: 1}, {3: 51, 4: 1}, {4: 2}, {4: 2}, {4: 2}]
    if topic == "input-repeat":
        return [{0: 1} for _ in range(8)]
    if topic == "approach-target":
        return [{0: 250, 1: 255, 2: 10 if not custom else 2}, {}]
    if topic == "endpoint-patrol":
        return [{0: 4, 1: 0, 2: 6 if custom else 4, 3: 0}] + [{} for _ in range(5)]
    if topic == "manhattan-distance":
        return [{0: 0, 1: 0, 2: 200 if custom else 255, 3: 255}]
    if topic == "priority-arbiter":
        return [{3: 7, 4: 1 if custom else 8}, {3: 9, 4: 8}, {3: 5, 4: 2}]
    if topic == "decimal-format":
        return [{0: 0 if custom else 255, 1: 16 if custom else 255}]
    raise ValueError(topic)


def packet(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    n = len(TOPICS[topic][1])
    out = [165, list(TOPICS).index(topic), int(custom)] + [0] * n
    for row in cases(topic, custom):
        out += step(topic, row, custom)
    s = [0] * n
    for changes in trace(topic, custom):
        for key, value in changes.items():
            s[key] = value
        s = step(topic, s, custom, wrong)
        out += s
    return out + [239]


def preview(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    n = len(TOPICS[topic][1])
    p = packet(topic, custom, wrong)
    return (p[-1 - n : -1] + [0] * 8)[:8]
