"""Independent stable maximum selection for BASIC request arbitration."""

from __future__ import annotations

FIELDS = ["F", "I", "P", "R", "A", "O", "E"]
LABEL = "PICK RESULTS"


def initial() -> list[int]:
    return [0] * 7


def call(row: list[int]) -> list[int]:
    f, i, p, r, a, _, _ = row
    if f not in [0, 1] or any(int(x) != x or not 0 <= x <= 255 for x in [i, p]):
        return [f, i, p, r, a, 0, 1]
    if any(int(x) != x or not 0 <= x <= 255 for x in [r, a]):
        return [f, i, p, r, a, 0, 2]
    candidates = ([(i, p)] if f else []) + [(r, a)]
    winner = max(candidates, key=lambda x: x[1])
    accepted = int(not f or a > p)
    return [1, winner[0], winner[1], r, a, accepted, 0]


def requests(custom: bool) -> list[tuple[int, int]]:
    return (
        [(10, 5), (20, 180), (30, 40), (40, 180), (50, 1)]
        if custom
        else [(10, 30), (20, 200), (30, 50), (40, 200), (50, 10)]
    )


def rows(custom: bool) -> list[list[int]]:
    edges = [0, 1, 127, 128, 254, 255]
    return [[i % 2, 17, p, 23, a, 9, 9] for i, p in enumerate(edges) for a in edges] + [
        [2, 0, 0, 1, a, 9, 9] for a in edges
    ]


def packet(variant: str) -> list[int]:
    out = initial()
    for row in rows(variant == "custom"):
        out += call(row)
    d = initial()
    for request, priority in requests(variant == "custom"):
        if variant == "wrong":
            d = initial()
        d[3:5] = [request, priority]
        d = call(d)
        out += d
    return out
