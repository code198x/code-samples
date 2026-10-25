"""Independent stable queue, cyclic selection, signed sums and first-match models."""

from __future__ import annotations

from itertools import accumulate

TOPICS = [
    "priority-event-queue",
    "round-robin-service",
    "bounded-delta-decoder",
    "dictionary-lookup",
]
CATEGORIES = {t: "framework" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["PRIO RESULTS", "TURN RESULTS", "MOVE RESULTS", "FIND RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["V", "P", "R", "O", "N", "M", "E", "D"]
    + [f"A{i}" for i in range(1, 5)]
    + [f"B{i}" for i in range(1, 5)],
    TOPICS[1]: ["S", "F", "N", "M", "O"],
    TOPICS[2]: ["W", "O", "N", "B"]
    + [f"Q{i}" for i in range(1, 9)]
    + [f"R{i}" for i in range(1, 9)],
    TOPICS[3]: ["V", "F", "O", "K", "N"]
    + [f"A{i}" for i in range(1, 9)]
    + [f"B{i}" for i in range(1, 9)],
}
ARRAYS = {
    TOPICS[0]: {"A": 4, "B": 4},
    TOPICS[1]: {},
    TOPICS[2]: {"Q": 8, "R": 8},
    TOPICS[3]: {"A": 8, "B": 8},
}


def integer(v: int, lo: int, hi: int) -> bool:
    return lo <= v <= hi and int(v) == v


def queue(data: list[int]) -> list[int]:
    d = list(data)
    d[:4] = [255, 0, 0, 0]
    count, mode, event, priority = d[4:8]
    if not integer(count, 0, 4) or mode not in [0, 1]:
        return d
    entries = list(zip(d[8 : 8 + count], d[12 : 12 + count]))
    if any(
        not integer(e, 0, 255) or not integer(p, 0, 255) for e, p in entries
    ) or entries != sorted(entries, key=lambda item: -item[1]):
        return d
    if mode == 0 and any(not integer(v, 0, 255) for v in [event, priority]):
        return d
    d[3] = 1
    if (mode == 0 and count == 4) or (mode == 1 and count == 0):
        return d
    if mode == 0:
        entries.append((event, priority))
        entries.sort(key=lambda item: -item[1])
        returned = (event, priority)
    else:
        returned = entries.pop(0)
    d[:3] = [*returned, 1]
    d[4] = len(entries)
    for j, (e, p) in enumerate(entries):
        d[8 + j] = e
        d[12 + j] = p
    if mode == 1:
        d[8 + len(entries)] = 0
        d[12 + len(entries)] = 0
    return d


def robin(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [255, 0]
    d[4] = 0
    start, mask = d[2:4]
    if not integer(start, 0, 255) or not integer(mask, 0, 255):
        return d
    start %= 8
    d[2] = start
    d[4] = 1
    eligible = {i for i in range(8) if mask & (1 << i)}
    if not eligible:
        return d
    chosen = min(eligible, key=lambda i: (i - start) % 8)
    d[:3] = [chosen, 1, (chosen + 1) % 8]
    return d


def delta(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 0]
    count, base = d[2:4]
    if (
        not integer(count, 0, 8)
        or not integer(base, 0, 255)
        or any(not integer(v, 0, 255) for v in d[4 : 4 + int(count)])
    ):
        return d
    signed = [v if v < 128 else v - 256 for v in d[4 : 4 + count]]
    result = [v % 256 for v in list(accumulate(signed, initial=base))[1:]]
    d[:2] = [count, 1]
    d[12 : 12 + count] = result
    return d


def lookup(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [0, 0, 0]
    key, count = d[3:5]
    if not integer(count, 0, 8) or not integer(key, 0, 255):
        return d
    pairs = list(zip(d[5 : 5 + count], d[13 : 13 + count]))
    if any(not integer(k, 0, 255) or not integer(v, 0, 255) for k, v in pairs):
        return d
    d[2] = 1
    found = next((v for k, v in pairs if k == key), None)
    if found is not None:
        d[:2] = [found, 1]
    return d


FUNCTIONS = dict(zip(TOPICS, [queue, robin, delta, lookup]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        cases = []
        for count, mode, event, priority in [
            (0, 1, 1, 1),
            (0, 0, 255, 255),
            (1, 0, 22, 9),
            (2, 0, 22, 9),
            (4, 0, 22, 255),
            (4, 1, 0, 0),
            (1, 1, 255, 255),
            (0, 2, 1, 1),
            (5, 0, 1, 1),
            (255, 1, 1, 1),
            (3, 0, 33, 0),
            (3, 1, 0, 0),
            (4, 1, 0, 0),
            (4, 0, 33, 0),
            (2, 0, 0, 0),
            (0, 0, 0, 0),
        ]:
            cases.append(
                [199] * 4
                + [count, mode, event, priority]
                + [11, 12, 13, 14]
                + ([1, 2, 3, 4] if len(cases) == 12 else [9, 9, 3, 0])
            )
        return cases
    if topic == TOPICS[1]:
        return [
            [199, 199, n, m, 199]
            for n, m in [
                (0, 0),
                (0, 1),
                (0, 128),
                (7, 129),
                (255, 255),
                (8, 1),
                (15, 1),
                (2, 21),
                (3, 21),
                (4, 21),
                (5, 21),
                (6, 0),
                (254, 2),
                (1, 170),
                (7, 85),
                (255, 0),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [199, 199, n, b]
            + (
                [10, 128, 255, 1, 127, 129, 0, 5]
                if custom
                else [1, 255, 2, 254, 10, 0, 1, 255]
            )
            + [99] * 8
            for n, b in [
                (0, 0),
                (0, 255),
                (1, 0),
                (1, 255),
                (2, 0),
                (2, 255),
                (8, 100),
                (8, 250),
                (9, 1),
                (255, 1),
                (3, 128),
                (7, 127),
                (4, 0),
                (5, 255),
                (6, 10),
                (8, 0),
            ]
        ]
    return [
        [199, 199, 199, k, n]
        + [0, 7, 7, 255, 8, 9, 10, 11]
        + [11, 99, 88, 0, 18, 19, 20, 21]
        for k, n in [
            (0, 0),
            (0, 1),
            (7, 1),
            (7, 2),
            (7, 3),
            (255, 4),
            (9, 4),
            (9, 8),
            (11, 8),
            (255, 8),
            (7, 9),
            (7, 255),
            (0, 8),
            (8, 5),
            (10, 7),
            (255, 3),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = initial(topic)
        for event, priority in [
            (11, 0 if custom else 1),
            (22, 255 if custom else 9),
            (33, 255 if custom else 9),
            (44, 1 if custom else 3),
        ]:
            d[5:8] = [0, event, 0 if wrong else priority]
            d = queue(d)
            states.append(list(d))
        events = []
        priorities = []
        for _ in range(5):
            d[5] = 1
            d = queue(d)
            states.append(list(d))
            events.append(d[0])
            priorities.append(d[1])
        checks = [
            int(events[:4] == [22, 33, 44, 11]),
            int(priorities[:4] == ([255, 255, 1, 0] if custom else [9, 9, 3, 1])),
        ]
    elif topic == TOPICS[1]:
        d = [255, 0, 7 if custom else 0, 129 if custom else 21, 0]
        for _ in range(6):
            if wrong:
                d[2] = 0
            d = robin(d)
            states.append(list(d))
        checks = [
            int(sum(v[0] for v in states) == (21 if custom else 12)),
            int(sum(2 ** v[0] for v in states) == (387 if custom else 42)),
        ]
    elif topic == TOPICS[2]:
        base = 250 if custom else 100
        d = (
            [0, 0, 8, 0 if wrong else base]
            + (
                [10, 128, 255, 1, 127, 129, 0, 5]
                if custom
                else [1, 255, 2, 254, 10, 0, 1, 255]
            )
            + [99] * 8
        )
        d = delta(d)
        states.append(list(d))
        expected = (
            [4, 132, 131, 132, 3, 132, 132, 137]
            if custom
            else [101, 100, 102, 100, 110, 110, 111, 110]
        )
        checks = [int(d[12:] == expected), int(d[3] == base)]
        for count, b in [(0, 200), (9, 200), (3, 200)]:
            d[2:4] = [count, b]
            d = delta(d)
            states.append(list(d))
    else:
        key = 255 if custom else 7
        d = (
            [0, 0, 0, 0 if wrong else key, 4]
            + [0, 7, 7, 255, 8, 9, 10, 11]
            + [11, 99, 88, 0, 18, 19, 20, 21]
        )
        d = lookup(d)
        states.append(list(d))
        checks = [int(d[0] == (0 if custom else 99)), int(d[1] == 1 and d[3] == key)]
        for k in [7, 9, 255, 0]:
            d[3] = k
            d = lookup(d)
            states.append(list(d))
    return states, checks


def packet(topic: str, variant: str) -> list[int]:
    states = [initial(topic)] + [
        FUNCTIONS[topic](d) for d in rows(topic, variant == "custom")
    ]
    client, _checks = clients(topic, variant == "custom", variant == "wrong")
    states += client
    result = [v for d in states for v in d]
    assert len(result) < 995 and all(integer(v, 0, 255) for v in result)
    return result
