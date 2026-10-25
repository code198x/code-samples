"""Independent profiles, camera intervals, jump ages and platform intersections."""

from __future__ import annotations

TOPICS = ["slope-height", "camera-deadzone", "jump-windows", "one-way-platform"]
CATEGORIES = {t: "physics" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["SLOP RESULTS", "VIEW RESULTS", "JUMP RESULTS", "LAND RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["X", "B", "M", "S", "O"] + [f"H{i}" for i in range(1, 9)],
    TOPICS[1]: ["C", "P", "L", "R", "M", "S", "O"],
    TOPICS[2]: ["J", "C", "B", "G", "P", "W", "X", "O"],
    TOPICS[3]: ["L", "S", "X", "W", "P", "N", "A", "B", "Y", "D", "O"],
}
ARRAYS = {TOPICS[0]: {"H": 8}, TOPICS[1]: {}, TOPICS[2]: {}, TOPICS[3]: {}}
PROFILE = [0, 1, 1, 3, 4, 4, 6, 7]


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def slope(data: list[int]) -> list[int]:
    d = list(data)
    d[3:5] = [255, 0]
    x, base, mirror = d[:3]
    if not byte(x) or x > 7 or any(not byte(v) for v in [base, mirror] + d[5:]):
        return d
    value = base + (list(reversed(d[5:])) if mirror else d[5:])[x]
    if value <= 255:
        d[3:5] = [value, 1]
    return d


def camera(data: list[int]) -> list[int]:
    d = list(data)
    d[5:] = [0, 0]
    old, player, left, right, limit = d[:5]
    if any(not byte(v) for v in d[:5]) or left > right or old > limit:
        return d
    permissible = range(max(0, player - right), min(limit, player - left) + 1)
    if permissible:
        new = min(permissible, key=lambda c: abs(c - old))
    elif player - left < 0:
        new = 0
    else:
        new = limit
    d[0] = new
    d[5:] = [int(new != old), 1]
    return d


def jump(data: list[int]) -> list[int]:
    d = list(data)
    d[0] = 0
    d[7] = 0
    if any(not byte(v) for v in d[1:7]) or not d[5] or not d[6]:
        return d
    c = max(0, d[1] - 1)
    b = max(0, d[2] - 1)
    if d[3]:
        c = d[5]
    if d[4]:
        b = d[6]
    if c and b:
        d[0] = 1
        c = b = 0
    d[1:3] = [c, b]
    d[7] = 1
    return d


def platform(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, d[5]]
    d[10] = 0
    if any(not byte(v) for v in d[2:10]):
        return d
    d[10] = 1
    x, w, old, new, a, b, y, drop = d[2:10]
    if drop or not w or not b:
        return d
    actor = set(range(x, x + w))
    floor = set(range(a, a + b))
    if actor & floor and old <= y <= new:
        d[:2] = [1, y]
    return d


FUNCTIONS = dict(zip(TOPICS, [slope, camera, jump, platform]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [x, b, m, 199, 199] + h
            for x, b, m, h in [
                (3, 100, 0, PROFILE),
                (3, 100, 1, PROFILE),
                (0, 255, 0, PROFILE),
                (7, 255, 1, PROFILE),
                (0, 250, 1, PROFILE),
                (7, 248, 0, PROFILE),
                (4, 251, 0, PROFILE),
                (4, 252, 0, PROFILE),
                (8, 0, 0, PROFILE),
                (255, 0, 0, PROFILE),
                (3, 100, 255, PROFILE),
                (0, 0, 0, [255] * 8),
                (0, 1, 0, [255] * 8),
                (7, 10, 0, [0] * 8),
                (1, 0, 1, PROFILE),
                (5, 200, 0, PROFILE),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            list(v) + [199, 199]
            for v in [
                (0, 90, 40, 80, 200),
                (10, 100, 40, 80, 200),
                (10, 50, 40, 80, 200),
                (10, 90, 40, 80, 200),
                (10, 49, 40, 80, 200),
                (10, 91, 40, 80, 200),
                (100, 0, 40, 80, 200),
                (100, 50, 40, 80, 200),
                (0, 255, 40, 80, 20),
                (21, 100, 40, 80, 20),
                (0, 100, 80, 40, 200),
                (0, 100, 60, 60, 200),
                (255, 0, 0, 0, 255),
                (0, 0, 255, 255, 200),
                (0, 255, 0, 0, 255),
                (0, 90, 40, 80, 0),
            ]
        ]
    if topic == TOPICS[2]:
        w = 2 if custom else 4
        return [
            [199, c, b, g, p, w if a else 0, w if z else 0, 199]
            for c, b, g, p, a, z in [
                (4, 0, 0, 0, 1, 1),
                (1, 1, 0, 0, 1, 1),
                (2, 2, 0, 0, 1, 1),
                (0, 0, 1, 1, 1, 1),
                (0, 0, 1, 0, 1, 1),
                (0, 0, 0, 1, 1, 1),
                (0, 2, 1, 0, 1, 1),
                (2, 0, 0, 1, 1, 1),
                (1, 0, 0, 1, 1, 1),
                (0, 1, 1, 0, 1, 1),
                (255, 255, 0, 0, 1, 1),
                (0, 0, 255, 255, 1, 1),
                (4, 4, 1, 1, 0, 1),
                (4, 4, 1, 1, 1, 0),
                (0, 0, 0, 0, 1, 1),
                (4, 3, 0, 0, 1, 1),
            ]
        ]
    return [
        [199, 199] + list(v) + [199]
        for v in [
            (10, 10, 90, 110, 15, 10, 100, 0),
            (10, 10, 90, 110, 20, 10, 100, 0),
            (20, 10, 90, 110, 10, 10, 100, 0),
            (10, 0, 90, 110, 15, 10, 100, 0),
            (10, 10, 90, 110, 15, 0, 100, 0),
            (10, 10, 110, 90, 15, 10, 100, 0),
            (10, 10, 100, 100, 15, 10, 100, 0),
            (10, 10, 101, 110, 15, 10, 100, 0),
            (10, 10, 90, 99, 15, 10, 100, 0),
            (10, 10, 90, 100, 15, 10, 100, 0),
            (10, 10, 90, 110, 15, 10, 100, 1),
            (10, 10, 90, 110, 15, 10, 100, 255),
            (250, 20, 90, 110, 255, 20, 100, 0),
            (255, 255, 0, 255, 255, 255, 100, 0),
            (0, 255, 0, 255, 255, 1, 100, 0),
            (10, 10, 255, 0, 15, 10, 100, 0),
        ]
    ]


def jump_client(custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    window = 2 if custom else 4
    counts = []
    for flow in [
        [(1, 1), (1, 0), (1, 0), (1, 0)],
        [(0, 1), (0, 0), (0, 0), (1, 0), (1, 0)],
        [(1, 0), (0, 0), (0, 1), (0, 0)],
    ]:
        d = initial(TOPICS[2])
        d[5:7] = [window, window]
        count = 0
        for grounded, pressed in flow:
            d[3:5] = [grounded, 1 if wrong else pressed]
            d = jump(d)
            states.append(list(d))
            count += d[0]
        counts.append(count)
    return states, [int(counts[0] == 1), int(sum(counts[1:]) == (0 if custom else 2))]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = [0 if wrong else 3, 100, 1 if custom else 0, 0, 0] + PROFILE
        d = slope(d)
        states.append(list(d))
        checks = [int(d[3] == (104 if custom else 103)), int(d[0] == 3)]
        for x in [0, 7, 8]:
            d[0] = x
            d = slope(d)
            states.append(list(d))
        d[:2] = [1, 255]
        d = slope(d)
        states.append(list(d))
    elif topic == TOPICS[1]:
        d = [0, 0, 60 if custom else 40, 60 if custom else 80, 200, 0, 0]
        for player in [90, 100]:
            d[1] = player - d[0] if wrong else player
            d = camera(d)
            states.append(list(d))
        checks = [int(d[0] == (40 if custom else 20)), int(d[1] == 100)]
        for player in [0, 255]:
            d[1] = player
            d = camera(d)
            states.append(list(d))
        d[2] = d[3] + 1
        d = camera(d)
        states.append(list(d))
    elif topic == TOPICS[2]:
        return jump_client(custom, wrong)
    else:
        d = platform([0, 0, 10, 10, 90, 110, 15, 10, 100, 1 if custom else 0, 0])
        if wrong and d[5] != d[8]:
            d[:2] = [0, d[5]]
        states.append(list(d))
        checks = [
            int(d[0] == (0 if custom else 1)),
            int(d[1] == (110 if custom else 100)),
        ]
        for old, new, x, w, a, b in [
            (110, 90, 10, 10, 15, 10),
            (100, 100, 10, 10, 15, 10),
            (90, 110, 10, 10, 20, 10),
        ]:
            d[2:10] = [x, w, old, new, a, b, 100, 0]
            d = platform(d)
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
