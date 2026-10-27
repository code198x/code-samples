"""Independent full-long observations for invalid pool domains and signed MIN."""

from __future__ import annotations

import struct

MARKER = bytes((26, 43, 60, 77))
DONE = struct.pack(">i", 239)
RECORD_BYTES = 116
MINIMUM = -2147483648


def cases(extremes: bool = False) -> tuple[tuple[int, int, int, int, int], ...]:
    if extremes:
        return (
            (1, MINIMUM, 4, -1, 1),
            (2, 4, MINIMUM, -1, 2),
            (3, 4, MINIMUM, -1, 2),
        ) + tuple((3, cap, cap, MINIMUM, 3) for cap in (1, 4, 8))
    invalid = (-1, 0, 9, 255, 65535, 2147483647)
    rows = [(1, cap, 4, -1, 0) for cap in (1, 4, 8) + invalid]
    rows += [(op, 4, size, -1, 0) for op in (2, 3) for size in (-1, 0, 9, 2147483647)]
    rows += [
        (3, cap, cap, slot, 0)
        for cap in (1, 4, 8)
        for slot in (-1, cap, 8, 255, 65535, 2147483647)
    ]
    rows += [(op, cap, 4, -1, 0) for op in (4, 5) for cap in invalid]
    return tuple(dict.fromkeys(rows))


def record(op: int, cap: int, size: int, slot: int, minimum: int) -> bytes:
    flags = [77] * 8 + [99]
    extent, result_slot, ok, error, scratch = size, slot, 0, 1, 91
    if op in (1, 4, 5):
        extent = result_slot = 0
        if 1 <= cap <= 8:
            extent = result_slot = scratch = cap
            flags[:cap] = [0] * cap
            ok, error = 1, 0
        if op in (4, 5):
            if 1 <= cap <= 8:
                raise ValueError("Chained boundary must start from invalid init")
            ok, error = 0, 1
            result_slot = 0 if op == 4 else slot
    elif op == 2:
        if 1 <= size <= 8:
            raise ValueError("Boundary acquire needs invalid context")
        result_slot = size
    elif op == 3:
        if 1 <= size <= 8:
            if 0 <= slot < size:
                raise ValueError("Boundary release needs invalid index")
            error = 2
    else:
        raise ValueError(op)
    return (
        struct.pack(
            ">28i",
            op,
            cap,
            size,
            slot,
            cap,
            extent,
            result_slot,
            ok,
            error,
            scratch,
            *flags,
            *([65537] * 9),
        )
        + MARKER
    )


def packet(extremes: bool = False) -> bytes:
    return b"".join(record(*row) for row in cases(extremes)) + MARKER + DONE


def data(extremes: bool = False) -> str:
    rows = []
    for original in cases(extremes):
        row = list(original)
        if row[4]:
            row[row[4]] += 1
        rows.append("Data.l " + ",".join(map(str, row)))
    return "\n".join(rows) + "\n"
