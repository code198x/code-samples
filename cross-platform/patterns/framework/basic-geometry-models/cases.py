"""Independent set, rational-time, ordered-distance and integer-root geometry."""

from __future__ import annotations

from fractions import Fraction
from math import isqrt

TOPICS = [
    "rectangle-clipping",
    "swept-axis-collision",
    "nearest-target",
    "point-circle",
]
CATEGORIES = dict(zip(TOPICS, ["physics", "physics", "ai", "physics"]))
LABELS = dict(
    zip(TOPICS, ["CLIP RESULTS", "PATH RESULTS", "NEAR RESULTS", "BALL RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["F", "V"]
    + [f"C{i}" for i in range(1, 5)]
    + [f"A{i}" for i in range(1, 5)]
    + [f"B{i}" for i in range(1, 5)],
    TOPICS[1]: ["P", "H", "V", "X", "T", "S", "A", "B"],
    TOPICS[2]: ["S", "L", "H", "F", "O", "M", "X", "Y"]
    + [f"A{i}" for i in range(1, 5)]
    + [f"B{i}" for i in range(1, 5)],
    TOPICS[3]: ["F", "D", "E", "X", "Y", "A", "B", "R", "O"],
}
ARRAYS = {
    TOPICS[0]: {"C": 4, "A": 4, "B": 4},
    TOPICS[1]: {},
    TOPICS[2]: {"A": 4, "B": 4},
    TOPICS[3]: {},
}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def clip(data: list[int]) -> list[int]:
    d = list(data)
    d[:6] = [0] * 6
    a = d[6:10]
    b = d[10:14]
    if any(not byte(v) for v in a + b) or any(
        r[0] > r[2] or r[1] > r[3] for r in [a, b]
    ):
        return d
    d[1] = 1
    xs = set(range(a[0], a[2])) & set(range(b[0], b[2]))
    ys = set(range(a[1], a[3])) & set(range(b[1], b[3]))
    if xs and ys:
        d[0] = 1
        d[2:6] = [min(xs), min(ys), max(xs) + 1, max(ys) + 1]
    return d


def sweep(data: list[int]) -> list[int]:
    d = list(data)
    old, target, size, start, end = d[3:]
    d[:3] = [old, 0, 0]
    if (
        any(not byte(v) for v in d[3:])
        or not size
        or start >= end
        or old + size > 255
        or target + size > 255
        or (old < end and old + size > start)
    ):
        return d
    d[:3] = [target, 0, 1]
    movement = target - old
    if not movement:
        return d
    time = (
        Fraction(start - (old + size), movement)
        if movement > 0
        else Fraction(end - old, movement)
    )
    if 0 <= time <= 1:
        d[:2] = [int(old + movement * time), 1]
    return d


def nearest(data: list[int]) -> list[int]:
    d = list(data)
    d[:5] = [255, 0, 0, 0, 0]
    mask, x, y = d[5:8]
    if any(not byte(v) for v in [mask, x, y]):
        return d
    active = [i for i in range(4) if mask & (1 << i)]
    if any(not byte(d[8 + i]) or not byte(d[12 + i]) for i in active):
        return d
    d[4] = 1
    if not active:
        return d
    distance, slot = min((abs(x - d[8 + i]) + abs(y - d[12 + i]), i) for i in active)
    d[:4] = [slot, distance % 256, distance // 256, 1]
    return d


def circle(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [0, 0, 0]
    d[8] = 0
    if any(not byte(v) for v in d[3:8]):
        return d
    x, y, cx, cy, r = d[3:8]
    dx = abs(x - cx)
    dy = abs(y - cy)
    d[1:3] = [dx, dy]
    d[8] = 1
    d[0] = int(dx <= r and dy <= isqrt(r * r - dx * dx))
    return d


FUNCTIONS = dict(zip(TOPICS, [clip, sweep, nearest, circle]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [199] * 6 + a + b
            for a, b in [
                ([0, 0, 60, 60], [10, 10, 40, 40]),
                ([0, 0, 255, 255], [20, 30, 40, 50]),
                ([10, 10, 20, 20], [20, 10, 30, 20]),
                ([20, 20, 20, 30], [0, 0, 255, 255]),
                ([0, 0, 10, 10], [0, 0, 0, 10]),
                ([30, 20, 10, 40], [0, 0, 255, 255]),
                ([0, 0, 255, 255], [30, 20, 10, 40]),
                ([0, 40, 10, 20], [0, 0, 255, 255]),
                ([0, 0, 255, 255], [0, 40, 10, 20]),
                ([0, 0, 1, 1], [0, 0, 1, 1]),
                ([254, 254, 255, 255], [0, 0, 255, 255]),
                ([0, 0, 0, 0], [0, 0, 0, 0]),
                ([5, 5, 9, 9], [0, 0, 4, 4]),
                ([0, 0, 100, 100], [0, 90, 100, 110]),
                ([10, 10, 30, 30], [15, 15, 25, 25]),
                ([15, 15, 25, 25], [10, 10, 30, 30]),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            [199] * 3 + list(v)
            for v in [
                (10, 100, 5, 50, 60),
                (100, 10, 5, 50, 60),
                (10, 45, 5, 50, 60),
                (10, 44, 5, 50, 60),
                (60, 60, 5, 50, 60),
                (45, 45, 5, 50, 60),
                (45, 46, 5, 50, 60),
                (60, 59, 5, 50, 60),
                (50, 10, 5, 50, 60),
                (10, 100, 0, 50, 60),
                (250, 250, 6, 50, 60),
                (10, 251, 5, 50, 60),
                (10, 100, 5, 60, 60),
                (10, 100, 5, 60, 50),
                (0, 254, 1, 100, 101),
                (254, 0, 1, 100, 101),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [199] * 5 + [mask, x, y] + a + b
            for mask, x, y, a, b in [
                (0, 0, 0, [0] * 4, [0] * 4),
                (16, 0, 0, [0] * 4, [0] * 4),
                (1, 255, 255, [0] * 4, [0] * 4),
                (1, 0, 0, [255] * 4, [255] * 4),
                (15, 50, 50, [0, 51, 49, 50], [0, 50, 50, 80]),
                (255, 50, 50, [0, 51, 49, 50], [0, 50, 50, 80]),
                (2, 50, 50, [0, 51, 49, 50], [0, 50, 50, 80]),
                (4, 50, 50, [0, 51, 49, 50], [0, 50, 50, 80]),
                (8, 50, 50, [0, 51, 49, 50], [0, 50, 50, 80]),
                (15, 250, 250, [0, 255, 245, 250], [0, 255, 245, 200]),
                (128, 255, 255, [255] * 4, [255] * 4),
                (3, 0, 0, [10, 10, 0, 0], [0, 0, 0, 0]),
                (15, 0, 0, [0] * 4, [0] * 4),
                (240, 0, 0, [255] * 4, [255] * 4),
                (17, 255, 0, [0] * 4, [255] * 4),
                (15, 255, 255, [0, 1, 2, 3], [0, 1, 2, 3]),
            ]
        ]
    return [
        [199] * 3 + list(v) + [199]
        for v in [
            (104, 104, 100, 100, 5),
            (103, 104, 100, 100, 5),
            (100, 100, 100, 100, 0),
            (101, 100, 100, 100, 0),
            (0, 0, 255, 255, 255),
            (255, 255, 0, 0, 255),
            (255, 0, 0, 0, 255),
            (0, 255, 0, 0, 255),
            (0, 0, 0, 0, 255),
            (255, 255, 255, 255, 0),
            (10, 10, 20, 20, 14),
            (10, 10, 20, 20, 15),
            (0, 0, 255, 0, 254),
            (0, 0, 255, 0, 255),
            (1, 1, 0, 0, 1),
            (1, 1, 0, 0, 2),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        a = [0, 0, 255, 255] if custom else [0, 0, 60, 60]
        b = [20, 30, 40, 50] if custom else [10, 10, 40, 40]
        if wrong:
            b[2] = 255
        d = clip([0] * 6 + a + b)
        states.append(list(d))
        checks = [int(d[4] == 40), int(d[4] - d[2] == (20 if custom else 30))]
        for a in [[0, 0, 5, 5], [10, 10, 10, 20], [0, 0, 255, 255]]:
            d[6:10] = a
            d = clip(d)
            states.append(list(d))
    elif topic == TOPICS[1]:
        old, target = (100, 10) if custom else (10, 100)
        d = sweep([0, 0, 0, old, old if wrong else target, 5, 50, 60])
        states.append(list(d))
        checks = [int(d[0] == (60 if custom else 45)), int(d[1] == 1)]
        for values in [(45, 44, 5, 50, 60), (60, 61, 5, 50, 60), (10, 44, 5, 50, 60)]:
            d[3:] = values
            d = sweep(d)
            states.append(list(d))
    elif topic == TOPICS[2]:
        x, y = (250, 250) if custom else (50, 50)
        a = [0, 255, 245, 250] if custom else [0, 51, 49, 50]
        b = [0, 255, 245, 200] if custom else [0, 50, 50, 80]
        d = nearest([0] * 5 + [1 if wrong else 15, x, y] + a + b)
        states.append(list(d))
        checks = [int(d[0] == 1), int(d[1] + 256 * d[2] == (10 if custom else 1))]
        for mask in [0, 255, 16]:
            d[5] = mask
            d = nearest(d)
            states.append(list(d))
    else:
        x = 103 if custom else 104
        y = 104
        d = circle([0] * 3 + [x, 100 if wrong else y, 100, 100, 5, 0])
        states.append(list(d))
        checks = [int(d[1:3] == [3 if custom else 4, 4]), int(d[4] == y)]
        for values in [
            (100, 100, 100, 100, 0),
            (101, 100, 100, 100, 0),
            (255, 255, 0, 0, 255),
        ]:
            d[3:8] = values
            d = circle(d)
            states.append(list(d))
    return states, checks


def packet(topic: str, variant: str) -> list[int]:
    states = [initial(topic)] + [
        FUNCTIONS[topic](d) for d in rows(topic, variant == "custom")
    ]
    client, _checks = clients(topic, variant == "custom", variant == "wrong")
    states += client
    result = [v for d in states for v in d]
    assert len(result) < 995 and all(byte(v) for v in result)
    return result
