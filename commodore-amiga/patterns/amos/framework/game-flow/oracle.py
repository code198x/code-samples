"""Independent transition table for native AMOS integer observations."""
from __future__ import annotations

import struct

MARKER = bytes((26, 43, 60, 77))
RECORD_BYTES = 48
# Rows are old states TITLE, PLAY, OVER, PAUSED; columns are event masks0..15.
NEXT = (
    (0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1),
    (1, 1, 3, 3, 2, 2, 2, 2, 1, 1, 3, 3, 2, 2, 2, 2),
    (2, 0, 2, 0, 2, 0, 2, 0, 1, 1, 1, 1, 1, 1, 1, 1),
    (3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1, 3, 3, 1, 1),
)


def cases() -> tuple[tuple[int, int], ...]:
    valid = tuple((state, event) for state in range(4) for event in range(16))
    invalid_states = tuple((state, 15) for state in range(4, 256))
    wide_states = tuple((state, 15) for state in (-2147483647, -65535, -1, 2147483647))
    invalid_events = tuple((state, event) for state in range(4) for event in
                           (-2147483647, -65535, -1, 16, 31, 255, 256, 512, 65535, 2147483647))
    return valid + invalid_states + wide_states + invalid_events


def record(state: int, events: int) -> bytes:
    changed, fresh, error, following = 0, 0, 0, 91
    result = state
    if state not in range(4):
        error = 1
    elif events not in range(16):
        error = 2
    else:
        result = following = NEXT[state][events]
        changed = int(result != state)
        fresh = int(result == 1 and state in (0, 2))
    # The helper must preserve events and caller-owned score, health and history.
    return struct.pack(">11i", state, events, result, events, changed, fresh, error,
                       following, 65537, 5, 3) + MARKER


def packet() -> bytes:
    return b"".join(record(*row) for row in cases()) + MARKER
