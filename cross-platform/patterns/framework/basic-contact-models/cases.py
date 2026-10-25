"""Independent bucket lists, unordered pairs, displacement and signed shake clocks."""

from __future__ import annotations

TOPICS = [
    "spatial-bucket",
    "contact-pair-cache",
    "moving-platform-carry",
    "camera-shake",
]
CATEGORIES = dict(zip(TOPICS, ["physics", "physics", "physics", "rendering"]))
LABELS = dict(
    zip(TOPICS, ["BUKT RESULTS", "CACH RESULTS", "CARY RESULTS", "SHAK RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["B", "N", "V", "F", "O", "M", "X", "Y", "A"]
    + [f"C{i}" for i in range(1, 5)]
    + [f"S{i}" for i in range(1, 17)],
    TOPICS[1]: ["F", "O", "M", "A", "B"] + [f"R{i}" for i in range(1, 9)],
    TOPICS[2]: ["P", "C", "O", "X", "A", "B", "S", "L", "H"],
    TOPICS[3]: ["X", "Y", "R", "A", "O", "T", "S", "D", "N", "M"],
}
ARRAYS = {
    TOPICS[0]: {"C": 4, "S": 16},
    TOPICS[1]: {"R": 8},
    TOPICS[2]: {},
    TOPICS[3]: {},
}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def buckets(data: list[int]) -> list[int]:
    d = list(data)
    d[:5] = [255, 0, 0, 0, 0]
    mode, x, y, item = d[5:9]
    if mode not in (0, 1, 2):
        return d
    if mode == 0:
        d[:5] = [0, 0, 0, 0, 1]
        d[9:] = [0] * 20
        return d
    if (
        not byte(x)
        or x > 15
        or not byte(y)
        or y > 15
        or not byte(item)
        or any(not byte(c) or c > 4 for c in d[9:13])
        or any(not byte(v) for v in d[13:])
    ):
        return d
    b = int(x) // 8 + 2 * (int(y) // 8)
    count = int(d[9 + b])
    prefix = list(d[13 + 4 * b : 13 + 4 * b + count])
    d[:5] = [b, count, 0, 0, 1]
    if mode == 1:
        if len(prefix) == 4:
            d[3] = 1
        else:
            d[13 + 4 * b + count] = item
            d[9 + b] = count + 1
            d[1] = count + 1
            d[2] = 1
    return d


def cache(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 0]
    mode, a, b = d[2:5]
    if mode not in (0, 1, 2):
        return d
    if mode == 0:
        d[1] = 1
        d[5:] = [0] * 8
        return d
    if (
        not byte(a)
        or a > 7
        or not byte(b)
        or b > 7
        or a == b
        or any(not byte(v) for v in d[5:])
    ):
        return d
    lo, hi = sorted([int(a), int(b)])
    remembered = {
        (i, j) for i in range(8) for j in range(i + 1, 8) if int(d[5 + i]) & (1 << j)
    }
    fresh = (lo, hi) not in remembered
    d[:2] = [int(fresh), 1]
    if mode == 1 and fresh:
        d[5 + lo] = int(d[5 + lo]) | (1 << hi)
    return d


def carry(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [d[3], 0, 0]
    x, old, new, supported, lo, hi = d[3:]
    if any(not byte(v) for v in d[3:]) or lo > hi or not lo <= x <= hi:
        return d
    d[2] = 1
    if supported:
        raw = x + (new - old)
        position = max(lo, min(hi, raw))
        d[:2] = [position, int(position != raw)]
    return d


def shake(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 0]
    d[4] = 0
    if (
        any(not byte(d[i]) for i in [2, 3, 5, 6, 7, 8, 9])
        or d[6] > 15
        or (not d[5] and d[3] > 15)
    ):
        return d
    if d[5]:
        d[2:4] = [d[7], d[6]]
    d[4] = 1
    if not d[2]:
        return d
    span = 2 * int(d[3]) + 1
    d[:2] = [(int(v) % span - int(d[3])) % 256 for v in d[8:10]]
    d[2] -= 1
    return d


FUNCTIONS = dict(zip(TOPICS, [buckets, cache, carry, shake]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def bucketrow(
    mode: int,
    x: int,
    y: int,
    item: int,
    counts: list[int] | None = None,
    slots: list[int] | None = None,
) -> list[int]:
    return (
        [199] * 5
        + [mode, x, y, item]
        + (list(counts) if counts is not None else [0] * 4)
        + (list(slots) if slots is not None else [0] * 16)
    )


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        full = [10, 11, 12, 13] + [0] * 12
        return [
            bucketrow(0, 255, 255, 255, [5, 255, 0, 0], [256] + [99] * 15),
            bucketrow(1, 0, 0, 10),
            bucketrow(1, 7, 7, 0),
            bucketrow(1, 8, 0, 255),
            bucketrow(1, 0, 8, 7),
            bucketrow(1, 8, 8, 8),
            bucketrow(1, 15, 15, 200),
            bucketrow(1, 0, 0, 99, [4, 0, 0, 0], full),
            bucketrow(2, 0, 0, 0, [4, 0, 0, 0], full),
            bucketrow(2, 15, 15, 0),
            bucketrow(1, 16, 0, 0),
            bucketrow(2, 0, 16, 0),
            bucketrow(3, 0, 0, 0),
            bucketrow(1, 0, 0, 0, [5, 0, 0, 0]),
            bucketrow(2, 0, 0, 0, [0, 0, 0, 5]),
            bucketrow(2, 0, 0, 0, [1, 0, 0, 0], [255] + [0] * 15),
        ]
    if topic == TOPICS[1]:
        return [
            [199, 199, mode, a, b] + list(r)
            for mode, a, b, r in [
                (0, 255, 255, [256] + [99] * 7),
                (1, 0, 3, [0] * 8),
                (1, 3, 0, [8] + [0] * 7),
                (2, 0, 3, [0] * 8),
                (2, 0, 3, [8] + [0] * 7),
                (1, 0, 7, [0] * 8),
                (1, 7, 0, [128] + [0] * 7),
                (1, 6, 7, [0] * 8),
                (1, 0, 0, [0] * 8),
                (1, 8, 0, [0] * 8),
                (2, 0, 255, [0] * 8),
                (3, 0, 1, [0] * 8),
                (1, 1, 7, [255] * 8),
                (2, 7, 6, [0] * 8),
                (0, 0, 0, [255] * 8),
                (1, 2, 1, [0] * 8),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [199, 199, 199] + list(v)
            for v in [
                (100, 40, 45, 1, 10, 200),
                (15, 40, 30, 1, 10, 200),
                (100, 40, 255, 0, 10, 200),
                (198, 250, 255, 1, 10, 200),
                (200, 0, 255, 1, 0, 255),
                (0, 255, 0, 1, 0, 255),
                (100, 255, 0, 1, 0, 255),
                (0, 255, 255, 1, 0, 255),
                (255, 0, 0, 1, 0, 255),
                (100, 40, 40, 255, 10, 200),
                (100, 40, 45, 1, 200, 10),
                (9, 40, 45, 1, 10, 200),
                (201, 40, 45, 1, 10, 200),
                (100, 0, 255, 0, 0, 255),
                (100, 255, 0, 255, 0, 255),
                (50, 20, 20, 1, 50, 50),
            ]
        ]
    return [
        [199, 199, r, a, 199, t, s, d, n, m]
        for r, a, t, s, d, n, m in [
            (0, 0, 0, 3, 3, 0, 255),
            (0, 0, 1, 3, 3, 0, 255),
            (2, 3, 0, 3, 3, 1, 6),
            (1, 3, 0, 3, 3, 2, 5),
            (0, 3, 0, 3, 3, 3, 4),
            (255, 15, 0, 15, 255, 255, 0),
            (2, 0, 0, 0, 3, 255, 255),
            (7, 255, 1, 5, 4, 0, 255),
            (7, 255, 0, 5, 4, 0, 255),
            (3, 3, 1, 16, 3, 0, 255),
            (3, 3, 0, 16, 3, 0, 255),
            (3, 3, 1, 3, 0, 0, 0),
            (3, 3, 255, 15, 1, 0, 255),
            (255, 15, 0, 15, 255, 15, 15),
            (1, 1, 0, 1, 1, 2, 0),
            (2, 15, 1, 0, 2, 255, 255),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        x = y = 15 if custom else 0
        d = initial(topic)
        d[6:8] = [x, y]
        for item in [200, 201, 202, 203] if custom else [10, 11, 12, 13]:
            d[5] = 0 if wrong else 1
            d[8] = item
            d = buckets(d)
            states.append(list(d))
        d[5] = 0 if wrong else 1
        d[8] = 99
        d = buckets(d)
        states.append(list(d))
        checks = [int(d[3] == 1)]
        d[5] = 0 if wrong else 2
        d = buckets(d)
        states.append(list(d))
        checks.append(int(d[1] == 4))
        d[6:8] = [0, 15] if custom else [15, 15]
        d = buckets(d)
        states.append(list(d))
        return states, checks
    if topic == TOPICS[1]:
        flow = (
            [(2, 0, 7), (1, 0, 7), (1, 7, 0), (2, 0, 7)]
            if custom
            else [(1, 0, 3), (1, 3, 0), (2, 0, 3), (1, 1, 7)]
        )
        d = initial(topic)
        count = 0
        checks = []
        for i, (mode, a, b) in enumerate(flow):
            if wrong:
                d[5] = 0
            d[2:5] = [mode, a, b]
            d = cache(d)
            states.append(list(d))
            count += d[0]
            if i == (2 if custom else 1):
                checks.append(int(d[0] == 0))
        checks.append(int(count == 2))
        d[2] = 0
        d = cache(d)
        states.append(list(d))
        d[2:5] = [2, 0, 7 if custom else 3]
        if wrong:
            d[5] = 0
        d = cache(d)
        states.append(list(d))
        return states, checks
    if topic == TOPICS[2]:
        d = [0, 0, 0, 15 if custom else 100, 40, 30 if custom else 45, 1, 10, 200]
        if wrong:
            d[4] = d[5]
        d = carry(d)
        states.append(list(d))
        checks = [
            int(d[0] == (10 if custom else 105)),
            int(d[1] == 1) if custom else int(d[4] == 40),
        ]
        d[3] = d[0]
        d[6] = 0
        d[5] = 255
        if wrong:
            d[4] = d[5]
        d = carry(d)
        states.append(list(d))
        d[3:7] = [198, 250, 255, 1]
        if wrong:
            d[4] = d[5]
        d = carry(d)
        states.append(list(d))
        d[7:] = [201, 200]
        if wrong:
            d[4] = d[5]
        d = carry(d)
        states.append(list(d))
        return states, checks
    d = initial(topic)
    d[6:8] = [5 if custom else 3, 4 if custom else 3]
    count = 0
    checks = []
    for i in range(5):
        if wrong:
            d[2] = 0
        d[5] = int(i == 0)
        d[8:] = [i, 255 if i == 0 else 7 - i]
        if (d[5] and d[7] > 0) or (not d[5] and d[2] > 0):
            count += 1
        d = shake(d)
        states.append(list(d))
        if i == 1:
            checks.append(int(d[0] == (252 if custom else 254)))
    checks.append(int(count == (4 if custom else 3)))
    return states, checks


def packet(topic: str, variant: str) -> list[int]:
    states = (
        [initial(topic)]
        + [FUNCTIONS[topic](d) for d in rows(topic, variant == "custom")]
        + clients(topic, variant == "custom", variant == "wrong")[0]
    )
    result = [v for d in states for v in d]
    assert len(result) < 995 and all(byte(v) for v in result)
    return [int(v) for v in result]
