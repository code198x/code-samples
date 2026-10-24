"""Independent list/deque description of a BASIC bounded FIFO."""

from __future__ import annotations

from collections import deque

FIELDS = ["C", "H", "T", "N", "V", "M", "O", "E"] + ["Q" + str(i) for i in range(1, 9)]
LABEL = "FIFO RESULTS"


def rows(cap: int) -> list[list[int]]:
    result = []
    for i in range(20):
        n = i % (cap + 1)
        h = i % cap
        t = (h + n) % cap
        d = [cap, h, t, n, [0, 1, 255, 128][i % 4], 1 + i % 2, 9, 9] + [
            (j * 17 + i) % 256 for j in range(8)
        ]
        if i == 12:
            d[0] = 0
        if i == 13:
            d[1] = cap
        if i == 14:
            d[2] = (t + 1) % cap
        if i == 15:
            d[3] = cap + 1
        if i == 16:
            d[0] = 9
        if i == 17:
            d[8 + h] = 255
            d[4] = 255
        result.append(d)
    return result


def call(row: list[int]) -> list[int]:
    d = list(row)
    cap, h, t, n, v, mode, _, _ = d[:8]
    d[6:8] = [0, 1]
    if not (1 <= cap <= 8 and 0 <= h < cap and 0 <= t < cap and 0 <= n <= cap):
        return d
    if any(int(x) != x for x in [cap, h, t, n]) or t != (h + n) % cap:
        return d
    values = deque(d[8 + (h + i) % cap] for i in range(n))
    if any(not 0 <= x <= 255 or int(x) != x for x in values):
        return d
    d[7] = 0
    if mode == 1:
        if not 0 <= v <= 255 or int(v) != v:
            d[7] = 2
            return d
        if n == cap:
            return d
        values.append(v)
        d[8 + t] = v
        d[2] = (h + len(values)) % cap
        d[3] = len(values)
        d[6] = 1
    else:
        if not values:
            return d
        d[4] = values.popleft()
        d[1] = (h + 1) % cap
        d[3] = len(values)
        d[6] = 1
    return d


def initial(cap: int) -> list[int]:
    return [cap, 0, 0, 0, 0, 0, 0, 0] + [0] * 8


def packet(variant: str) -> list[int]:
    cap = 4 if variant == "custom" else 8
    d = initial(cap)
    out = list(d)
    for row in rows(cap):
        out += call(row)
    d = initial(cap)
    for i in range(cap + 1):
        d[4:6] = [10 + i, 1]
        d = call(d)
        out += d
    # Wrong caller erases the queue at the consumer boundary.
    if variant == "wrong":
        d = initial(cap)
    for _ in range(2):
        d[5] = 2
        d = call(d)
        out += d
    for i in range(3):
        d[4:6] = [100 + i, 1]
        d = call(d)
        out += d
    for _ in range(cap + 2):
        d[5] = 2
        d = call(d)
        out += d
    return out
