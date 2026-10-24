"""Independent policy selection and retained session outcomes for BASIC flow."""

from __future__ import annotations

FIELDS = ["S", "V", "C", "F", "E", "X", "P", "L", "N"]
LABEL = "FLOW RESULTS"
HELD = [0, 3, 3, 0, 0, 3, 3, 0, 3, 0, 4, 0, 8, 8, 0]
POLICY = {
    0: [(1, 1, 1)],
    1: [(4, 2, 0), (2, 3, 0)],
    2: [(8, 1, 1), (1, 0, 0)],
    3: [(2, 1, 0)],
}


def transition(state: int, events: int) -> tuple[int, int, int, int]:
    if state not in POLICY:
        return state, 0, 0, 1
    if not 0 <= events <= 15 or int(events) != events:
        return state, 0, 0, 2
    target, fresh = next(
        ((t, f) for mask, t, f in POLICY[state] if events & mask), (state, 0)
    )
    return target, int(target != state), fresh, 0


def rows() -> list[tuple[int, int]]:
    return [(s, v) for s in range(4) for v in range(16)] + [
        (4, 0),
        (255, 0),
        (0, 16),
        (1, 128),
        (2, 255),
        (3, 16),
    ]


def packet(variant: str) -> list[int]:
    health = 5 if variant == "custom" else 3
    result = [0, 0, 0, 0, 0, 0, 0, health, 0]
    for state, events in rows():
        s, c, f, e = transition(state, events)
        result += [s, events, c, f, e, 0, 0, health, 0]
    s = previous = score = resets = 0
    for held in HELD:
        events = held & (~previous & 15)
        previous = held
        if s == 1:
            score += 1
        s, c, f, e = transition(s, events)
        if f or (variant == "wrong" and c and s == 1):
            score = 0
            resets += 1
        result += [s, events, c, f, e, score, previous, health, resets]
    return result
