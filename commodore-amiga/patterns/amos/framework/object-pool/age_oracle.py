"""Independent owner lifetime-pass snapshots, with spawning after the pass."""
from __future__ import annotations

import struct

MARKER = bytes((26, 43, 60, 77))
RECORD_BYTES = 128


def cases():
    return (0, 1, 2)


def packet():
    # The owner starts four objects with lifetimes1,2,1,3. Only after pass0
    # completes does it reuse slot0 with lifetime2. No spawn occurs in traversal.
    lifetimes = {0: 1, 1: 2, 2: 1, 3: 3}
    records = []
    for frame in cases():
        expired = {slot for slot, life in lifetimes.items() if life == 1}
        lifetimes = {slot: life - 1 for slot, life in lifetimes.items() if life > 1}
        reuse = 4
        if frame == 0:
            reuse = min(set(range(4)) - lifetimes.keys())
            lifetimes[reuse] = 2
        live = [int(slot in lifetimes) for slot in range(4)] + [77] * 4 + [99]
        life = [lifetimes.get(slot, 0) for slot in range(4)] + [77] * 4 + [99]
        records.append(struct.pack(">4i", frame, len(lifetimes), len(expired), reuse)
                       + struct.pack(">9i", *live) + struct.pack(">9i", *life)
                       + struct.pack(">9i", *([65537] * 9)) + MARKER)
    return b"".join(records) + MARKER
