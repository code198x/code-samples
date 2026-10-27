"""Independent finite transition table and complete sixteen-bit Ace observations."""

from __future__ import annotations

NEXT = (
    (0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1),
    (1, 1, 3, 3, 2, 2, 2, 2, 1, 1, 3, 3, 2, 2, 2, 2),
    (2, 0, 2, 0, 2, 0, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1),
    (3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1),
)


def cases() -> tuple[tuple[int, int, int], ...]:
    rows = [(s, e, 0) for s in range(4) for e in range(16)]
    rows += [(s, 15, 0) for s in range(4, 256)]
    rows += [(s, 15, 0) for s in (-32768, -1, 256, 512, 32767, 32768, 65535)]
    rows += [
        (s, e, 0)
        for s in range(4)
        for e in (-32768, -1, 16, 31, 255, 256, 512, 32767, 32768, 65535)
    ]
    rows += [(4, 256, 0), (65535, 65535, 0), (3, 15, 1)]
    return tuple(rows)


def expected(state: int, events: int, initialise: int) -> list[int]:
    state %= 65536
    events %= 65536
    if initialise:
        return [0, 0, 0, 0, 0, 0, 65535, 32768, 3]
    result, changed, fresh, error, following = state, 0, 0, 0, 91
    if state > 3:
        error = 1
    elif events > 15:
        error = 2
    else:
        following = result = NEXT[state][events]
        changed = int(result != state)
        fresh = int(result == 1 and state in (0, 2))
    return [result, events, changed, fresh, error, following, 65535, 32768, 3]


def owner_rows(name: str) -> list[dict[str, int]]:
    state = previous = score = resets = 0
    health = 5 if name == "custom" else 3
    rows = []
    for held in (0, 3, 3, 0, 0, 3, 3, 0, 3, 0, 4, 0, 8, 8, 0):
        events = held & ~previous
        previous = held
        if state == 1:
            score = (score + 1) % 256
        following = NEXT[state][events]
        fresh = int(following == 1 and state in (0, 2))
        changed = int(following != state)
        state = following
        if fresh or (name == "wrong" and changed and state == 1):
            score = 0
            resets += 1
        rows.append(
            {
                "GS": state,
                "GE": events,
                "GC": changed,
                "GF": fresh,
                "GX": 0,
                "GN": following,
                "GP": previous,
                "GV": score,
                "GH": health,
                "GL": health,
                "GR": resets,
            }
        )
    return rows
