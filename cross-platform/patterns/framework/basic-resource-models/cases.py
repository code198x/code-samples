"""Independent action expiry, resource conservation, wide score and XOR sequences."""

from __future__ import annotations

TOPICS = ["action-cooldown", "resource-wallet", "score-counter", "seeded-random"]
CATEGORIES = {t: "framework" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["COOL RESULTS", "FUND RESULTS", "SCOR RESULTS", "RAND RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["R", "Q", "A", "P", "M", "G", "O"],
    TOPICS[1]: ["B", "A", "M", "O", "E"],
    TOPICS[2]: ["L", "H", "A", "B", "C", "D", "F", "O"],
    TOPICS[3]: ["R", "S", "M", "O"],
}
ARRAYS = {t: {} for t in TOPICS}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def cooldown(data: list[int]) -> list[int]:
    d = list(data)
    d[5:] = [0, 0]
    if any(not byte(v) for v in d[:5]) or d[4] not in (0, 1):
        return d
    d[6] = 1
    if d[4] == 0:
        d[0] = max(0, d[0] - 1)
    elif not d[0] and d[1] and d[2]:
        d[0] = d[3]
        d[5] = 1
    return d


def wallet(data: list[int]) -> list[int]:
    d = list(data)
    d[3:] = [0, 1]
    if any(not byte(v) for v in d[:3]) or d[2] not in (0, 1):
        return d
    d[4] = 0
    if d[2] == 0:
        d[0] = min(255, d[0] + d[1])
        d[3] = 1
    elif d[0] >= d[1]:
        d[0] -= d[1]
        d[3] = 1
    return d


def score(data: list[int]) -> list[int]:
    d = list(data)
    d[6:] = [0, 0]
    if any(not byte(v) for v in d[:6]):
        return d
    old = int.from_bytes(bytes(d[:2]), "little")
    award = int.from_bytes(bytes(d[2:4]), "little")
    cap = int.from_bytes(bytes(d[4:6]), "little")
    if old > cap:
        return d
    new = min(cap, old + award)
    d[:2] = list(new.to_bytes(2, "little"))
    d[6:] = [int(old + award > cap), 1]
    return d


def random(data: list[int]) -> list[int]:
    d = list(data)
    d[3] = 0
    if any(not byte(v) for v in d[:3]) or d[2] not in (0, 1):
        return d
    if d[2] == 0:
        d[0] = d[1] or 1
    elif not d[0]:
        return d
    else:
        d[0] = (d[0] >> 1) ^ (180 if d[0] & 1 else 0)
    d[3] = 1
    return d


FUNCTIONS = dict(zip(TOPICS, [cooldown, wallet, score, random]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            list(v) + [199, 199]
            for v in [
                (0, 1, 1, 3, 1),
                (1, 1, 1, 3, 1),
                (1, 1, 1, 3, 0),
                (255, 255, 255, 255, 0),
                (0, 0, 1, 3, 1),
                (0, 1, 0, 3, 1),
                (0, 255, 255, 0, 1),
                (0, 255, 255, 255, 1),
                (0, 0, 0, 0, 0),
                (2, 0, 0, 5, 0),
                (0, 1, 1, 3, 2),
                (255, 1, 1, 3, 255),
                (255, 1, 1, 3, 1),
                (0, 255, 1, 1, 1),
                (0, 1, 255, 5, 1),
                (2, 0, 0, 5, 1),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            list(v) + [199, 199]
            for v in [
                (3, 5, 1),
                (3, 2, 1),
                (255, 1, 0),
                (0, 255, 1),
                (255, 255, 1),
                (255, 0, 1),
                (0, 0, 0),
                (0, 0, 1),
                (0, 255, 0),
                (254, 1, 0),
                (254, 2, 0),
                (5, 6, 1),
                (5, 5, 1),
                (255, 255, 0),
                (3, 1, 2),
                (3, 1, 255),
            ]
        ]
    if topic == TOPICS[2]:
        cap = 999 if custom else 65535
        vals = [
            (0, 0),
            (0, 300),
            (250, 300),
            (cap, 0),
            (cap, 1),
            (cap - 1, 1),
            (cap - 1, 2),
            (0, 65535),
            (min(cap, 255), 256),
            (min(cap, 256), 255),
            (cap // 2, cap - cap // 2),
            (cap // 2, cap - cap // 2 + 1),
            (min(cap, 1), 65535),
            (0, 1),
            (min(cap, 999), 0),
            (65535, 0),
        ]
        return [
            [n % 256, n // 256, a % 256, a // 256, cap % 256, cap // 256, 199, 199]
            for n, a in vals
        ]
    return [
        list(v) + [199]
        for v in [
            (0, 0, 0),
            (0, 167, 0),
            (255, 255, 0),
            (0, 1, 0),
            (1, 0, 1),
            (2, 255, 1),
            (3, 0, 1),
            (255, 0, 1),
            (128, 0, 1),
            (180, 0, 1),
            (0, 0, 1),
            (0, 255, 1),
            (1, 1, 2),
            (255, 0, 255),
            (90, 0, 1),
            (39, 167, 1),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = [0, 0, 1, 5 if custom else 3, 0, 0, 0]
        count = 0
        for request in [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]:
            d[1] = request
            d[4] = 0
            if not wrong or request:
                d = cooldown(d)
            states.append(list(d))
            d[4] = 1
            d = cooldown(d)
            states.append(list(d))
            count += d[5]
        return states, [
            int(count == (2 if custom else 4)),
            int(d[0] == (0 if custom else 1)),
        ]
    if topic == TOPICS[1]:
        d = wallet([3, 2 if custom else 5, 0 if wrong else 1, 0, 0])
        states.append(list(d))
        checks = [
            int(d[3] == (1 if custom else 0) and d[2] == 1),
            int(d[0] == (1 if custom else 3)),
        ]
        for amount, mode in [(255, 0), (250, 1), (6, 1)]:
            d[1:3] = [amount, 0 if wrong else mode]
            d = wallet(d)
            states.append(list(d))
        return states, checks
    if topic == TOPICS[2]:
        cap = 999 if custom else 65535
        d = [250, 0, 44, 0 if wrong else 1, cap % 256, cap // 256, 0, 0]
        d = score(d)
        states.append(list(d))
        checks = [int(d[0] + 256 * d[1] == 550), int(d[3] == 1)]
        for award in [65000, 0]:
            d[2:4] = [award % 256, 0 if wrong else award // 256]
            d = score(d)
            states.append(list(d))
        return states, checks
    d = [0, 167 if custom else 0, 0, 0]
    if not wrong:
        d = random(d)
    states.append(list(d))
    for _ in range(8):
        d[2] = 1
        d = random(d)
        states.append(list(d))
    expected = 167 if custom else 1
    for _ in range(8):
        expected = (expected >> 1) ^ (180 if expected & 1 else 0)
    checks = [int(d[0] == expected), int(d[3] == 1)]
    # Restore the saved state through the documented external seed path, then draw again.
    saved = d[0]
    d[1:3] = [saved, 0]
    d = random(d)
    states.append(list(d))
    d[2] = 1
    d = random(d)
    states.append(list(d))
    return states, checks


def packet(topic: str, variant: str) -> list[int]:
    states = (
        [initial(topic)]
        + [FUNCTIONS[topic](r) for r in rows(topic, variant == "custom")]
        + clients(topic, variant == "custom", variant == "wrong")[0]
    )
    result = [v for d in states for v in d]
    assert len(result) < 995 and all(byte(v) for v in result)
    return result
