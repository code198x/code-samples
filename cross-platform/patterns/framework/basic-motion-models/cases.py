"""Independent opaque sets, signed fixed-point sums, clamps and folded motion."""

from __future__ import annotations

TOPICS = [
    "pixel-mask-collision",
    "fractional-position",
    "bounded-acceleration",
    "reflected-axis",
]
CATEGORIES = {t: "physics" for t in TOPICS}
LABELS = dict(
    zip(TOPICS, ["MASK RESULTS", "STEP RESULTS", "PUSH RESULTS", "BOUN RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["F", "R", "X", "Y", "O"]
    + [f"P{i}" for i in range(1, 9)]
    + [f"Q{i}" for i in range(1, 9)],
    TOPICS[1]: ["L", "H", "U", "V", "O"],
    TOPICS[2]: ["L", "H", "A", "B", "C", "D", "F", "O"],
    TOPICS[3]: ["P", "A", "B", "D", "S", "C", "O"],
}
ARRAYS = {TOPICS[0]: {"P": 8, "Q": 8}, TOPICS[1]: {}, TOPICS[2]: {}, TOPICS[3]: {}}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def signed(word: int) -> int:
    return word if word < 32768 else word - 65536


def word(value: int) -> list[int]:
    return [value % 256, (value % 65536) // 256]


def mask(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 255]
    d[4] = 0
    if any(not byte(v) for v in d[2:4] + d[5:]):
        return d
    d[4] = 1
    x, y = d[2:4]
    p = {
        (col, row)
        for row, bits in enumerate(d[5:13])
        for col in range(8)
        if bits & (128 >> col)
    }
    q = {
        (col + x, row + y)
        for row, bits in enumerate(d[13:21])
        for col in range(8)
        if bits & (128 >> col)
    }
    overlap = p & q
    if overlap:
        d[:2] = [1, min(row for _, row in overlap)]
    return d


def position(data: list[int]) -> list[int]:
    d = list(data)
    d[4] = 0
    if any(not byte(v) for v in d[:4]):
        return d
    p = d[0] + 256 * d[1]
    v = signed(d[2] + 256 * d[3])
    d[:2] = word(p + v)
    d[4] = 1
    return d


def acceleration(data: list[int]) -> list[int]:
    d = list(data)
    d[6:] = [0, 0]
    if any(not byte(v) for v in d[:6]) or d[5] >= 128:
        return d
    velocity = signed(d[0] + 256 * d[1])
    accel = signed(d[2] + 256 * d[3])
    limit = d[4] + 256 * d[5]
    total = velocity + accel
    bounded = min(limit, max(-limit, total))
    d[:2] = word(bounded)
    d[6:] = [int(total != bounded), 1]
    return d


def reflect(data: list[int]) -> list[int]:
    d = list(data)
    d[5:] = [0, 0]
    p, a, b, distance, direction = d[:5]
    if (
        any(not byte(v) for v in d[:4])
        or direction not in [0, 1]
        or a >= b
        or not a <= p <= b
    ):
        return d
    width = b - a
    offset = p - a
    remaining = width - offset if direction else offset
    count = 0 if distance <= remaining else 1 + (distance - remaining - 1) // width
    phase = (offset + (distance if direction else -distance)) % (2 * width)
    d[0] = a + min(phase, 2 * width - phase)
    d[4] = direction ^ (count % 2)
    d[5:] = [count, 1]
    return d


FUNCTIONS = dict(zip(TOPICS, [mask, position, acceleration, reflect]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        v = []

        def add(x, y, p, q):
            v.append([199, 199, x, y, 199] + p + q)

        for x, y, p, q in [
            (0, 0, [128] + [0] * 7, [128] + [0] * 7),
            (1, 0, [128] + [0] * 7, [128] + [0] * 7),
            (1, 0, [64] + [0] * 7, [128] + [0] * 7),
            (0, 1, [0, 128] + [0] * 6, [128] + [0] * 7),
            (0, 7, [0] * 7 + [128], [128] + [0] * 7),
            (0, 8, [255] * 8, [255] * 8),
            (8, 0, [255] * 8, [255] * 8),
            (255, 0, [255] * 8, [255] * 8),
            (0, 255, [255] * 8, [255] * 8),
            (0, 0, [255] * 8, [255] * 8),
            (0, 0, [0] * 8, [255] * 8),
            (0, 0, [255] * 8, [0] * 8),
            (7, 0, [1] + [0] * 7, [128] + [0] * 7),
            (7, 0, [128] + [0] * 7, [1] + [0] * 7),
            (0, 0, [0] * 4 + [128, 0, 128, 0], [0] * 4 + [128, 0, 128, 0]),
            (3, 2, [0, 0, 0, 16, 0, 0, 0, 0], [0, 128, 0, 0, 0, 0, 0, 0]),
        ]:
            add(x, y, p, q)
        return v
    if topic == TOPICS[1]:
        return [
            list(v) + [199]
            for v in [
                (0, 0, 64, 0),
                (0, 100, 64, 0),
                (192, 100, 64, 0),
                (255, 255, 1, 0),
                (0, 0, 255, 255),
                (0, 100, 128, 255),
                (0, 0, 0, 128),
                (0, 128, 0, 128),
                (255, 127, 1, 0),
                (255, 255, 255, 127),
                (1, 0, 255, 255),
                (0, 0, 0, 0),
                (128, 255, 128, 0),
                (255, 0, 1, 0),
                (0, 255, 0, 1),
                (255, 255, 255, 255),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            word(v) + word(a) + word(limit) + [199, 199]
            for v, a, limit in [
                (0, -128, 512),
                (-384, -128, 512),
                (-512, -128, 512),
                (512, 128, 512),
                (32767, 32767, 32767),
                (-32768, -32768, 32767),
                (32767, -32768, 32767),
                (-32768, 32767, 32767),
                (0, 0, 0),
                (1, 0, 0),
                (0, -1, 0),
                (100, -50, 20),
                (100, -150, 20),
                (100, 0, 32768),
                (-100, 0, 65535),
                (-32768, 0, 32767),
            ]
        ]
    return [
        list(v) + [199, 199]
        for v in [
            (8, 0, 10, 7, 1),
            (2, 0, 3, 7, 1),
            (0, 0, 1, 255, 0),
            (1, 0, 1, 255, 1),
            (0, 0, 10, 10, 1),
            (10, 0, 10, 10, 0),
            (10, 0, 10, 1, 1),
            (0, 0, 10, 1, 0),
            (5, 0, 10, 0, 0),
            (5, 0, 10, 0, 1),
            (10, 10, 10, 1, 1),
            (10, 20, 0, 1, 1),
            (0, 1, 10, 3, 1),
            (11, 0, 10, 3, 0),
            (5, 0, 10, 7, 2),
            (254, 0, 255, 255, 1),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = (
            [0, 0, 0 if wrong else 1, 0, 0]
            + [0] * 4
            + [64 if custom else 128]
            + [0] * 3
            + [0] * 4
            + [128]
            + [0] * 3
        )
        d = mask(d)
        states.append(list(d))
        checks = [int(d[:2] == ([1, 4] if custom else [0, 255])), int(d[2] == 1)]
        for x, y in [(0, 0), (1, 1), (8, 0)]:
            d[2:4] = [x, y]
            d = mask(d)
            states.append(list(d))
    elif topic == TOPICS[1]:
        d = [0, 100, 128 if custom else 64, 0, 0]
        for _ in range(4):
            if wrong:
                d[0] = 0
            d = position(d)
            states.append(list(d))
        checks = [int(d[1] == (102 if custom else 101)), int(d[0] == 0)]
        d[2:4] = [128, 255]
        d = position(d)
        states.append(list(d))
        d[2:4] = [0, 0]
        d = position(d)
        states.append(list(d))
    elif topic == TOPICS[2]:
        d = [0, 0, 128, 0 if wrong else 255, 0, 1 if custom else 2, 0, 0]
        for _ in range(4):
            d = acceleration(d)
            states.append(list(d))
        checks = [int(d[:2] == [0, 255 if custom else 254]), int(d[3] == 255)]
        d = acceleration(d)
        states.append(list(d))
        d[5] = 128
        d = acceleration(d)
        states.append(list(d))
        d[4:6] = [0, 0]
        d = acceleration(d)
        states.append(list(d))
    else:
        d = [2 if custom else 8, 0, 3 if custom else 10, 1 if wrong else 7, 1, 0, 0]
        for _ in range(4):
            d = reflect(d)
            states.append(list(d))
        checks = [
            int(
                states[0][0] == (3 if custom else 5)
                and states[0][5] == (2 if custom else 1)
            ),
            int(d[3] == 7),
        ]
        d[3] = 0
        d = reflect(d)
        states.append(list(d))
        d[4] = 2
        d = reflect(d)
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
