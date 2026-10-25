"""Independent menu sets, counted edits, unpacked cells and linear envelope states."""

from __future__ import annotations

TOPICS = [
    "menu-navigation",
    "text-entry-buffer",
    "packed-nibble-map",
    "logical-envelope",
]
CATEGORIES = dict(zip(TOPICS, ["input", "input", "rendering", "audio"]))
LABELS = dict(
    zip(TOPICS, ["MENU RESULTS", "TEXT RESULTS", "CELL RESULTS", "ENVE RESULTS"])
)
FIELDS = {
    TOPICS[0]: ["S", "C", "E", "D", "M", "O"],
    TOPICS[1]: ["L", "S", "K", "M", "C"] + [f"B{i}" for i in range(1, 9)],
    TOPICS[2]: ["V", "O", "C", "W", "N"] + [f"B{i}" for i in range(1, 9)],
    TOPICS[3]: ["L", "P", "W", "O", "G", "A", "D", "S", "R"],
}
ARRAYS = {TOPICS[0]: {}, TOPICS[1]: {"B": 8}, TOPICS[2]: {"B": 8}, TOPICS[3]: {}}
BYTES = [18, 52, 86, 120, 154, 188, 222, 240]


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def menu(data: list[int]) -> list[int]:
    d = list(data)
    d[4:] = [0, 0]
    selected, count, enabled, delta = d[:4]
    if (
        not byte(count)
        or not 1 <= count <= 8
        or not byte(selected)
        or selected >= count
        or not byte(enabled)
        or delta not in (0, 1, 255)
    ):
        return d
    d[5] = 1
    if not delta:
        return d
    step = 1 if delta == 1 else -1
    order = [(selected + step * n) % count for n in range(1, count + 1)]
    choice = next((i for i in order if enabled & (1 << i)), selected)
    d[0] = choice
    d[4] = int(choice != selected)
    return d


def text(data: list[int]) -> list[int]:
    d = list(data)
    d[1] = 3
    length, _status, key, mode, cap = d[:5]
    if not byte(cap) or not 1 <= cap <= 8 or mode not in (0, 1, 2):
        return d
    if mode == 2:
        d[0] = 0
        d[1] = 1
        d[5:] = [0] * 8
        return d
    if not byte(length) or length > cap or any(not byte(v) for v in d[5:]):
        return d
    live = list(d[5 : 5 + length])
    d[1] = 0
    if mode == 0:
        if not byte(key) or not 32 <= key <= 126:
            d[1] = 2
            return d
        if length == cap:
            return d
        d[5 + length] = key
        d[0] = length + 1
        d[1] = 1
    elif live:
        d[5 + length - 1] = 0
        d[0] = length - 1
        d[1] = 1
    return d


