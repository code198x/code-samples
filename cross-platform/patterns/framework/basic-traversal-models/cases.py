"""Independent interval, projection, rational-response and traversal-state models."""

from __future__ import annotations

TOPICS = [
    "moving-solid-push",
    "viewport-world-transform",
    "surface-response",
    "ladder-controller",
]
CATEGORIES = dict(zip(TOPICS, ["physics", "rendering", "physics", "physics"]))
LABELS = dict(
    zip(TOPICS, ["SOLI RESULTS", "VIEW RESULTS", "SURF RESULTS", "LADR RESULTS"])
)
FIELDS = {
    TOPICS[0]: list("PUCOXWABSLH"),
    TOPICS[1]: list("XYVOABCDEFGHWT"),
    TOPICS[2]: list("NDTOABCR"),
    TOPICS[3]: list("MYGJOLUDBAH"),
}
ARRAYS = {t: {} for t in TOPICS}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def solid(data: list[int]) -> list[int]:
    d = list(data)
    d[:4] = [d[4], 0, 0, 0]
    x, w, a, b, s, lo, hi = d[4:]
    if (
        any(not byte(v) for v in d[4:])
        or not w
        or not s
        or not lo <= x <= hi
        or max(x + w, a + s, b + s) > 255
        or max(x, a) < min(x + w, a + s)
    ):
        return d
    d[3] = 1
    target = None
    if b > a and a + s <= x < b + s:
        target = b + s
    elif b < a and b < x + w <= a:
        target = b - w
    if target is not None:
        if not lo <= target <= hi or target + w > 255:
            d[2] = 1
        else:
            d[:2] = [target, 1]
    return d


def viewport(data: list[int]) -> list[int]:
    d = list(data)
    d[:4] = [0] * 4
    if any(not byte(v) for v in d[4:]) or not d[12] or not d[13]:
        return d
    d[3] = 1
    wx = d[4] + 256 * d[5]
    wy = d[6] + 256 * d[7]
    cx = d[8] + 256 * d[9]
    cy = d[10] + 256 * d[11]
    dx = wx - cx
    dy = wy - cy
    if 0 <= dx < d[12] and 0 <= dy < d[13]:
        d[:3] = [dx, dy, 1]
    return d


def surface(data: list[int]) -> list[int]:
    d = list(data)
    d[:4] = [0] * 4
    a, b, c, r = d[4:]
    if any(not byte(v) for v in d[4:]) or b > 1 or r > 4:
        return d
    from fractions import Fraction

    d[:4] = [int(Fraction(int(a) * int(r), 4)), 1 - b, c, 1]
    return d


def ladder(data: list[int]) -> list[int]:
    d = list(data)
    d[2:5] = [0, 0, 0]
    mode, y = d[:2]
    on, up, down, jump, lo, hi = d[5:]
    if any(not byte(v) for v in d[:2] + d[5:]) or mode > 1 or not lo <= y <= hi:
        return d
    d[4] = 1
    if not on:
        d[0] = 0
    elif mode or up or down:
        d[0] = 1
        if jump:
            d[0] = 0
            d[3] = 1
        else:
            d[1] = max(lo, min(hi, y + int(bool(down)) - int(bool(up))))
    d[2] = int(d[0] == 0)
    return d


