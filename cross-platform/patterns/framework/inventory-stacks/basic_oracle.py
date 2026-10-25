"""Independent whole-request bounded stock changes for BASIC."""

from __future__ import annotations

FIELDS = ["S", "A", "M", "C", "O", "E"] + ["Q" + str(i) for i in range(1, 5)]
LABEL = "PACK RESULTS"


def initial(cap: int) -> list[int]:
    return [0, 0, 0, cap, 0, 0] + [0] * 4


def call(row: list[int]) -> list[int]:
    d = list(row)
    s, a, m, c, _, _ = d[:6]
    d[4:6] = [0, 1]
    if (
        not 1 <= c <= 255
        or int(c) != c
        or any(int(x) != x or not 0 <= x <= c for x in d[6:])
    ):
        return d
    d[5] = 2
    if (
        not 0 <= s < 4
        or int(s) != s
        or not 0 <= a <= 255
        or int(a) != a
        or m not in [0, 1]
    ):
        return d
    d[5] = 0
    new = d[6 + s] + (-a if m else a)
    if 0 <= new <= c:
        d[6 + s] = new
        d[4] = 1
    return d


def rows(custom: bool) -> list[list[int]]:
    cap = 9 if custom else 99
    out = []
    for i in range(32):
        row = [i % 4, [0, 1, cap, 255][i % 4], i % 2, cap, 9, 9] + [
            (i + j) % (cap + 1) for j in range(4)
        ]
        if i == 24:
            row[0] = 4
        if i == 25:
            row[0] = 255
        if i == 26:
            row[3] = 0
        if i == 27:
            row[6] = cap + 1
        if i == 28:
            row[2] = 2
        out.append(row)
    return out


def packet(variant: str) -> list[int]:
    cap = 9 if variant == "custom" else 99
    out = initial(cap)
    for row in rows(variant == "custom"):
        out += call(row)
    d = initial(cap)
    d[6] = cap - 1
    d[0:3] = [0, 1 if variant == "wrong" else 2, 0]
    d = call(d)
    out += d
    for slot, amount, mode in [
        (0, 1, 0),
        (0, cap, 1),
        (3, 1, 1),
        (2, 5, 0),
        (2, 5, 1),
        (1, 0, 0),
    ]:
        d[0:3] = [slot, amount, mode]
        d = call(d)
        out += d
    return out
