"""Independent suffix matching, chord sets, intent vectors and axis intervals."""

from __future__ import annotations

TOPICS = ["input-sequence", "input-chord", "four-way-input", "analogue-deadzone"]
CATEGORIES = {t: "input" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["SEQU RESULTS", "CHRD RESULTS", "DIRS RESULTS", "AXIS RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["P", "Q", "M", "O"],
    TOPICS[1]: ["W", "H", "R", "F", "A", "E", "O"],
    TOPICS[2]: ["H", "A", "D", "O"],
    TOPICS[3]: ["S", "C", "R", "D", "M", "O"],
}
ARRAYS = {t: {} for t in TOPICS}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def sequence(data: list[int]) -> list[int]:
    d = list(data)
    d[2:] = [0, 0]
    p, q = d[:2]
    if not byte(p) or p > 3 or not byte(q) or q > 2:
        return d
    d[3] = 1
    if not q:
        return d
    word = [1, 2, 1, 2]
    history = word[:p] + [q]
    d[2] = int(history[-4:] == word)
    d[0] = max(n for n in range(4) if n == 0 or history[-n:] == word[:n])
    return d


def chord(data: list[int]) -> list[int]:
    d = list(data)
    d[4:] = [0, 0, 0]
    if (
        d[0] not in (0, 1)
        or any(not byte(v) for v in d[1:4])
        or not d[2]
        or d[2] & d[3]
    ):
        d[0] = 0
        return d
    held = {i for i in range(8) if d[1] & (1 << i)}
    required = {i for i in range(8) if d[2] & (1 << i)}
    forbidden = {i for i in range(8) if d[3] & (1 << i)}
    active = int(required <= held and not (forbidden & held))
    d[4:] = [active, int(active and not d[0]), 1]
    d[0] = active
    return d


def directions(data: list[int]) -> list[int]:
    d = list(data)
    d[2:] = [0, 0]
    if not byte(d[0]) or d[1] not in (0, 1):
        return d
    h = d[0]
    horizontal = int(bool(h & 2)) - int(bool(h & 1))
    vertical = int(bool(h & 8)) - int(bool(h & 4))
    axes = [horizontal, vertical]
    order = [d[1], 1 - d[1]]
    for axis in order:
        if axes[axis]:
            d[1] = axis
            d[2] = (
                (1 if axes[axis] < 0 else 2)
                if axis == 0
                else (3 if axes[axis] < 0 else 4)
            )
            break
    d[3] = 1
    return d


def analogue(data: list[int]) -> list[int]:
    d = list(data)
    d[3:] = [0, 0, 0]
    if any(not byte(v) for v in d[:3]) or d[2] > 127:
        return d
    sample, centre, radius = d[:3]
    low, high = centre - radius, centre + radius
    if sample < low:
        d[3:5] = [1, low - sample]
    elif sample > high:
        d[3:5] = [2, sample - high]
    d[5] = 1
    return d


FUNCTIONS = dict(zip(TOPICS, [sequence, chord, directions, analogue]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [p, q, 199, 199]
            for p, q in [
                (0, 0),
                (0, 1),
                (0, 2),
                (1, 1),
                (1, 2),
                (2, 1),
                (2, 2),
                (3, 1),
                (3, 2),
                (3, 0),
                (4, 1),
                (255, 1),
                (0, 3),
                (3, 255),
                (1, 0),
                (2, 0),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            [w, h, r, f, 199, 199, 199]
            for w, h, r, f in [
                (0, 3, 3, 4),
                (1, 3, 3, 4),
                (0, 1, 3, 4),
                (0, 7, 3, 4),
                (1, 7, 3, 4),
                (0, 129, 129, 2),
                (1, 129, 129, 2),
                (0, 131, 129, 2),
                (0, 0, 0, 0),
                (1, 255, 3, 1),
                (2, 3, 3, 4),
                (0, 255, 255, 0),
                (0, 128, 128, 127),
                (1, 0, 3, 4),
                (0, 255, 1, 128),
                (0, 1, 1, 0),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [h, a, 199, 199]
            for h, a in [
                (0, 0),
                (1, 0),
                (2, 0),
                (4, 0),
                (8, 0),
                (3, 0),
                (12, 1),
                (5, 0),
                (5, 1),
                (10, 0),
                (10, 1),
                (7, 0),
                (13, 1),
                (255, 1),
                (128, 0),
                (5, 2),
            ]
        ]
    radius = 16 if custom else 8
    return [
        [s, c, r, 199, 199, 199]
        for s, c, r in [
            (110, 100, radius),
            (100 - radius, 100, radius),
            (100 + radius, 100, radius),
            (99 - radius, 100, radius),
            (101 + radius, 100, radius),
            (100, 100, 0),
            (99, 100, 0),
            (101, 100, 0),
            (0, 255, 127),
            (255, 0, 127),
            (0, 0, 127),
            (255, 255, 127),
            (0, 255, 0),
            (255, 0, 0),
            (100, 100, 128),
            (100, 100, 255),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = initial(topic)
        count = 0
        for symbol in [1, 1, 2, 1, 2, 1, 2] if custom else [1, 2, 1, 2, 1, 2]:
            if wrong:
                d[0] = 0
            d[1] = symbol
            d = sequence(d)
            states.append(list(d))
            count += d[2]
        return states, [int(count == 2), int(d[0] == 2)]
    if topic == TOPICS[1]:
        required, forbidden, first = (129, 2, 128) if custom else (3, 4, 1)
        d = [0, 0, required, forbidden, 0, 0, 0]
        count = 0
        repeated = 0
        for i, held in enumerate(
            [0, first, required, required, required | forbidden, required, 0]
        ):
            if wrong:
                d[0] = 0
            d[1] = held
            d = chord(d)
            states.append(list(d))
            count += d[5]
            if i == 3:
                repeated = d[5]
        return states, [int(count == 2), int(repeated == 0)]
    if topic == TOPICS[2]:
        d = [0, 1 if custom else 0, 0, 0]
        for held in [5, 4, 5]:
            if wrong:
                d[1] = 0
            d[0] = held
            d = directions(d)
            states.append(list(d))
        return states, [int(d[2] == 3), int(d[1] == 1)]
    radius = 16 if custom else 8
    d = analogue([110, 0 if wrong else 100, radius, 0, 0, 0])
    states.append(list(d))
    checks = [int(d[4] == (0 if custom else 2)), int(d[1] == 100)]
    for sample in [100 - radius, 100 + radius, 99 - radius, 101 + radius]:
        d[0] = sample
        d = analogue(d)
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
    return result
