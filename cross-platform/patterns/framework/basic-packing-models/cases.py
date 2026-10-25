"""Independent integer bit fields and grouping/expansion contracts."""

from __future__ import annotations

from itertools import groupby

TOPICS = [
    "bounded-bit-reader",
    "bounded-bit-writer",
    "bounded-rle",
    "bounded-rle-encoder",
]
CATEGORIES = {t: "framework" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["BITS RESULTS", "PACK RESULTS", "RLE RESULTS", "RUN RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["V", "O", "C", "N"] + [f"B{i}" for i in range(1, 5)],
    TOPICS[1]: ["O", "C", "N", "V"] + [f"B{i}" for i in range(1, 5)],
    TOPICS[2]: ["W", "E", "S", "T", "L"]
    + [f"I{i}" for i in range(1, 14)]
    + [f"B{i}" for i in range(1, 9)],
    TOPICS[3]: ["W", "E", "O", "N", "C"]
    + [f"B{i}" for i in range(1, 9)]
    + [f"R{i}" for i in range(1, 17)],
}
ARRAYS = {
    TOPICS[0]: {"B": 4},
    TOPICS[1]: {"B": 4},
    TOPICS[2]: {"I": 13, "B": 8},
    TOPICS[3]: {"B": 8, "R": 16},
}
STREAM = [3, 65, 2, 66, 1, 67, 0, 90, 2, 68, 5, 69, 1]


def integer(v: int, lo: int, hi: int) -> bool:
    return lo <= v <= hi and int(v) == v


def read(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 0]
    cursor, count = d[2:4]
    if (
        not integer(cursor, 0, 32)
        or not integer(count, 0, 8)
        or cursor + count > 32
        or any(not integer(v, 0, 255) for v in d[4:])
    ):
        return d
    word = int.from_bytes(bytes(d[4:]), "big")
    d[:3] = [(word >> (32 - cursor - count)) & ((1 << count) - 1), 1, cursor + count]
    return d


def write(data: list[int]) -> list[int]:
    d = list(data)
    d[0] = 0
    cursor, count, value = d[1:4]
    if (
        not integer(cursor, 0, 32)
        or not integer(count, 0, 8)
        or cursor + count > 32
        or not integer(value, 0, 255)
        or any(not integer(v, 0, 255) for v in d[4:])
    ):
        return d
    shift = 32 - cursor - count
    mask = ((1 << count) - 1) << shift
    word = int.from_bytes(bytes(d[4:]), "big")
    word = (word & ~mask) | ((value << shift) & mask)
    d[4:] = word.to_bytes(4, "big")
    d[:2] = [1, cursor + count]
    return d


def decode(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 1]
    start, end, limit = d[2:5]
    stream = d[5:18]
    if (
        not integer(start, 0, 13)
        or not integer(end, start, 13)
        or not integer(limit, 0, 8)
        or any(not integer(v, 0, 255) for v in stream)
    ):
        return d
    d[1] = 0
    output = []
    for offset in range(start, end, 2):
        if offset + 1 >= end:
            d[1] = 2
            break
        count, value = stream[offset : offset + 2]
        if not count:
            d[1] = 3
            break
        room = limit - len(output)
        output.extend([value] * min(room, count))
        if count > room:
            d[1] = 4
            break
    d[0] = len(output)
    d[18 : 18 + len(output)] = output
    return d


def encode(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [0, 1, 0]
    count, capacity = d[3:5]
    if (
        not integer(count, 0, 8)
        or not integer(capacity, 0, 16)
        or any(not integer(v, 0, 255) for v in d[5 : 5 + int(count)])
    ):
        return d
    encoded = [
        v for value, g in groupby(d[5 : 5 + int(count)]) for v in [len(list(g)), value]
    ]
    d[2] = 1
    d[1] = 0
    if len(encoded) > capacity:
        d[1] = 2
        return d
    d[0] = len(encoded)
    d[13 : 13 + len(encoded)] = encoded
    return d


FUNCTIONS = dict(zip(TOPICS, [read, write, decode, encode]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic in TOPICS[:2]:
        result = []
        for cursor, count in [
            (0, 0),
            (0, 1),
            (0, 8),
            (4, 8),
            (7, 2),
            (8, 8),
            (15, 8),
            (24, 8),
            (31, 1),
            (31, 2),
            (32, 0),
            (32, 1),
            (33, 0),
            (0, 9),
            (255, 1),
            (1, 7),
        ]:
            result.append(
                (
                    [199, 199, cursor, count]
                    if topic == TOPICS[0]
                    else [199, cursor, count, 173]
                )
                + ([255, 0, 85, 170] if custom else [171, 205, 239, 1])
            )
        return result
    if topic == TOPICS[2]:
        return [
            [199, 199, s, t, l] + list(STREAM) + [99] * 8
            for s, t, l in [
                (0, 6, 8),
                (0, 6, 5),
                (0, 6, 6),
                (0, 6, 0),
                (0, 0, 0),
                (12, 13, 8),
                (6, 8, 8),
                (8, 12, 8),
                (13, 13, 8),
                (13, 12, 8),
                (0, 14, 8),
                (0, 6, 9),
                (0, 5, 8),
                (0, 6, 1),
                (1, 3, 8),
                (0, 2, 3),
            ]
        ]
    return [
        [199, 199, 199, n, c]
        + ([1, 2, 3, 4, 5, 6, 7, 8] if custom else [65, 65, 65, 66, 66, 67, 67, 67])
        + [99] * 16
        for n, c in [
            (0, 0),
            (0, 16),
            (1, 2),
            (8, 16),
            (8, 15),
            (8, 0),
            (9, 16),
            (8, 17),
            (3, 1),
            (3, 2),
            (4, 4),
            (5, 4),
            (6, 6),
            (7, 16),
            (8, 6),
            (255, 8),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = initial(topic)
        d[4:] = [171, 205, 239, 1]
        values = []
        for count in [8, 8, 8, 8] if custom else [4, 4, 8, 8, 8]:
            d[3] = count
            if wrong:
                d[2] = 0
            d = read(d)
            states.append(list(d))
            values.append(d[0])
        good = [171, 205, 239, 1] if custom else [10, 11, 205, 239, 1]
        checks = [int(d[2] == 32), int(values == good)]
    elif topic == TOPICS[1]:
        d = initial(topic)
        d[4:] = [85] * 4
        for count, value in (
            [(8, 171), (8, 205), (8, 239), (8, 1)]
            if custom
            else [(4, 10), (4, 11), (8, 205), (8, 239), (8, 1)]
        ):
            d[2:4] = [count, value]
            if wrong:
                d[1] = 0
            d = write(d)
            states.append(list(d))
        checks = [int(d[1] == 32), int(d[4:] == [171, 205, 239, 1])]
    elif topic == TOPICS[2]:
        d = [0, 0, 0, 6, 5 if custom else 8] + list(STREAM) + [99] * 8
        d = decode(d)
        if wrong:
            d[0] = d[4]
        states.append(list(d))
        length = 5 if custom else 6
        checks = [
            int(d[0] == length),
            int(sum(d[18 : 18 + d[0]]) == (327 if custom else 394)),
        ]
        d[2:5] = [12, 13, 8]
        d = decode(d)
        states.append(list(d))
        d[2:5] = [6, 8, 8]
        d = decode(d)
        states.append(list(d))
        d[2:5] = [0, 0, 0]
        d = decode(d)
        states.append(list(d))
    else:
        d = (
            [0, 0, 0, 8, 0 if wrong else 16]
            + ([1, 2, 3, 4, 5, 6, 7, 8] if custom else [65, 65, 65, 66, 66, 67, 67, 67])
            + [99] * 16
        )
        d = encode(d)
        states.append(list(d))
        expected = [v for k, g in groupby(d[5:13]) for v in [len(list(g)), k]]
        checks = [
            int(d[0] == len(expected)),
            int(d[13 : 13 + len(expected)] == expected),
        ]
        d[4] = 1
        d = encode(d)
        states.append(list(d))
        d[3:5] = [0, 0]
        d = encode(d)
        states.append(list(d))
        d[3:5] = [1, 2]
        d = encode(d)
        states.append(list(d))
    return states, checks


def packet(topic: str, variant: str) -> list[int]:
    custom = variant == "custom"
    states = [initial(topic)] + [FUNCTIONS[topic](d) for d in rows(topic, custom)]
    client, _checks = clients(topic, custom, variant == "wrong")
    states += client
    result = [v for d in states for v in d]
    assert len(result) < 995 and all(integer(v, 0, 255) for v in result)
    return result
