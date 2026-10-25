"""Independent polynomial, decimal and stable-container reference models."""

from __future__ import annotations

TOPICS = ["streaming-crc8", "decimal-parser", "decimal-format", "high-score-insertion"]
CATEGORIES = {t: "framework" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["CRC RESULTS", "READ RESULTS", "TEXT RESULTS", "RANK RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["R", "D", "P", "O"],
    TOPICS[1]: ["V", "C", "S"],
    TOPICS[2]: ["L", "H", "O"] + [f"D{i}" for i in range(1, 6)],
    TOPICS[3]: ["R", "F", "O", "V", "T", "N"]
    + [f"S{i}" for i in range(1, 5)]
    + [f"I{i}" for i in range(1, 5)],
}
ARRAYS = {
    TOPICS[0]: {},
    TOPICS[1]: {},
    TOPICS[2]: {"D": 5},
    TOPICS[3]: {"S": 4, "I": 4},
}


def integer(v: int, lo: int, hi: int) -> bool:
    return lo <= v <= hi and int(v) == v


def crc(data: list[int]) -> list[int]:
    d = list(data)
    r, b, p = d[:3]
    d[3] = 0
    if any(not integer(v, 0, 255) for v in [r, b]) or p not in [7, 49]:
        return d
    dividend = (r ^ b) << 8
    divisor = 256 | p
    while dividend.bit_length() >= divisor.bit_length():
        dividend ^= divisor << (dividend.bit_length() - divisor.bit_length())
    d[0] = dividend
    d[3] = 1
    return d


def parse(data: list[int]) -> list[int]:
    d = list(data)
    v, c = d[:2]
    d[2] = 4
    if not integer(v, 0, 255) or not integer(c, 0, 255):
        return d
    d[2] = 2
    if not 48 <= c <= 57:
        return d
    candidate = int(str(v) + chr(c))
    d[2] = 3
    if candidate > 255:
        return d
    d[0] = candidate
    d[2] = 1
    return d


def format_decimal(data: list[int]) -> list[int]:
    d = list(data)
    d[2] = 0
    if any(not integer(v, 0, 255) for v in d[:2]):
        return d
    d[3:] = list(map(ord, f"{d[0] + 256 * d[1]:05d}"))
    d[2] = 1
    return d


def score(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [255, 0, 0]
    value, tag, count = d[3:6]
    if not integer(count, 0, 4) or any(not integer(v, 0, 255) for v in [value, tag]):
        return d
    entries = list(zip(d[6 : 6 + int(count)], d[10 : 10 + int(count)]))
    if any(
        not integer(v, 0, 255) or not integer(t, 0, 255) for v, t in entries
    ) or entries != sorted(entries, key=lambda item: -item[0]):
        return d
    d[2] = 1
    rank = sum(v >= value for v, _ in entries)
    if rank == 4:
        return d
    entries.insert(rank, (value, tag))
    entries = entries[:4]
    d[:2] = [rank, 1]
    d[5] = len(entries)
    for j, (v, t) in enumerate(entries):
        d[6 + j] = v
        d[10 + j] = t
    return d


FUNCTIONS = dict(zip(TOPICS, [crc, parse, format_decimal, score]))


def initial(topic: str) -> list[int]:
    d = [0] * len(FIELDS[topic])
    if topic == TOPICS[3]:
        d[0] = 255
    return d


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            [r, d, 49 if custom else p, 199]
            for r, d, p in [
                (0, 0, 7),
                (0, 49, 7),
                (255, 255, 7),
                (244, 0, 7),
                (0, 255, 7),
                (255, 0, 7),
                (1, 1, 7),
                (128, 128, 7),
                (99, 57, 7),
                (0, 0, 49),
                (0, 49, 49),
                (255, 255, 49),
                (99, 57, 49),
                (0, 49, 0),
                (0, 49, 255),
                (175, 57, 7),
            ]
        ]
    if topic == TOPICS[1]:
        return [
            [v, c, 199]
            for v, c in [
                (0, 48),
                (0, 57),
                (2, 53),
                (25, 53),
                (25, 54),
                (255, 48),
                (26, 48),
                (0, 47),
                (0, 58),
                (0, 0),
                (0, 255),
                (9, 57),
                (99, 57),
                (24, 57),
                (25, 52),
                (100, 49),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [n % 256, n // 256, 199] + [99] * 5
            for n in [
                0,
                1,
                9,
                10,
                99,
                100,
                255,
                256,
                999,
                1000,
                4096,
                9999,
                10000,
                32768,
                65534,
                65535,
            ]
        ]
    cases = []
    for count, value, tag, scores in [
        (0, 0, 0, []),
        (0, 255, 255, []),
        (1, 100, 2, [100]),
        (2, 100, 3, [100, 80]),
        (4, 0, 9, [255, 100, 100, 0]),
        (4, 1, 9, [255, 100, 100, 0]),
        (4, 255, 9, [255, 100, 100, 0]),
        (4, 100, 9, [255, 100, 100, 0]),
        (4, 0, 9, [255, 100, 100, 1]),
        (3, 50, 4, [100, 90, 80]),
        (3, 200, 4, [100, 90, 80]),
        (4, 200, 4, [1, 2, 3, 4]),
        (5, 50, 1, [100] * 4),
        (255, 50, 1, [100] * 4),
        (2, 0, 4, [0, 0]),
        (4, 255, 5, [255] * 4),
    ]:
        cases.append(
            [199, 199, 199, value, tag, count]
            + scores
            + [77] * (4 - len(scores))
            + [1, 2, 3, 4]
        )
    return cases


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = [0, 0, 49 if custom else 7, 0]
        for b in b"123456789":
            d[1] = b
            if wrong:
                d[0] = 0
            d = crc(d)
            states.append(list(d))
        checks = [
            int(d[0] == (162 if custom else 244)),
            int(sum(v[0] for v in states) == (1353 if custom else 1670)),
        ]
    elif topic == TOPICS[1]:
        d = initial(topic)
        for c in "104" if custom else "2565":
            d[1] = ord(c)
            if wrong:
                d[0] = 0
            d = parse(d)
            states.append(list(d))
        checks = [
            int(d[0] == (104 if custom else 255)),
            int(sum(v[0] for v in states) == (115 if custom else 307)),
        ]
    elif topic == TOPICS[2]:
        n = 4096 if custom else 65535
        d = [n % 256, 0 if wrong else n // 256, 0] + [0] * 5
        d = format_decimal(d)
        states.append(list(d))
        checks = [int(d[1] == n // 256), int(d[3:] == list(map(ord, f"{n:05d}")))]
        for n in [0, 1, 9999, 10000]:
            d[0:2] = [n % 256, n // 256]
            d = format_decimal(d)
            states.append(list(d))
    else:
        d = initial(topic)
        values = [255, 0, 255, 1, 0] if custom else [100, 80, 100, 90, 70, 255, 0]
        for tag, value in enumerate(values, 1):
            d[3:5] = [0 if wrong else value, tag]
            d = score(d)
            states.append(list(d))
        expected = [255, 255, 1, 0] if custom else [255, 100, 100, 90]
        tags = [1, 3, 4, 2] if custom else [6, 1, 3, 4]
        checks = [int(d[6:10] == expected), int(d[10:14] == tags)]
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
