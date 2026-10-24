"""Independent saturating-health and recovery-count policy for BASIC."""

from __future__ import annotations

FIELDS = ["H", "T", "A", "P", "O", "K", "E"]
LABEL = "HITS RESULTS"


def initial(period: int) -> list[int]:
    return [3, 0, 0, period, 0, 0, 0]


def call(row: list[int]) -> list[int]:
    h, t, a, p, _, _, _ = row
    if (
        any(int(x) != x or not 0 <= x <= 255 for x in [h, t])
        or not 1 <= p <= 255
        or int(p) != p
    ):
        return [h, t, a, p, 0, 0, 1]
    if not 0 <= a <= 255 or int(a) != a:
        return [h, t, a, p, 0, 0, 2]
    remaining = max(0, t - 1)
    result = max(0, h - a) if h > 0 and remaining == 0 and a > 0 else h
    applied = int(h > 0 and remaining == 0 and a > 0)
    dead = int(applied and result == 0)
    return [
        result,
        (p if applied and result else 0 if dead else remaining),
        a,
        p,
        applied,
        dead,
        0,
    ]


def rows(custom: bool) -> list[list[int]]:
    p = 2 if custom else 4
    edges = [0, 1, 2, 3, 127, 255]
    return (
        [[h, 0, a, p, 9, 9, 9] for h in edges for a in edges]
        + [[3, t, 1, p, 9, 9, 9] for t in [0, 1, 2, p, 254, 255]]
        + [[h, 2, 1, 0, 9, 9, 9] for h in edges]
    )


def packet(variant: str) -> list[int]:
    p = 2 if variant == "custom" else 4
    out = initial(p)
    for row in rows(variant == "custom"):
        out += call(row)
    d = initial(p)
    for _ in range(12):
        d[2] = 1
        if variant == "wrong":
            d[1] = p
        d = call(d)
        out += d
    return out
