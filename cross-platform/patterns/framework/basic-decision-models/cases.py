"""Independent slot sets, ASCII roundtrips, trailing sample runs and grid coordinates."""

from __future__ import annotations

TOPICS = [
    "bitset-slot-allocation",
    "hexadecimal-byte-codec",
    "input-debounce",
    "grid-turn-buffer",
]
CATEGORIES = dict(zip(TOPICS, ["framework", "framework", "input", "framework"]))
LABELS = dict(
    zip(TOPICS, ["SLOT RESULTS", "HEXA RESULTS", "STAB RESULTS", "TURN RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["S", "R", "O", "U", "M", "Q"],
    TOPICS[1]: ["V", "H", "L", "C", "M", "O"],
    TOPICS[2]: ["S", "P", "C", "R", "X", "T", "O"],
    TOPICS[3]: ["C", "D", "P", "M", "O", "R"] + [f"B{i}" for i in range(1, 17)],
}
ARRAYS = {TOPICS[0]: {}, TOPICS[1]: {}, TOPICS[2]: {}, TOPICS[3]: {"B": 16}}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def slots(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [255, 0, 0]
    used, mode, request = d[3:]
    if (
        not byte(used)
        or not byte(request)
        or mode not in (0, 1)
        or (mode == 1 and request > 7)
    ):
        return d
    d[2] = 1
    occupied = {i for i in range(8) if int(used) & (1 << i)}
    if mode == 0:
        available = set(range(8)) - occupied
        if not available:
            return d
        choice = min(available)
        occupied.add(choice)
    else:
        choice = int(request)
        if choice not in occupied:
            return d
        occupied.remove(choice)
    d[:4] = [choice, 1, 1, sum(1 << i for i in occupied)]
    return d


def codec(data: list[int]) -> list[int]:
    d = list(data)
    d[5] = 0
    if d[4] not in (0, 1):
        return d
    if d[4] == 0:
        d[1:3] = [0, 0]
        if not byte(d[0]) or not byte(d[3]):
            return d
        digits = format(int(d[0]), "02x" if d[3] else "02X")
        d[1:3] = list(map(ord, digits))
    else:
        d[0] = 0
        if not byte(d[1]) or not byte(d[2]):
            return d
        digits = chr(int(d[1])) + chr(int(d[2]))
        if any(c not in "0123456789abcdefABCDEF" for c in digits):
            return d
        d[0] = int(digits, 16)
    d[5] = 1
    return d


def debounce(data: list[int]) -> list[int]:
    d = list(data)
    d[1] = d[6] = 0
    if any(not byte(v) for v in [d[0], d[2], d[3], d[4], d[5]]):
        return d
    d[6] = 1
    if not d[5]:
        d[3] = 0
        return d
    history = [d[2]] * int(d[3]) + [d[4]]
    run = 0
    for value in reversed(history):
        if value != history[-1]:
            break
        run += 1
    d[2] = history[-1]
    d[3] = min(255, run)
    if d[3] >= d[5] and d[0] != d[2]:
        d[0] = d[2]
        d[1] = 1
    return d


def neighbour(cell: int, direction: int, world: list[int]) -> int | None:
    dx, dy = {1: (-1, 0), 2: (1, 0), 3: (0, -1), 4: (0, 1)}[direction]
    row, col = divmod(int(cell), 4)
    row += dy
    col += dx
    if not (0 <= row < 4 and 0 <= col < 4):
        return None
    result = row * 4 + col
    return result if world[result] == 0 else None


def turns(data: list[int]) -> list[int]:
    d = list(data)
    d[3:5] = [0, 0]
    if (
        not byte(d[0])
        or d[0] > 15
        or any(not byte(v) or v > 4 for v in [d[1], d[2], d[5]])
        or any(not byte(v) for v in d[6:])
    ):
        return d
    world = d[6:]
    if world[int(d[0])]:
        return d
    d[4] = 1
    if d[5]:
        d[2] = d[5]
    for direction, is_pending in [(d[2], True), (d[1], False)]:
        if not direction:
            continue
        target = neighbour(d[0], direction, world)
        if target is None:
            continue
        d[0] = target
        d[3] = 1
        if is_pending:
            d[1] = direction
            d[2] = 0
        break
    return d


FUNCTIONS = dict(zip(TOPICS, [slots, codec, debounce, turns]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def world(walls: list[int]) -> list[int]:
    return [int(i in walls) for i in range(16)]


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [199, 199, 199, u, m, q]
            for u, m, q in [
                (0, 0, 255),
                (1, 0, 0),
                (254, 0, 0),
                (255, 0, 0),
                (128, 0, 0),
                (255, 1, 7),
                (128, 1, 7),
                (0, 1, 0),
                (1, 1, 0),
                (3, 1, 1),
                (0, 1, 7),
                (255, 1, 8),
                (255, 2, 0),
                (85, 0, 0),
                (170, 1, 7),
                (255, 1, 255),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            list(v) + [199]
            for v in [
                (0, 199, 199, 0, 0),
                (9, 199, 199, 0, 0),
                (10, 199, 199, 1, 0),
                (15, 199, 199, 255, 0),
                (16, 199, 199, 0, 0),
                (165, 199, 199, 1 if custom else 0, 0),
                (255, 199, 199, 0, 0),
                (199, 48, 48, 0, 1),
                (199, 53, 65, 0, 1),
                (199, 97, 102, 255, 1),
                (199, 70, 70, 0, 1),
                (199, 47, 48, 0, 1),
                (199, 71, 48, 0, 1),
                (199, 48, 103, 0, 1),
                (199, 255, 0, 0, 1),
                (165, 65, 53, 0, 2),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [s, 199, c, r, x, t, 199]
            for s, c, r, x, t in [
                (0, 0, 0, 1, 3),
                (0, 1, 1, 1, 3),
                (0, 1, 2, 1, 3),
                (1, 1, 3, 1, 3),
                (1, 1, 255, 1, 255),
                (0, 1, 254, 1, 255),
                (0, 1, 255, 1, 255),
                (1, 1, 3, 0, 3),
                (1, 0, 2, 0, 3),
                (1, 0, 3, 0, 3),
                (0, 0, 0, 255, 1),
                (255, 255, 255, 0, 1),
                (5, 7, 12, 9, 0),
                (5, 7, 0, 7, 1),
                (5, 7, 2, 7, 2),
                (5, 7, 3, 7, 255),
            ]
        ]
    return [
        [c, d, p, 199, 199, r] + world(w)
        for c, d, p, r, w in [
            (8, 2, 0, 3, [4]),
            (9, 2, 3, 0, [4]),
            (0, 1, 0, 0, []),
            (3, 2, 0, 0, []),
            (0, 3, 0, 0, []),
            (15, 4, 0, 0, []),
            (0, 0, 0, 0, []),
            (0, 2, 3, 4, []),
            (0, 2, 3, 0, []),
            (0, 0, 3, 0, []),
            (0, 2, 0, 0, [1]),
            (0, 2, 0, 0, [0]),
            (16, 2, 0, 0, []),
            (0, 5, 0, 0, []),
            (0, 2, 5, 0, []),
            (0, 2, 0, 255, []),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = [0, 0, 0, 254 if custom else 0, 0, 0]
        checks = []
        for i, (mode, request) in enumerate([(0, 0), (0, 0), (1, 0), (0, 0)]):
            if wrong:
                d[3] = 0
            d[4:] = [mode, request]
            d = slots(d)
            states.append(list(d))
            if i == 1:
                checks = [
                    int(d[0] == (255 if custom else 1)),
                    int(d[3] == (255 if custom else 3)),
                ]
        return states, checks
    if topic == TOPICS[1]:
        d = codec([165, 0, 0, 1 if custom else 0, 0, 0])
        if wrong:
            d[1:3] = [d[2], d[1]]
        states.append(list(d))
        checks = [int(d[1] == (97 if custom else 65))]
        d[4] = 1
        d = codec(d)
        states.append(list(d))
        checks.append(int(d[0] == 165))
        d[1:3] = [71, 48]
        d = codec(d)
        states.append(list(d))
        d[0] = 255
        d[4] = 0
        d = codec(d)
        states.append(list(d))
        return states, checks
    if topic == TOPICS[2]:
        d = [0, 0, 0, 0, 0, 2 if custom else 3, 0]
        count = 0
        for raw in [1, 0, 1, 1, 1, 1, 0, 0, 0]:
            if wrong:
                d[3] = 0
            d[4] = raw
            d = debounce(d)
            states.append(list(d))
            count += d[1]
        return states, [int(count == 2), int(d[3] == 3)]
    d = [8, 2, 0, 0, 0, 0] + world([4, 5] if custom else [4])
    for request in [3, 0, 0, 0] if custom else [3, 0, 0]:
        if wrong:
            d[2] = 0
        d[5] = request
        d = turns(d)
        states.append(list(d))
    checks = [int(d[0] == (2 if custom else 1)), int(d[1] == 3)]
    d[5] = 4
    if wrong:
        d[2] = 0
    d = turns(d)
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