def packed(data: list[int]) -> list[int]:
    d = list(data)
    d[:2] = [0, 0]
    cell, write, new = d[2:5]
    if any(not byte(v) for v in d[2:]) or cell > 15 or (write and new > 15):
        return d
    cells = [nibble for b in d[5:] for nibble in [b // 16, b % 16]]
    if write:
        cells[cell] = new
        d[5:] = [16 * cells[i] + cells[i + 1] for i in range(0, 16, 2)]
    d[:2] = [cells[cell], 1]
    return d


def envelope(data: list[int]) -> list[int]:
    d = list(data)
    d[3] = 0
    level, phase, previous, _valid, gate, attack, decay, sustain, release = d
    if (
        not byte(level)
        or level > 15
        or not byte(phase)
        or phase > 4
        or previous not in (0, 1)
        or not byte(gate)
        or any(not byte(v) or not 1 <= v <= 15 for v in [attack, decay, release])
        or not byte(sustain)
        or sustain > 15
    ):
        return d
    if gate:
        if not previous:
            level, phase = 0, 1
        previous = 1
    else:
        previous = 0
        if phase:
            phase = 4
    if phase == 0:
        level = 0
    elif phase == 1:
        level = min(15, level + attack)
        if level == 15:
            phase = 2
    elif phase == 2:
        level = max(sustain, level - decay)
        if level == sustain:
            phase = 3
    elif phase == 3:
        level = sustain
    else:
        level = max(0, level - release)
        if not level:
            phase = 0
    d[:4] = [level, phase, previous, 1]
    return d


FUNCTIONS = dict(zip(TOPICS, [menu, text, packed, envelope]))


def initial(topic: str) -> list[int]:
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool) -> list[list[int]]:
    if topic == TOPICS[0]:
        return [
            list(v) + [199, 199]
            for v in [
                (2, 3, 5, 1),
                (0, 3, 7, 255),
                (0, 3, 2, 1),
                (0, 3, 2, 255),
                (0, 3, 0, 1),
                (0, 3, 0, 0),
                (2, 3, 4, 1),
                (2, 3, 4, 255),
                (7, 8, 128, 1),
                (7, 8, 1, 1),
                (0, 8, 128, 255),
                (0, 3, 128, 1),
                (0, 0, 0, 1),
                (0, 9, 255, 1),
                (3, 3, 7, 1),
                (0, 3, 7, 2),
            ]
        ]
    if topic == TOPICS[1]:
        cap = 4 if custom else 8
        return [
            [length, 199, key, mode, cap] + list(buf)
            for length, key, mode, buf in [
                (0, 65, 0, [0] * 8),
                (cap, 66, 0, [65] * 8),
                (0, 66, 1, [0] * 8),
                (1, 66, 1, [65] + [0] * 7),
                (0, 31, 0, [0] * 8),
                (0, 32, 0, [0] * 8),
                (0, 126, 0, [0] * 8),
                (0, 127, 0, [0] * 8),
                (cap - 1, 90, 0, [65] * 8),
                (255, 0, 0, [0] * 8),
                (255, 255, 2, [255] * 8),
                (cap, 0, 2, [65] * 8),
                (0, 65, 3, [0] * 8),
                (0, 255, 1, [0] * 8),
                (1, 255, 2, [65] + [7] * 7),
                (0, 255, 0, [0] * 8),
            ]
        ]
    if topic == TOPICS[2]:
        return [
            [199, 199, c, w, n] + list(b)
            for c, w, n, b in [
                (0, 0, 255, BYTES),
                (1, 0, 0, BYTES),
                (15, 0, 0, BYTES),
                (0, 1, 0, BYTES),
                (1, 1, 15, BYTES),
                (15, 1, 15, BYTES),
                (14, 1, 0, BYTES),
                (16, 0, 0, BYTES),
                (255, 1, 1, BYTES),
                (0, 1, 16, BYTES),
                (0, 1, 255, BYTES),
                (7, 255, 0, BYTES),
                (8, 0, 255, [255] * 8),
                (9, 1, 0, [255] * 8),
                (0, 0, 0, [0] * 8),
                (15, 1, 15, [0] * 8),
            ]
        ]
    return [
        [l, p, w, 199, g, a, d, s, r]
        for l, p, w, g, a, d, s, r in [
            (0, 0, 0, 0, 4, 3, 6, 2),
            (0, 0, 0, 1, 4, 3, 6, 2),
            (14, 1, 1, 1, 4, 3, 6, 2),
            (15, 2, 1, 1, 4, 3, 6, 2),
            (7, 2, 1, 1, 4, 3, 6, 2),
            (6, 3, 1, 1, 4, 3, 6, 2),
            (6, 3, 1, 0, 4, 3, 6, 2),
            (1, 4, 0, 0, 4, 3, 6, 2),
            (8, 2, 0, 255, 8, 4, 5, 3),
            (16, 0, 0, 1, 4, 3, 6, 2),
            (0, 5, 0, 1, 4, 3, 6, 2),
            (0, 0, 2, 1, 4, 3, 6, 2),
            (0, 0, 0, 1, 0, 3, 6, 2),
            (0, 0, 0, 1, 4, 16, 6, 2),
            (0, 0, 0, 1, 4, 3, 16, 2),
            (0, 0, 0, 1, 4, 3, 6, 0),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    states = []
    if topic == TOPICS[0]:
        d = [0 if custom else 2, 3, 7 if custom else 5, 255 if custom else 1, 0, 0]
        if wrong:
            d[0] += d[3]
            d[3] = 0
        d = menu(d)
        states.append(list(d))
        checks = [int(d[0] == (2 if custom else 0)), int(d[5] == 1)]
        for values in [(0, 3, 0, 1), (7, 8, 128, 1), (7, 8, 128, 255), (0, 3, 3, 255)]:
            d[:4] = values
            d = menu(d)
            states.append(list(d))
        return states, checks
    if topic == TOPICS[1]:
        cap = 4 if custom else 8
        d = [cap if wrong else 0, 0, 65, 0, cap] + [0] * 8
        d = text(d)
        states.append(list(d))
        checks = [int(d[1] == 1), int(d[0] == 1 and d[5] == 65)]
        for key, mode in [(66, 0), (0, 1), (0, 2), (67, 0), (0, 1), (0, 1)]:
            d[2:4] = [key, mode]
            d = text(d)
            states.append(list(d))
        return states, checks
    if topic == TOPICS[2]:
        cell, new = (15, 7) if custom else (9, 3)
        d = packed([0, 0, 0 if wrong else cell, 1, new] + BYTES)
        states.append(list(d))
        d[2:5] = [cell, 0, 255]
        d = packed(d)
        states.append(list(d))
        checks = [int(d[0] == new), int(d[5] == 18)]
        d[2] = cell - 1
        d = packed(d)
        states.append(list(d))
        d[2:5] = [16, 1, 15]
        d = packed(d)
        states.append(list(d))
        return states, checks
    attack, decay, sustain, release, held = (
        (8, 4, 5, 3, 3) if custom else (4, 3, 6, 2, 8)
    )
    d = [0, 0, 0, 0, 0, attack, decay, sustain, release]
    checks = []
    for i, gate in enumerate([1] * held + [0] * 4):
        if wrong:
            d[2] = 0
        d[4] = gate
        d = envelope(d)
        states.append(list(d))
        if i == (15 + attack - 1) // attack - 1:
            checks.append(int(d[0] == 15 and d[1] == 2))
        if i == held:
            checks.append(int(d[0] == (8 if custom else 4)))
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
