"""Independent XOR snapshots, edit logs, quiet delays and active intervals."""

from __future__ import annotations

CATEGORIES = {
    t: "framework"
    for t in ["checkpoint-state", "bounded-undo", "spawn-timeline", "timed-status"]
}
LABELS = {
    "checkpoint-state": "SAVE RESULTS",
    "bounded-undo": "UNDO RESULTS",
    "spawn-timeline": "WAVE RESULTS",
    "timed-status": "TIME RESULTS",
}
FIELDS = {
    "checkpoint-state": ["X", "Y", "R", "S", "T", "U", "K", "V", "M", "O", "E"],
    "bounded-undo": ["N", "M", "S", "V", "O", "E"]
    + [f"B{i}" for i in range(1, 17)]
    + [f"I{i}" for i in range(1, 5)]
    + [f"J{i}" for i in range(1, 5)],
    "spawn-timeline": ["C", "I", "W", "D", "R", "F", "O", "E"]
    + [f"A{i}" for i in range(1, 5)]
    + [f"L{i}" for i in range(1, 5)],
    "timed-status": ["R", "H", "D", "P", "A", "F", "O", "E"],
}
ARRAYS = {
    "checkpoint-state": {},
    "bounded-undo": {"B": 16, "I": 4, "J": 4},
    "spawn-timeline": {"A": 4, "L": 4},
    "timed-status": {},
}


def integral(v: int, lo: int, hi: int) -> bool:
    return lo <= v <= hi and v == int(v)


def snapshot(data: list[int]) -> list[int]:
    d = list(data)
    d[9:] = [0, 1]
    present, mode = d[7:9]
    if present not in [0, 1]:
        return d
    d[10] = 2
    if mode not in [0, 1]:
        return d
    if mode == 0:
        d[10] = 1
        if any(not integral(v, 0, 255) for v in d[:3]):
            return d
        d[3:6] = d[:3]
        d[6] = d[0] ^ d[1] ^ d[2]
        d[7] = 1
        d[9:] = [1, 0]
    else:
        d[10] = 0
        if not present:
            return d
        d[10] = 1
        if any(not integral(v, 0, 255) for v in d[3:7]):
            return d
        d[10] = 3
        if d[6] != (d[3] ^ d[4] ^ d[5]):
            return d
        d[:3] = d[3:6]
        d[9:] = [1, 0]
    return d


def undo(data: list[int]) -> list[int]:
    d = list(data)
    count, mode, cell, value = d[:4]
    d[4:6] = [0, 1]
    if not integral(count, 0, 4):
        return d
    d[5] = 2
    if not integral(mode, 0, 2):
        return d
    if mode == 2:
        d[0] = 0
        d[4:6] = [1, 0]
        return d
    d[5] = 1
    board = d[6:22]
    log = list(zip(d[22 : 22 + count], d[26 : 26 + count]))
    if any(not integral(v, 0, 255) for v in board) or any(
        not integral(i, 0, 15) or not integral(v, 0, 255) for i, v in log
    ):
        return d
    if mode == 0:
        d[5] = 2
        if not integral(cell, 0, 15) or not integral(value, 0, 255):
            return d
        d[5] = 0
        if count == 4:
            return d
        d[22 + count] = cell
        d[26 + count] = board[cell]
        d[6 + cell] = value
        d[0] += 1
        d[4] = 1
    else:
        d[5] = 0
        if not log:
            return d
        target, old = log[-1]
        d[6 + target] = old
        d[0] -= 1
        d[4] = 1
    return d


def timeline(data: list[int]) -> list[int]:
    d = list(data)
    count, index, wait, done = d[:4]
    d[4:8] = [255, 0, 0, 1]
    if (
        not integral(count, 1, 4)
        or not integral(index, 0, count - 1)
        or not integral(wait, 0, 255)
        or done not in [0, 1]
        or any(not integral(v, 0, 255) for v in d[8 : 8 + count] + d[12 : 12 + count])
    ):
        return d
    d[6:8] = [1, 0]
    if done:
        return d
    quiet = d[12 + index]
    if wait < quiet:
        d[2] += 1
    else:
        d[2] = 0
        d[4:6] = [d[8 + index], 1]
        if index + 1 < count:
            d[1] += 1
        else:
            d[3] = 1
    return d


