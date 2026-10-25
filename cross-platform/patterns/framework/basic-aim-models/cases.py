"""Independent rational dominant-axis aim model."""

from __future__ import annotations

from fractions import Fraction

TOPICS = ["aimed-projectile"]
CATEGORIES = {"aimed-projectile": "physics"}
LABELS = {"aimed-projectile": "AIMD RESULTS"}
FIELDS = {"aimed-projectile": list("UVOXYABS")}
ARRAYS = {"aimed-projectile": {}}


def byte(v: int) -> bool:
    return 0 <= v <= 255 and int(v) == v


def aim(data: list[int]) -> list[int]:
    d = list(data)
    d[:3] = [0, 0, 0]
    if any(not byte(v) for v in d[3:]) or d[7] > 15:
        return d
    d[2] = 1
    dx, dy = d[5] - d[3], d[6] - d[4]
    scale = max(abs(dx), abs(dy))
    if scale:
        d[:2] = [
            (int(Fraction(abs(int(v)) * int(d[7]), int(scale))) * (1 if v >= 0 else -1))
            % 256
            for v in [dx, dy]
        ]
    return d


FUNCTIONS = {"aimed-projectile": aim}


def initial(topic: str) -> list[int]:
    return [0] * 8


def rows(topic: str, custom: bool) -> list[list[int]]:
    return [
        [199] * 3 + list(v)
        for v in [
            (100, 100, 110, 105, 4),
            (100, 100, 90, 95, 4),
            (100, 100, 100, 100, 15),
            (0, 0, 255, 255, 15),
            (255, 255, 0, 0, 15),
            (0, 255, 255, 0, 15),
            (255, 0, 0, 255, 15),
            (100, 100, 100, 99, 1),
            (100, 100, 99, 100, 1),
            (100, 100, 101, 100, 0),
            (100, 100, 101, 255, 1),
            (100, 100, 100, 255, 15),
            (100, 100, 255, 100, 15),
            (0, 0, 255, 128, 15),
            (100, 100, 110, 105, 16),
            (100, 100, 110, 105, 255),
        ]
    ]


def clients(topic: str, custom: bool, wrong: bool) -> tuple[list[list[int]], list[int]]:
    d = [0, 0, 0, 100, 100, 90 if custom else 110, 95 if custom else 105, 4]
    states = []
    checks = []
    for i, updates in enumerate(
        [{}, {5: 100, 6: 100}, {3: 255, 4: 0, 5: 0, 6: 255, 7: 15}, {7: 16}]
    ):
        for k, v in updates.items():
            d[k] = v
        if wrong:
            d[7] = 0
        d = aim(d)
        states.append(list(d))
        if i == 0:
            checks = [
                int(d[0] == (252 if custom else 4)),
                int(d[1] == (254 if custom else 2)),
            ]
    return states, checks


def packet(topic: str, variant: str) -> list[int]:
    states = (
        [initial(topic)]
        + [aim(d) for d in rows(topic, variant == "custom")]
        + clients(topic, variant == "custom", variant == "wrong")[0]
    )
    result = [v for d in states for v in d]
    assert len(result) < 995 and all(byte(v) for v in result)
    return [int(v) for v in result]
