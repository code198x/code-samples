"""Independent invalid-capacity/context/index observations for native AMOS."""
from __future__ import annotations

import struct

MARKER = bytes((26, 43, 60, 77))
RECORD_BYTES = 108


def cases():
    invalid = (-1, 0, 9, 255, 65535, 2147483647)
    rows = [(1, capacity, 4, -1) for capacity in (1, 4, 8) + invalid]
    rows += [(op, 4, size, -1) for op in (2, 3) for size in (-1, 0, 9, 2147483647)]
    rows += [(3, capacity, capacity, slot) for capacity in (1, 4, 8)
             for slot in (-1, capacity, 8, 255, 65535, 2147483647)]
    rows += [(op, capacity, 4, -1) for op in (4, 5) for capacity in invalid]
    return tuple(dict.fromkeys(rows))


def record(op, capacity, size, slot):
    flags = [77] * 8 + [99]
    result_size, result_slot, ok, error = size, slot, 0, 1
    if op in (1, 4, 5):
        result_size = result_slot = 0
        if 1 <= capacity <= 8:
            result_size = result_slot = capacity
            flags[:capacity] = [0] * capacity
            ok, error = 1, 0
        if op in (4, 5):
            # Every chained case deliberately starts from an invalid init.
            assert not 1 <= capacity <= 8
            ok, error = 0, 1
            result_slot = 0 if op == 4 else slot
    elif op == 2:
        assert not 1 <= size <= 8
        result_slot = size
    elif op == 3:
        if 1 <= size <= 8:
            assert not 0 <= slot < size
            error = 2
    else:
        raise ValueError(op)
    return (struct.pack(">8i", op, capacity, size, slot, result_size, result_slot, ok, error)
            + struct.pack(">9i", *flags) + struct.pack(">9i", *([65537] * 9)) + MARKER)


def packet():
    return b"".join(record(*row) for row in cases()) + MARKER
