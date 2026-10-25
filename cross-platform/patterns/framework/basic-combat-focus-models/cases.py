"""Independent hit-set and eligible-focus policies."""

from __future__ import annotations

TOPICS = ["attack-hit-window", "interaction-focus"]
CATEGORIES = {t: "framework" for t in TOPICS}
LABELS = dict(zip(TOPICS, ["HITW RESULTS", "FOCS RESULTS"]))
FIELDS = {TOPICS[0]: list("HOMFABTCN"), TOPICS[1]: list("SOCARMDEFG")}
ARRAYS = {t: {} for t in TOPICS}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def attack(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 0]
    seen, frame, begin, end, target, contact, new = d[2:]
    if any(not byte(v) for v in d[2:]) or target > 7 or begin >= end:
        return d
    d[1] = 1
    remembered = {i for i in range(8) if int(seen) & 1 << i}
    if new:
        remembered.clear()
    if begin <= frame < end and contact and target not in remembered:
        d[0] = 1
        remembered.add(int(target))
    d[2] = sum(1 << i for i in remembered)
    return d


def focus(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [255, 0]
    current, active, limit, margin = d[2:6]
    if (
        any(not byte(v) for v in d[2:])
        or current not in [0, 1, 2, 3, 255]
        or active > 15
    ):
        return d
    d[1] = 1
    candidates = {
        i: d[6 + i] for i in range(4) if int(active) & 1 << i and d[6 + i] <= limit
    }
    if candidates:
        best = min(candidates, key=lambda i: (candidates[i], i))
        d[0] = (
            current
            if current in candidates
            and candidates[current] <= candidates[best] + margin
            else best
        )
    return d


FUNCTIONS = dict(zip(TOPICS, [attack, focus]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [199, 199] + list(v)
            for v in [
                (0, 1, 2, 5, 1, 1, 0),
                (0, 2, 2, 5, 1, 1, 0),
                (0, 4, 2, 5, 1, 1, 0),
                (0, 5, 2, 5, 1, 1, 0),
                (2, 3, 2, 5, 1, 1, 0),
                (2, 3, 2, 5, 2, 1, 0),
                (255, 3, 2, 5, 7, 1, 0),
                (127, 3, 2, 5, 7, 1, 0),
                (255, 0, 2, 5, 7, 1, 1),
                (255, 2, 2, 5, 7, 1, 255),
                (0, 2, 2, 5, 1, 0, 0),
                (99, 2, 2, 5, 8, 1, 1),
                (99, 2, 5, 5, 1, 1, 1),
                (99, 2, 5, 2, 1, 1, 1),
                (0, 254, 254, 255, 7, 255, 0),
                (0, 255, 254, 255, 7, 255, 0),
            ]
        ]
    return [
        [199, 199] + list(v)
        for v in [
            (1, 3, 20, 2, 9, 10, 30, 30),
            (1, 3, 20, 2, 8, 10, 30, 30),
            (1, 3, 20, 2, 7, 10, 30, 30),
            (3, 15, 10, 0, 10, 10, 10, 10),
            (255, 15, 10, 0, 10, 10, 10, 10),
            (1, 0, 20, 255, 0, 0, 0, 0),
            (1, 1, 20, 255, 9, 10, 30, 30),
            (1, 3, 9, 255, 9, 10, 30, 30),
            (0, 15, 0, 0, 0, 0, 1, 2),
            (255, 15, 255, 0, 255, 255, 255, 255),
            (3, 15, 255, 255, 0, 5, 9, 255),
            (4, 15, 10, 0, 0, 0, 0, 0),
            (254, 15, 10, 0, 0, 0, 0, 0),
            (1, 16, 10, 0, 0, 0, 0, 0),
            (2, 4, 5, 0, 255, 255, 5, 255),
            (2, 4, 4, 0, 255, 255, 5, 255),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    checks = []
    if topic == TOPICS[0]:
        begin, end, target, second = (1, 3, 7, 0) if custom else (2, 5, 1, 2)
        d = [0, 0, 0, begin, begin, end, target, 1, 1]
        for i, updates in enumerate(
            [
                {},
                {3: begin + 1, 8: 0},
                {6: second},
                {3: end, 6: 3},
                {3: begin, 6: target, 8: 1},
            ]
        ):
            for k, v in updates.items():
                d[k] = v
            if wrong:
                d[8] = 1
            d = attack(d)
            states.append(list(d))
            if i == 1:
                checks.append(int(d[0] == 0))
            if i == 2:
                checks.append(int(d[2] == (129 if custom else 6)))
        return states, checks
    d = (
        [0, 0, 3, 15, 10, 0, 10, 10, 10, 10]
        if custom
        else [0, 0, 1, 3, 20, 2, 9, 10, 30, 30]
    )
    for i, updates in enumerate(
        [{}, {6: 9 if custom else 8}, {3: 0} if custom else {6: 7}, {3: 16}]
    ):
        for k, v in updates.items():
            d[k] = v
        if wrong:
            d[2] = 255
        d = focus(d)
        states.append(list(d))
        if i == 0:
            checks = [
                int(d[0] == (3 if custom else 1)),
                int(d[2] == (3 if custom else 1)),
            ]
        if d[1]:
            d[2] = d[0]
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
