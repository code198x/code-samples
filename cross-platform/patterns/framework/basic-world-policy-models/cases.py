"""Independent facing sectors, colour tuples, mutual sets and grid transactions."""

from __future__ import annotations

from collections.abc import Sequence
from fractions import Fraction

TOPICS = [
    "eight-way-direction",
    "packed-colour-step",
    "collision-layer-filter",
    "push-block-transaction",
]
CATEGORIES = dict(zip(TOPICS, ["physics", "rendering", "physics", "framework"]))
LABELS = dict(
    zip(TOPICS, ["FACE RESULTS", "FADE RESULTS", "PAIR RESULTS", "PUSH RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["D", "U", "V", "X", "Y", "A", "B", "O"],
    TOPICS[1]: ["C", "T", "O"],
    TOPICS[2]: ["K", "A", "B", "C", "D", "S", "T", "O"],
    TOPICS[3]: ["C", "R", "O", "D"] + [f"B{i}" for i in range(1, 17)],
}
ARRAYS = {TOPICS[0]: {}, TOPICS[1]: {}, TOPICS[2]: {}, TOPICS[3]: {"B": 16}}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def facing(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [0, 0, 0]
    d[7] = 0
    if any(not byte(v) for v in d[3:7]):
        return d
    dx, dy = int(d[5] - d[3]), int(d[6] - d[4])
    u, v = abs(dx), abs(dy)
    d[1:3] = [u, v]
    d[7] = 1
    if not u and not v:
        return d
    slope = Fraction(v, u) if u else None
    if slope is not None and slope <= Fraction(1, 2):
        direction = 3 if dx > 0 else 7
    elif slope is None or slope >= 2:
        direction = 5 if dy > 0 else 1
    else:
        direction = {
            (True, False): 2,
            (True, True): 4,
            (False, True): 6,
            (False, False): 8,
        }[(dx > 0, dy > 0)]
    d[0] = direction
    return d


def channels(value: int) -> tuple[int, int, int]:
    return (int(value) // 32, (int(value) // 4) % 8, int(value) % 4)


def colour(data: list[int]) -> list[int]:
    d = list(data)
    d[2] = 0
    if not byte(d[0]) or not byte(d[1]):
        return d
    current = channels(d[0])
    target = channels(d[1])
    result = [a + (b > a) - (b < a) for a, b in zip(current, target)]
    d[0] = 32 * result[0] + 4 * result[1] + result[2]
    d[2] = 1
    return d


def collision(data: list[int]) -> list[int]:
    d = list(data)
    d[0] = d[7] = 0
    if any(not byte(v) for v in d[1:7]):
        return d
    a, ma, b, mb, sa, sb = d[1:7]
    ga = {i for i in range(8) if int(a) & (1 << i)}
    gb = {i for i in range(8) if int(b) & (1 << i)}
    accepta = {i for i in range(8) if int(ma) & (1 << i)}
    acceptb = {i for i in range(8) if int(mb) & (1 << i)}
    d[7] = 1
    if ga & acceptb and gb & accepta:
        d[0] = 2 if sa and sb else 1
    return d


def board(crates: Sequence[int] = (), walls: Sequence[int] = ()) -> list[int]:
    return [2 if i in crates else 1 if i in walls else 0 for i in range(16)]


def push(data: list[int]) -> list[int]:
    d = list(data)
    d[1:3] = [0, 0]
    cell, _, _, request = d[:4]
    if (
        not byte(cell)
        or cell > 15
        or request not in (1, 2, 3, 4)
        or any(not byte(v) for v in d[4:])
    ):
        return d
    world = list(d[4:])
    row, col = divmod(int(cell), 4)
    if world[int(cell)] != 0:
        return d
    d[2] = 1
    dr, dc = {1: (0, -1), 2: (0, 1), 3: (-1, 0), 4: (1, 0)}[request]
    ar, ac = row + dr, col + dc
    if not (0 <= ar < 4 and 0 <= ac < 4):
        return d
    adjacent = ar * 4 + ac
    if world[adjacent] == 0:
        d[0] = adjacent
        d[1] = 1
        return d
    if world[adjacent] != 2:
        return d
    br, bc = ar + dr, ac + dc
    if not (0 <= br < 4 and 0 <= bc < 4) or world[br * 4 + bc] != 0:
        return d
    world[adjacent] = 0
    world[br * 4 + bc] = 2
    d[0] = adjacent
    d[1] = 2
    d[4:] = world
    return d


FUNCTIONS = dict(zip(TOPICS, [facing, colour, collision, push]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [199, 199, 199] + list(v) + [199]
            for v in [
                (100, 100, 103, 107),
                (100, 100, 91, 94),
                (0, 0, 0, 0),
                (0, 0, 255, 0),
                (255, 255, 0, 255),
                (0, 255, 0, 0),
                (255, 0, 255, 255),
                (0, 0, 2, 1),
                (0, 0, 1, 2),
                (0, 0, 3, 2),
                (0, 0, 2, 3),
                (255, 255, 0, 0),
                (255, 0, 0, 255),
                (0, 255, 255, 0),
                (128, 128, 127, 128),
                (128, 128, 128, 127),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            [c, t, 199]
            for c, t in [
                (0, 255),
                (255, 0),
                (0, 0),
                (255, 255),
                (31, 32),
                (32, 31),
                (3, 4),
                (4, 3),
                (37, 255),
                (218, 0),
                (128, 0),
                (0, 128),
                (28, 0),
                (0, 28),
                (1, 2),
                (2, 1),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [199] + list(v) + [199]
            for v in [
                (1, 2, 2, 1, 1, 1),
                (1, 0, 2, 1, 1, 1),
                (1, 2, 2, 0, 1, 1),
                (255, 255, 255, 255, 255, 255),
                (1, 2, 2, 1, 0, 1),
                (1, 2, 2, 1, 1, 0),
                (1, 2, 2, 1, 0, 0),
                (0, 2, 2, 1, 1, 1),
                (1, 2, 0, 1, 1, 1),
                (128, 2, 2, 128, 0, 1),
                (3, 4, 4, 1, 1, 1),
                (1, 4, 2, 1, 1, 1),
                (1, 2, 2, 4, 1, 1),
                (128, 128, 128, 128, 1, 1),
                (255, 0, 255, 0, 1, 1),
                (1, 1, 1, 1, 255, 1),
            ]
        ]
    data = []
    for cell, request, crates, walls in [
        (5, 2, [6], []),
        (5, 2, [6], [7]),
        (5, 2, [6, 7], []),
        (5, 2, [], []),
        (3, 2, [], []),
        (0, 1, [], []),
        (0, 3, [], []),
        (15, 4, [], []),
        (2, 2, [3], []),
        (4, 1, [], []),
        (9, 3, [5], []),
        (1, 4, [5], [9]),
        (6, 3, [], [2]),
        (6, 0, [], []),
        (16, 2, [], []),
        (6, 2, [], [6]),
    ]:
        world = board(crates, walls)
        if cell == 6 and request == 3:
            world[2] = 255
        data.append([cell, 199, 199, request] + world)
    return data


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        tx, ty = (91, 94) if custom else (103, 107)
        d = facing([0, 0, 0, 100, 100, tx, 100 if wrong else ty, 0])
        states.append(list(d))
        checks = [int(d[0] == (8 if custom else 5)), int(d[2] == (6 if custom else 7))]
        for x, y, a, b in [(0, 0, 0, 0), (0, 0, 2, 1), (255, 255, 0, 0)]:
            d[3:7] = [x, y, a, b]
            d = facing(d)
            states.append(list(d))
        return states, checks
    if topic == TOPICS[1]:
        start, target = (255, 0) if custom else (0, 255)
        d = [start, target, 0]
        checks = [0, 0]
        for i in range(8):
            if wrong:
                d[0] = start
            d = colour(d)
            states.append(list(d))
            if i == 1:
                checks[1] = int(d[0] == (181 if custom else 74))
            if i == 6:
                checks[0] = int(d[0] == target)
        return states, checks
    if topic == TOPICS[2]:
        a = 128 if custom else 1
        d = collision([0, a, 255 if wrong else 0, 2, a, 0 if custom else 1, 1, 0])
        states.append(list(d))
        checks = [int(d[0] == 0), int(d[2] == 0)]
        d[2] = 2
        d = collision(d)
        states.append(list(d))
        d[4] = 0
        d = collision(d)
        states.append(list(d))
        d[4] = a
        d[5:7] = [1, 1]
        d = collision(d)
        states.append(list(d))
        return states, checks
    cell, crate, dest, request = (9, 5, 1, 3) if custom else (5, 6, 7, 2)
    world = board([crate])
    if wrong:
        world[dest] = 1
    d = push([cell, 0, 0, request] + world)
    states.append(list(d))
    checks = [int(d[1] == 2), int(d[0] == crate)]
    d = push(d)
    states.append(list(d))
    d[3] = 2 if custom else 4
    d = push(d)
    states.append(list(d))
    d[3] = 0
    d = push(d)
    states.append(list(d))
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
