"""Independent literal transition table and full signed-long native records."""

from __future__ import annotations

import struct

MARKER = bytes((26, 43, 60, 77))
DONE = struct.pack(">i", 239)
RECORD_BYTES = 48
NEXT = (
    (0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1),
    (1, 1, 3, 3, 2, 2, 2, 2, 1, 1, 3, 3, 2, 2, 2, 2),
    (2, 0, 2, 0, 2, 0, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1),
    (3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1),
)


def cases() -> tuple[tuple[int, int, int, int], ...]:
    rows = [(state, event, 0) for state in range(4) for event in range(16)]
    rows += [(state, 15, 0) for state in range(4, 256)]
    rows += [(state, 15, 0) for state in (-2147483647, -65535, -1, 2147483647)]
    rows += [(state, event, 0) for state in range(4) for event in
             (-2147483647, -65535, -1, 16, 31, 255, 256, 512, 65535, 2147483647)]
    rows += [(-2147483647, 15, 1)]
    rows += [(state, -2147483647, 2) for state in range(4)]
    return tuple((*row, 0) for row in rows) + ((3, 15, 0, 1),)


def record(state: int, events: int, minimum: int, initialise: int) -> bytes:
    if initialise:
        return struct.pack(">11i", state, events, 0, 0, 0, 0, 0, 0, 65537, 5, 3) + MARKER
    state -= int(minimum == 1)
    events -= int(minimum == 2)
    result, changed, fresh, error, following = state, 0, 0, 0, 91
    if state not in range(4):
        error = 1
    elif events not in range(16):
        error = 2
    else:
        result = following = NEXT[state][events]
        changed = int(result != state)
        fresh = int(result == 1 and state in (0, 2))
    return struct.pack(">11i", state, events, result, events, changed, fresh, error,
                       following, 65537, 5, 3) + MARKER


def chunks() -> tuple[tuple[tuple[int, int, int, int], ...], ...]:
    rows = cases()
    return tuple(rows[start:start + 64] for start in range(0, len(rows), 64))


def packet(chunk: int | None = None) -> bytes:
    rows = cases() if chunk is None else chunks()[chunk]
    return b"".join(record(*row) for row in rows) + MARKER + DONE
