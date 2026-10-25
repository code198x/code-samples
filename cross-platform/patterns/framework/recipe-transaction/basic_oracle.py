"""Independent atomic resource transaction for BASIC crafting."""

from __future__ import annotations

FIELDS = ["H", "I", "R", "A", "B", "P", "C", "O", "E"]
LABEL = "MAKE RESULTS"


def initial(cap: int) -> list[int]:
    return [0, 0, 0, 0, 0, 0, cap, 0, 0]


def call(row: list[int]) -> list[int]:
    h, i, r, a, b, p, c, _, _ = row
    if (
        not 1 <= c <= 255
        or int(c) != c
        or any(int(x) != x or not 0 <= x <= 255 for x in [h, i])
        or not 0 <= r <= c
        or int(r) != r
    ):
        return [h, i, r, a, b, p, c, 0, 1]
    if (
        any(int(x) != x or not 0 <= x <= 255 for x in [a, b])
        or a + b == 0
        or not 1 <= p <= 255
        or int(p) != p
    ):
        return [h, i, r, a, b, p, c, 0, 2]
    holdings = [h, i, c - r]
    needs = [a, b, p]
    ok = all(stock >= cost for stock, cost in zip(holdings, needs))
    return [
        h - a if ok else h,
        i - b if ok else i,
        r + p if ok else r,
        a,
        b,
        p,
        c,
        int(ok),
        0,
    ]


def rows(custom: bool) -> list[list[int]]:
    cap = 7 if custom else 31
    out = []
    for j in range(36):
        d = [
            [0, 1, 2, 5, 127, 255][j % 6],
            [0, 1, 4, 5, 127, 255][j // 6],
            j % (cap + 1),
            2,
            1,
            2,
            cap,
            9,
            9,
        ]
        if j == 24:
            d[6] = 0
        if j == 25:
            d[2] = cap + 1
        if j == 26:
            d[3:5] = [0, 0]
        if j == 27:
            d[5] = 0
        if j == 28:
            d[3:5] = [0, 1]
        if j == 29:
            d[3:5] = [1, 0]
        out.append(d)
    return out


def packet(variant: str) -> list[int]:
    cap = 7 if variant == "custom" else 31
    out = initial(cap)
    for row in rows(variant == "custom"):
        out += call(row)
    d = [5, 4, cap - 1, 2, 1, 2, cap, 0, 0]
    if variant == "wrong":
        d[0] -= d[3]
        d[1] -= d[4]
    d = call(d)
    out += d
    d[2] = 0
    for _ in range(4):
        d = call(d)
        out += d
    return out
