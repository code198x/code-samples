"""Saturating integer health and an update-count recovery policy."""

EDGES = [0, 1, 2, 3, 127, 255]


def step(health, remaining, amount, period):
    remaining = max(0, remaining - 1)
    if health == 0 or remaining != 0 or amount == 0:
        return [health, remaining, 0, 0]
    result = max(0, health - amount)
    return [result, period if result else 0, 1, int(result == 0)]


def inputs(period):
    return (
        [(h, 0, 1) for h in range(256)]
        + [(h, 0, a) for h in EDGES for a in EDGES]
        + [(3, t, 1) for t in [0, 1, 2, period, 254, 255]]
    )


def session(period, broken):
    health, remaining = 3, 0
    trace, accepted, first, deaths, blocked, snapshot = [], 0, 255, 0, 0, 0
    for index in range(12):
        if broken:
            remaining = period
        health, remaining, applied, killed = step(health, remaining, 1, period)
        accepted += applied
        deaths += killed
        if killed and first == 255:
            first = index
        blocked += int(health > 0 and applied == 0)
        if index == 4:
            snapshot = health
        trace += [health, remaining, applied, killed]
    return trace, [
        accepted,
        first,
        health,
        remaining,
        deaths,
        blocked,
        snapshot,
        period,
    ]


def packet(period, broken=False):
    return (
        [165, period, 3, 0, 0, 0, 0]
        + [v for h, t, a in inputs(period) for v in step(h, t, a, period)]
        + session(period, broken)[0]
        + [239]
    )


def preview(period, broken=False):
    return session(period, broken)[1]
