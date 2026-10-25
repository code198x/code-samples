"""Independent set transitions, fractional credits, active ticks and repeat deadlines."""

from __future__ import annotations

TOPICS = ["trigger-transitions", "rational-tick-divider", "pause-clock", "input-repeat"]
CATEGORIES = {t: "framework" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["TRIG RESULTS", "TICK RESULTS", "TIME RESULTS", "REPT RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["E", "S", "X", "P", "C", "O"],
    TOPICS[1]: ["P", "N", "D", "F", "O"],
    TOPICS[2]: ["L", "H", "P", "R", "O"],
    TOPICS[3]: ["H", "W", "T", "P", "D", "R", "O"],
}
ARRAYS = {t: {} for t in TOPICS}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def trigger(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [0, 0, 0]
    d[5] = 0
    if not byte(d[3]) or not byte(d[4]):
        return d
    previous = {i for i in range(8) if d[3] & (1 << i)}
    current = {i for i in range(8) if d[4] & (1 << i)}
    d[:3] = [
        sum(1 << i for i in group)
        for group in [current - previous, current & previous, previous - current]
    ]
    d[3] = d[4]
    d[5] = 1
    return d


def divider(data: list[int]) -> list[int]:
    d = list(data)
    d[3:] = [0, 0]
    phase, num, den = d[:3]
    if any(not byte(v) for v in d[:3]) or not den or num > den or phase >= den:
        return d
    count, new = divmod(phase + num, den)
    d[0] = new
    d[3:] = [count, 1]
    return d


def clock(data: list[int]) -> list[int]:
    d = list(data)
    d[4] = 0
    if any(not byte(v) for v in d[:4]):
        return d
    value = int.from_bytes(bytes(d[:2]), "little")
    value = 0 if d[3] else value if d[2] else (value + 1) % 65536
    d[:2] = list(value.to_bytes(2, "little"))
    d[4] = 1
    return d


def repeat(data: list[int]) -> list[int]:
    d = list(data)
    d[3] = d[6] = 0
    if (
        any(not byte(v) for v in [d[0], d[2], d[4], d[5]])
        or d[1] not in (0, 1)
        or not d[4]
        or not d[5]
    ):
        return d
    d[6] = 1
    if not d[0]:
        d[1:3] = [0, 0]
    elif not d[1]:
        d[1:4] = [1, d[4], 1]
    else:
        d[2] = max(0, d[2] - 1)
        if not d[2]:
            d[2] = d[5]
            d[3] = 1
    return d


FUNCTIONS = dict(zip(TOPICS, [trigger, divider, clock, repeat]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [199, 199, 199, p, c, 199]
            for p, c in [
                (0, 0),
                (0, 1),
                (1, 1),
                (1, 0),
                (1, 3),
                (3, 2),
                (128, 129),
                (255, 0),
                (0, 255),
                (255, 255),
                (85, 170),
                (170, 85),
                (128, 128),
                (127, 128),
                (255, 128),
                (128, 255),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            [p, n, d, 199, 199]
            for p, n, d in [
                (0, 3, 5),
                (2, 3, 5),
                (4, 3, 5),
                (0, 1, 3),
                (2, 1, 3),
                (0, 0, 1),
                (0, 1, 1),
                (254, 255, 255),
                (254, 1, 255),
                (254, 0, 255),
                (0, 0, 0),
                (5, 3, 5),
                (0, 6, 5),
                (255, 255, 255),
                (0, 255, 255),
                (0, 1, 255),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [l, h, p, r, 199]
            for l, h, p, r in [
                (0, 0, 0, 0),
                (255, 0, 0, 0),
                (255, 255, 0, 0),
                (255, 255, 1, 0),
                (255, 255, 1, 1),
                (123, 45, 0, 1),
                (123, 45, 255, 0),
                (123, 45, 0, 255),
                (0, 0, 1, 0),
                (0, 0, 1, 1),
                (254, 255, 0, 0),
                (0, 255, 0, 0),
                (255, 0, 255, 255),
                (255, 0, 0, 0),
                (254, 0, 0, 0),
                (1, 0, 0, 0),
            ]
        ]
    delay, rate = (6, 3) if custom else (4, 2)
    return [
        [h, w, t, 199, d, r, 199]
        for h, w, t, d, r in [
            (0, 0, 0, delay, rate),
            (1, 0, 0, delay, rate),
            (1, 1, 1, delay, rate),
            (1, 1, 2, delay, rate),
            (1, 1, 0, delay, rate),
            (0, 1, 4, delay, rate),
            (255, 0, 255, delay, rate),
            (255, 1, 255, delay, rate),
            (1, 2, 4, delay, rate),
            (1, 0, 0, 0, rate),
            (1, 0, 0, delay, 0),
            (1, 0, 0, 1, 1),
            (1, 1, 1, 1, 1),
            (1, 0, 0, 255, 255),
            (1, 1, 1, 255, 255),
            (0, 1, 255, delay, rate),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = initial(topic)
        ent = ex = 0
        for mask in [128, 128, 129, 1, 0, 128] if custom else [1, 1, 3, 2, 0, 1]:
            if wrong:
                d[3] = 0
            d[4] = mask
            d = trigger(d)
            states.append(list(d))
            ent += d[0]
            ex += d[2]
        return states, [
            int(ent == (257 if custom else 4)),
            int(ex == (129 if custom else 3)),
        ]
    if topic == TOPICS[1]:
        d = [0, 1 if custom else 3, 3 if custom else 5, 0, 0]
        count = 0
        for _ in range(12):
            if wrong:
                d[0] = 0
            d = divider(d)
            states.append(list(d))
            count += d[3]
        return states, [
            int(count == (4 if custom else 7)),
            int(d[0] == (0 if custom else 1)),
        ]
    if topic == TOPICS[2]:
        start = 255 if custom else 254
        d = [start, 0, 0, 0, 0]
        checks = []
        for i, (paused, reset) in enumerate(
            [(0, 0), (1, 0), (1, 0), (0, 0), (1, 1), (1, 0), (0, 0)]
        ):
            d[2:4] = [0 if wrong else paused, reset]
            d = clock(d)
            states.append(list(d))
            if i == 3:
                checks.append(int(d[0] + 256 * d[1] == start + 2))
        checks.append(int(d[:2] == [1, 0]))
        return states, checks
    delay, rate = (6, 3) if custom else (4, 2)
    d = [1, 0, 0, 0, delay, rate, 0]
    count = 0
    for _ in range(8):
        if wrong:
            d[1:3] = [0, 0]
        d = repeat(d)
        states.append(list(d))
        count += d[3]
    checks = [int(count == (2 if custom else 3)), int(d[2] == (2 if custom else 1))]
    for held in [0, 1]:
        d[0] = held
        d = repeat(d)
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
