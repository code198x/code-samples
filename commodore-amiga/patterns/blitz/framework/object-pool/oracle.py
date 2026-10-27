"""Independent set policy and full signed-long snapshots for compiled pools."""

from __future__ import annotations

import struct

CAPACITIES = (1, 4, 8)
RECORD_BYTES = 496
MARKER = bytes((26, 43, 60, 77))
DONE = struct.pack(">i", 239)


def cases() -> tuple[tuple[int, int, int], ...]:
    return tuple(
        (capacity, mask, (-1, capacity, 8, 255, 65535, 2147483647)[mask % 6])
        for capacity in CAPACITIES
        for mask in range(256)
    )


def record(capacity: int, mask: int, bad: int, broken: bool = False) -> bytes:
    live: set[int] = set()

    def snapshot(slot: int, ok: int, error: int) -> bytes:
        context = (capacity, capacity, slot, ok, error, capacity)
        flags = tuple(int(i in live) if i < capacity else 77 for i in range(8)) + (99,)
        return struct.pack(">24i", *context, *flags, *([60] * 9))

    result = struct.pack(">3i", capacity, mask, bad) + snapshot(capacity, 1, 0)
    live = {i for i in range(capacity) if mask & (1 << i)}
    free = sorted(set(range(capacity)) - live)
    slot, acquired = (free[0], 1) if free else (capacity, 0)
    if acquired:
        live.add(slot)
    result += snapshot(slot, acquired, 0)
    if broken:
        result += snapshot(slot, acquired, 0)
    else:
        released = int(slot in live)
        live.discard(slot)
        result += snapshot(slot, released, 0 if released else 2)
    repeated = int(slot in live)
    live.discard(slot)
    result += snapshot(slot, repeated, 0 if repeated else 2)
    result += snapshot(bad, 0, 2)
    return result + MARKER


def packet(broken: bool = False) -> bytes:
    return b"".join(record(*row, broken) for row in cases()) + MARKER + DONE
