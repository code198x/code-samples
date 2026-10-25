"""Independent clamp, chronology, lifetime and paired-filter models."""

from __future__ import annotations

CATEGORIES = {
    "waypoint-route": "ai",
    "motion-history": "framework",
    "generation-handles": "framework",
    "stable-compaction": "framework",
}
LABELS = {
    "waypoint-route": "ROUT RESULTS",
    "motion-history": "HIST RESULTS",
    "generation-handles": "LIFE RESULTS",
    "stable-compaction": "PACK RESULTS",
}
FIELDS = {
    "waypoint-route": ["X", "T", "C", "S", "L", "A", "F", "O", "E"]
    + [f"P{i}" for i in range(1, 5)],
    "motion-history": ["H", "C", "X", "Y", "L", "M", "A", "B", "O", "E"]
    + [f"U{i}" for i in range(1, 9)]
    + [f"V{i}" for i in range(1, 9)],
    "generation-handles": ["A", "M", "S", "T", "O", "R", "V", "E"]
    + [f"G{i}" for i in range(1, 5)],
    "stable-compaction": ["C", "R", "O", "E"]
    + [f"F{i}" for i in range(1, 9)]
    + [f"P{i}" for i in range(1, 9)],
}
ARRAYS = {
    "waypoint-route": {"P": 4},
    "motion-history": {"U": 8, "V": 8},
    "generation-handles": {"G": 4},
    "stable-compaction": {"F": 8, "P": 8},
}


def integral(v: int, lo: int, hi: int) -> bool:
    return lo <= v <= hi and v == int(v)


def route(data: list[int]) -> list[int]:
    d = list(data)
    x, t, c, s, l, _, f, _, _ = d[:9]
    d[5] = 0
    d[7:9] = [0, 1]
    if not all(
        [
            integral(x, 0, 255),
            integral(c, 1, 4),
            integral(s, 1, 255),
            l in [0, 1],
            f in [0, 1],
        ]
    ):
        return d
    if not integral(t, 0, c - 1) or any(not integral(v, 0, 255) for v in d[9 : 9 + c]):
        return d
    d[7:9] = [1, 0]
    if f:
        return d
    target = d[9 + t]
    d[0] = max(x - s, min(x + s, target))
    if d[0] == target:
        d[5] = 1
        if t + 1 < c:
            d[1] = t + 1
        elif l:
            d[1] = 0
        else:
            d[6] = 1
    return d


def history(data: list[int]) -> list[int]:
    d = list(data)
    h, c, x, y, lag, push = d[:6]
    d[6:10] = [0, 0, 0, 1]
    if (
        not integral(h, 0, 7)
        or not integral(c, 0, 8)
        or any(not integral(v, 0, 255) for v in d[10:])
    ):
        return d
    d[9] = 2
    if (
        push not in [0, 1]
        or not integral(lag, 0, 255)
        or (push and (not integral(x, 0, 255) or not integral(y, 0, 255)))
    ):
        return d
    chronological = [
        (d[10 + (h - c + i) % 8], d[18 + (h - c + i) % 8]) for i in range(c)
    ]
    if push:
        chronological = (chronological + [(x, y)])[-8:]
        d[10 + h] = x
        d[18 + h] = y
        d[0] = (h + 1) % 8
        d[1] = len(chronological)
    d[9] = 0
    if lag < len(chronological):
        d[6:9] = [*chronological[-1 - lag], 1]
    return d