def status(data: list[int]) -> list[int]:
    d = list(data)
    remaining, phase, duration, period, apply = d[:5]
    d[5:] = [0, 0, 1]
    if (
        not integral(remaining, 0, 255)
        or not integral(duration, 0, 255)
        or not integral(period, 1, 255)
        or not integral(phase, 0, period - 1)
    ):
        return d
    d[7] = 2
    if apply not in [0, 1]:
        return d
    r = duration if apply else remaining
    h = 0 if apply else phase
    d[6:] = [1, 0]
    if r:
        elapsed = h + 1
        d[5] = int(elapsed == period)
        r -= 1
        h = elapsed % period
    d[:2] = [r, h if r else 0]
    return d


FUNCTIONS = {
    "checkpoint-state": snapshot,
    "bounded-undo": undo,
    "spawn-timeline": timeline,
    "timed-status": status,
}


def initial(topic: str, custom: bool = False) -> list[int]:
    if topic == "spawn-timeline":
        return [4, 0, 0, 0, 255, 0, 0, 0] + [0] * 8
    if topic == "timed-status":
        return [0, 0, 5 if custom else 6, 3 if custom else 2, 0, 0, 0, 0]
    return [0] * len(FIELDS[topic])


def rows(topic: str, custom: bool = False) -> list[list[int]]:
    if topic == "checkpoint-state":
        out = []
        for live, saved, k, present, mode in [
            ([10, 20, 3], [9, 9, 9], 9, 0, 0),
            ([255, 0, 255], [9, 9, 9], 9, 1, 0),
            ([99, 98, 97], [10, 20, 3], 29, 1, 1),
            ([99, 98, 97], [10, 20, 3], 0, 1, 1),
            ([99, 98, 97], [0, 0, 0], 0, 1, 1),
            ([99, 98, 97], [10, 20, 3], 29, 0, 1),
            ([99, 98, 97], [10, 20, 3], 29, 2, 1),
            ([1, 2, 3], [4, 5, 6], 7, 0, 2),
            ([99, 98, 97], [20, 10, 3], 29, 1, 1),
            ([0, 0, 0], [255, 255, 255], 255, 1, 1),
            ([1, 2, 3], [255, 255, 255], 0, 1, 0),
        ]:
            out.append(live + saved + [k, present, mode, 9, 9])
        return out
    if topic == "bounded-undo":
        out = []
        for n, m, s, v, indices in [
            (0, 0, 0, 1, [0, 1, 2, 3]),
            (0, 1, 255, 255, [0, 1, 2, 3]),
            (4, 0, 15, 255, [0, 1, 2, 3]),
            (4, 1, 255, 255, [0, 1, 2, 3]),
            (0, 0, 16, 1, [0, 1, 2, 3]),
            (5, 0, 0, 1, [0, 1, 2, 3]),
            (2, 1, 0, 0, [0, 16, 2, 3]),
            (2, 2, 255, 255, [0, 16, 2, 3]),
            (2, 3, 0, 0, [0, 1, 2, 3]),
            (1, 0, 15, 0, [0, 1, 2, 3]),
            (2, 1, 0, 0, [0, 15, 2, 3]),
            (0, 2, 255, 255, [255] * 4),
        ]:
            out.append(
                [n, m, s, v, 9, 9] + list(range(16)) + indices + [20, 21, 22, 23]
            )
        return out
    if topic == "spawn-timeline":
        return [
            [c, i, w, d, 9, 9, 9, 9] + events + delays
            for c, i, w, d, events, delays in [
                (4, 0, 0, 0, [10, 20, 30, 40], [1, 0, 2, 1]),
                (4, 0, 1, 0, [10, 20, 30, 40], [1, 0, 2, 1]),
                (4, 1, 0, 0, [10, 20, 30, 40], [1, 0, 2, 1]),
                (4, 3, 1, 0, [10, 20, 30, 40], [1, 0, 2, 1]),
                (4, 3, 0, 1, [10, 20, 30, 40], [1, 0, 2, 1]),
                (1, 0, 254, 0, [255, 0, 0, 0], [255, 0, 0, 0]),
                (1, 0, 255, 0, [255, 0, 0, 0], [255, 0, 0, 0]),
                (1, 0, 0, 0, [0, 0, 0, 0], [0, 0, 0, 0]),
                (0, 0, 0, 0, [0] * 4, [0] * 4),
                (5, 0, 0, 0, [0] * 4, [0] * 4),
                (4, 4, 0, 0, [0] * 4, [0] * 4),
                (4, 0, 0, 2, [0] * 4, [0] * 4),
            ]
        ]
    out = []
    for r, h, d, p, a in [
        (0, 0, 6, 2, 0),
        (0, 0, 6, 2, 1),
        (1, 1, 6, 2, 0),
        (1, 0, 6, 2, 0),
        (4, 1, 0, 2, 1),
        (4, 1, 5, 3, 1),
        (0, 2, 5, 3, 0),
        (255, 254, 255, 255, 0),
        (1, 0, 1, 1, 1),
        (0, 0, 0, 1, 1),
        (4, 0, 6, 0, 1),
        (4, 2, 6, 2, 1),
        (4, 0, 6, 2, 2),
    ]:
        out.append([r, h, d, p, a, 9, 9, 9])
    return out