FUNCTIONS = dict(zip(TOPICS, [solid, viewport, surface, ladder]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def split(n: int) -> list[int]:
    return [n % 256, n // 256]


def viewrow(wx: int, wy: int, cx: int, cy: int, w: int, h: int) -> list[int]:
    return [199] * 4 + split(wx) + split(wy) + split(cx) + split(cy) + [w, h]


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [199] * 4 + list(v)
            for v in [
                (10, 2, 0, 12, 2, 0, 30),
                (5, 2, 10, 0, 2, 0, 30),
                (10, 2, 0, 8, 2, 0, 30),
                (10, 2, 0, 9, 2, 0, 30),
                (10, 2, 0, 12, 2, 0, 13),
                (5, 2, 10, 7, 2, 0, 30),
                (5, 2, 10, 6, 2, 0, 30),
                (5, 2, 10, 0, 2, 0, 30),
                (10, 2, 10, 12, 2, 0, 30),
                (10, 0, 0, 12, 2, 0, 30),
                (10, 2, 0, 12, 0, 0, 30),
                (254, 1, 0, 254, 1, 0, 255),
                (254, 1, 0, 254, 1, 0, 254),
                (254, 2, 0, 252, 1, 0, 255),
                (10, 2, 0, 12, 2, 20, 5),
                (0, 1, 1, 0, 1, 0, 255),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            viewrow(*v)
            for v in [
                (261, 266, 250, 256, 32, 24),
                (65535, 65535, 65534, 65534, 2, 2),
                (0, 0, 0, 0, 1, 1),
                (255, 255, 256, 256, 32, 24),
                (256, 256, 255, 255, 1, 1),
                (256, 256, 255, 255, 2, 2),
                (282, 266, 250, 256, 32, 24),
                (261, 280, 250, 256, 32, 24),
                (250, 256, 250, 256, 32, 24),
                (65535, 0, 0, 0, 255, 255),
                (0, 65535, 0, 0, 255, 255),
                (255, 255, 1, 1, 255, 255),
                (256, 256, 1, 1, 255, 255),
                (100, 100, 50, 50, 0, 24),
                (100, 100, 50, 50, 32, 0),
                (65535, 65535, 65535, 65535, 255, 255),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [199] * 4 + list(v)
            for v in [
                (11, 1, 254, 3),
                (255, 0, 128, 2),
                (255, 0, 255, 4),
                (255, 1, 0, 0),
                (0, 0, 128, 4),
                (1, 0, 0, 1),
                (3, 1, 255, 1),
                (4, 1, 254, 1),
                (7, 0, 128, 2),
                (11, 0, 254, 3),
                (254, 1, 1, 3),
                (255, 1, 2, 3),
                (10, 2, 0, 4),
                (10, 255, 0, 4),
                (10, 0, 0, 5),
                (10, 0, 0, 255),
            ]
        ]
    return [
        [mode, y, 199, 199, 199, on, up, down, jump, lo, hi]
        for mode, y, on, up, down, jump, lo, hi in [
            (0, 10, 1, 1, 0, 0, 0, 30),
            (0, 20, 1, 0, 1, 0, 0, 30),
            (1, 10, 1, 0, 0, 0, 0, 30),
            (0, 10, 1, 0, 0, 0, 0, 30),
            (1, 10, 1, 1, 1, 0, 0, 30),
            (0, 10, 1, 1, 1, 0, 0, 30),
            (1, 10, 1, 0, 0, 1, 0, 30),
            (1, 10, 0, 1, 0, 1, 0, 30),
            (0, 10, 1, 0, 0, 1, 0, 30),
            (1, 0, 1, 1, 0, 0, 0, 30),
            (1, 30, 1, 0, 1, 0, 0, 30),
            (2, 10, 1, 1, 0, 0, 0, 30),
            (1, 9, 1, 1, 0, 0, 10, 30),
            (1, 31, 1, 0, 1, 0, 10, 30),
            (1, 20, 255, 255, 0, 0, 20, 20),
            (1, 255, 1, 0, 1, 0, 0, 255),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    checks = []
    if topic == TOPICS[0]:
        d = [0] * 4 + ([5, 2, 10, 0, 2, 0, 30] if custom else [10, 2, 0, 12, 2, 0, 30])
        for i, updates in enumerate(
            [{}, {4: 20, 6: 0, 7: 5}, {4: 10, 6: 20, 7: 8}, {4: 10, 6: 10, 7: 12}]
        ):
            for k, v in updates.items():
                d[k] = v
            if wrong:
                d[6] = d[7]
            d = solid(d)
            states.append(list(d))
            if i == 0:
                checks = [
                    int(d[2] == 1) if custom else int(d[0] == 14),
                    int(d[6] == 10) if custom else int(d[1] == 1),
                ]
        return states, checks
    if topic == TOPICS[1]:
        d = (
            viewrow(65535, 65535, 65534, 65534, 2, 2)
            if custom
            else viewrow(261, 266, 250, 256, 32, 24)
        )
        for i, updates in enumerate(
            [{}, {4: 0, 5: 0}, {4: 255, 5: 255, 12: 0}, {12: 2}]
        ):
            for k, v in updates.items():
                d[k] = v
            if wrong:
                d[5] = 0
            d = viewport(d)
            states.append(list(d))
            if i == 0:
                checks = [int(d[0] == (1 if custom else 11)), int(d[2] == 1)]
        return states, checks
    if topic == TOPICS[2]:
        d = [0] * 4 + ([255, 0, 128, 2] if custom else [11, 1, 254, 3])
        for i, updates in enumerate([{}, {4: 0}, {4: 255, 7: 4}, {5: 2}]):
            for k, v in updates.items():
                d[k] = v
            if wrong:
                d[7] = 4
            d = surface(d)
            states.append(list(d))
            if i == 0:
                checks = [
                    int(d[0] == (127 if custom else 8)),
                    int(d[7] == (2 if custom else 3)),
                ]
        return states, checks
    d = [
        0,
        20 if custom else 10,
        0,
        0,
        0,
        1,
        0 if custom else 1,
        1 if custom else 0,
        0,
        0,
        30,
    ]
    for i, updates in enumerate([{}, {6: 0, 7: 0}, {8: 1}, {8: 0, 6: 1}, {5: 0}]):
        for k, v in updates.items():
            d[k] = v
        if wrong:
            d[5] = 0
        d = ladder(d)
        states.append(list(d))
        if i == 0:
            checks.append(int(d[1] == (21 if custom else 9)))
        if i == 1:
            checks.append(int(d[0] == 1 and d[2] == 0))
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