def handles(data: list[int]) -> list[int]:
    d = list(data)
    active, mode, slot, generation = d[:4]
    d[4:8] = [0, 255, 0, 1]
    if not integral(active, 0, 15) or any(not integral(v, 0, 255) for v in d[8:]):
        return d
    d[7] = 2
    if not integral(mode, 0, 2) or (
        mode != 0 and (not integral(slot, 0, 3) or not integral(generation, 0, 255))
    ):
        return d
    d[7] = 0
    live = {i for i in range(4) if active & (1 << i)}
    if mode == 0:
        free = sorted(set(range(4)) - live)
        if free:
            slot = free[0]
            d[8 + slot] = (d[8 + slot] + 1) % 256
            live.add(slot)
            d[4:7] = [1, slot, d[8 + slot]]
    elif slot in live and generation == d[8 + slot]:
        d[4:7] = [1, slot, generation]
        if mode == 1:
            live.remove(slot)
    d[0] = sum(1 << i for i in live)
    return d


def compact(data: list[int]) -> list[int]:
    d = list(data)
    count = d[0]
    d[1:4] = [0, 0, 1]
    if not integral(count, 0, 8):
        return d
    if any(not integral(v, 0, 255) for v in d[4 : 4 + count] + d[12 : 12 + count]):
        return d
    survivors = [
        (flag, value)
        for flag, value in zip(d[4 : 4 + count], d[12 : 12 + count])
        if flag
    ]
    d[0:4] = [len(survivors), count - len(survivors), 1, 0]
    padded = survivors + [(0, 0)] * (count - len(survivors))
    d[4 : 4 + count] = [f for f, _ in padded]
    d[12 : 12 + count] = [v for _, v in padded]
    return d


FUNCTIONS = {
    "waypoint-route": route,
    "motion-history": history,
    "generation-handles": handles,
    "stable-compaction": compact,
}


def initial(topic: str, custom: bool = False) -> list[int]:
    if topic == "waypoint-route":
        return [0, 0, 4, 5 if custom else 4, int(custom), 0, 0, 0, 0] + [0] * 4
    if topic == "generation-handles":
        return [0, 0, 0, 0, 0, 255, 0, 0] + [0] * 4
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool = False) -> list[list[int]]:
    if topic == "waypoint-route":
        out = []
        for x, t, c, s, l, f in [
            (0, 0, 4, 4, 0, 0),
            (6, 0, 4, 4, 0, 0),
            (9, 1, 4, 255, 0, 0),
            (0, 1, 4, 1, 0, 0),
            (3, 3, 4, 1, 0, 0),
            (3, 3, 4, 1, 1, 0),
            (3, 3, 4, 1, 0, 1),
            (255, 0, 1, 255, 0, 0),
            (0, 0, 0, 1, 0, 0),
            (0, 4, 4, 1, 0, 0),
            (0, 0, 4, 0, 0, 0),
            (0, 0, 4, 1, 2, 0),
            (0, 0, 4, 1, 0, 2),
        ]:
            out.append([x, t, c, s, l, 9, f, 9, 9] + [6, 1, 9, 3])
        out.append([2, 0, 4, 1, 1, 9, 0, 9, 9] + [2] * 4)
        return out
    if topic == "motion-history":
        out = []
        for h, c, x, y, lag, push in [
            (0, 0, 4, 8, 0, 0),
            (0, 0, 4, 8, 0, 1),
            (7, 8, 255, 0, 7, 1),
            (0, 8, 1, 2, 7, 0),
            (5, 3, 7, 9, 2, 0),
            (5, 3, 7, 9, 3, 0),
            (0, 0, 1, 2, 7, 1),
            (7, 7, 7, 8, 8, 1),
            (8, 3, 1, 2, 0, 1),
            (0, 9, 1, 2, 0, 1),
            (0, 0, 1, 2, 0, 2),
            (4, 8, 255, 255, 255, 0),
        ]:
            out.append(
                [h, c, x, y, lag, push, 9, 9, 9, 9]
                + list(range(8))
                + list(range(10, 18))
            )
        return out
    if topic == "generation-handles":
        return [
            [a, m, s, t, 9, 9, 9, 9] + g
            for a, m, s, t, g in [
                (0, 0, 255, 255, [0] * 4),
                (0, 0, 0, 0, [255, 0, 0, 0]),
                (1, 0, 0, 0, [7] * 4),
                (15, 0, 0, 0, [7] * 4),
                (1, 2, 0, 1, [1, 0, 0, 0]),
                (1, 2, 0, 0, [1, 0, 0, 0]),
                (1, 1, 0, 255, [255, 0, 0, 0]),
                (0, 1, 0, 1, [1, 0, 0, 0]),
                (16, 0, 0, 0, [0] * 4),
                (0, 3, 0, 0, [0] * 4),
                (1, 2, 4, 0, [0] * 4),
                (1, 1, 255, 0, [0] * 4),
                (8, 2, 3, 9, [0, 0, 0, 9]),
                (8, 1, 3, 9, [0, 0, 0, 9]),
            ]
        ]
    out = []
    for count, flags in [
        (0, [1] * 8),
        (1, [0] + [1] * 7),
        (1, [255] + [0] * 7),
        (4, [1, 0, 2, 0, 1, 0, 0, 0]),
        (8, [0] * 8),
        (8, [1] * 8),
        (8, [0, 1, 0, 2, 0, 3, 0, 4]),
        (3, [0, 0, 0, 1, 1, 1, 1, 1]),
        (9, [1] * 8),
        (255, [1] * 8),
    ]:
        out.append([count, 9, 9, 9] + flags + list(range(10, 18)))
    return out