def clients(topic: str, custom: bool, wrong: bool) -> list[list[int]]:
    out = []
    if topic == "checkpoint-state":
        live = [40, 60, 5] if custom else [10, 20, 3]
        d = initial(topic)
        d[:3] = live
        d = snapshot(d)
        out.append(list(d))
        d[:3] = [200, 201, 1]
        if wrong:
            d[6] = 0
        d[8] = 1
        d = snapshot(d)
        out.append(list(d))
        d[3] += 1
        d = snapshot(d)
        out.append(list(d))
        d[7] = 0
        d = snapshot(d)
        out.append(list(d))
        d[8] = 0
        d = snapshot(d)
        out.append(list(d))
        d[8] = 1
        d = snapshot(d)
        out.append(list(d))
        return out
    if topic == "bounded-undo":
        cell = 15 if custom else 0
        old = 11 if custom else 7
        values = [20, 30] if custom else [9, 12]
        d = initial(topic)
        d[6 + cell] = old
        for value in values:
            d[1:4] = [0, cell, value]
            if wrong:
                d[6 + cell] = value
            d = undo(d)
            out.append(list(d))
        for _ in range(2):
            d[1] = 1
            d = undo(d)
            out.append(list(d))
        for i in range(1, 5):
            d[1:4] = [0, i, 20 + i]
            d = undo(d)
            out.append(list(d))
        d[1:4] = [0, 7, 99]
        d = undo(d)
        out.append(list(d))
        d[1] = 2
        d = undo(d)
        out.append(list(d))
        d[1] = 1
        d = undo(d)
        out.append(list(d))
        return out
    if topic == "spawn-timeline":
        d = initial(topic)
        d[8:] = [10, 20, 30, 40] + ([0] * 4 if custom else [1, 0, 2, 1])
        for _ in range(12):
            if wrong:
                d[1] = 0
            d = timeline(d)
            out.append(list(d))
        return out
    d = initial(topic, custom)
    d[4] = 1
    for _ in range(8):
        if wrong:
            d[4] = 1
        d = status(d)
        out.append(list(d))
        d[4] = 0
    return out


def packet(topic: str, variant: str) -> list[int]:
    custom = variant == "custom"
    states = (
        [initial(topic, custom)]
        + [FUNCTIONS[topic](r) for r in rows(topic, custom)]
        + clients(topic, custom, variant == "wrong")
    )
    assert all(len(r) == len(FIELDS[topic]) for r in states)
    result = [v for r in states for v in r]
    assert len(result) < 995 and all(integral(v, 0, 255) for v in result)
    return result
