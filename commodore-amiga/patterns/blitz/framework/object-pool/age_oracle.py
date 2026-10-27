"""Independent owner lifetimes, post-traversal reuse and complete long snapshots."""

from __future__ import annotations

import struct

MARKER = bytes((26, 43, 60, 77))
DONE = struct.pack(">i", 239)
RECORD_BYTES = 152


def cases() -> tuple[int, ...]:
    return (0, 1, 2)


def packet() -> bytes:
    lifetimes = {0: 1, 1: 2, 2: 1, 3: 3}
    records = []
    for frame in cases():
        expired = {slot for slot, life in lifetimes.items() if life == 1}
        lifetimes = {slot: life - 1 for slot, life in lifetimes.items() if life > 1}
        last_slot, reuse = max(expired), 4
        if frame == 0:
            reuse = min(set(range(4)) - lifetimes.keys())
            lifetimes[reuse] = 2
            last_slot = reuse
        live = [int(slot in lifetimes) for slot in range(4)] + [77] * 4 + [99]
        life = [lifetimes.get(slot, 0) for slot in range(4)] + [77] * 4 + [99]
        records.append(
            struct.pack(
                ">37i",
                frame,
                len(lifetimes),
                len(expired),
                reuse,
                4,
                4,
                last_slot,
                1,
                0,
                4,
                *live,
                *life,
                *([65537] * 9),
            )
            + MARKER
        )
    return b"".join(records) + MARKER + DONE