def clients(topic: str, custom: bool, wrong: bool) -> list[list[int]]:
    out = []
    if topic == "waypoint-route":
        d = initial(topic, custom)
        d[9:] = [6, 1, 9, 3]
        for _ in range(12):
            if wrong:
                d[1] = 0
            d = route(d)
            out.append(list(d))
        return out
    if topic == "motion-history":
        d = initial(topic)
        d[4] = 7 if custom else 2
        d[5] = 1
        for i in range(1, 10 if custom else 13):
            if wrong:
                d[0] = 0
            d[2:4] = [i, 2 * i]
            d = history(d)
            out.append(list(d))
        d[5] = 0
        d[4] = 255
        d = history(d)
        out.append(list(d))
        d[4] = 0
        d = history(d)
        out.append(list(d))
        return out
    if topic == "generation-handles":
        d = initial(topic)
        d[8] = 254 if custom else 0
        d = handles(d)
        out.append(list(d))
        slot, old = d[5:7]
        for mode in [2, 1]:
            d[1:4] = [mode, slot, 0 if wrong else old]
            d = handles(d)
            out.append(list(d))
        d[1] = 0
        d = handles(d)
        out.append(list(d))
        newslot, new = d[5:7]
        for s, g in [(slot, old), (newslot, new)]:
            d[1:4] = [2, s, 0 if wrong else g]
            d = handles(d)
            out.append(list(d))
        return out
    n = 3 if custom else 4
    flags = [0, 3, 1, 1, 0, 0, 0, 0] if custom else [1, 0, 2, 0, 1, 0, 0, 0]
    values = [20, 21, 22, 88, 0, 0, 0, 0] if custom else [10, 11, 12, 13, 99, 0, 0, 0]
    d = [8 if wrong else n, 0, 0, 0] + flags + values
    d = compact(d)
    out.append(list(d))
    d[4] = 0
    d = compact(d)
    out.append(list(d))
    count = d[0]
    d[0] = 9
    d = compact(d)
    out.append(list(d))
    d[0] = count
    d = compact(d)
    out.append(list(d))
    return out


def packet(topic: str, variant: str) -> list[int]:
    custom = variant == "custom"
    states = (
        [initial(topic, custom)]
        + [FUNCTIONS[topic](r) for r in rows(topic, custom)]
        + clients(topic, custom, variant == "wrong")
    )
    assert all(len(r) == len(FIELDS[topic]) for r in states)
    result = [v for r in states for v in r]
    assert len(result) < 995 and all(integral(v, 0, 255) for v in result)
    return result
