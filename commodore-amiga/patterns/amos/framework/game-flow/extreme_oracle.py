"""Independent signed-minimum rejection records."""
import struct

MARKER = bytes((26, 43, 60, 77))
RECORD_BYTES = 48
MINIMUM = -2147483648


def cases():
    return ((MINIMUM, 15, 0),) + tuple((state, MINIMUM, 1) for state in range(4))


def packet():
    records = []
    for state, events, kind in cases():
        error = 1 if kind == 0 else 2
        records.append(struct.pack(">11i", state, events, state, events, 0, 0,
                                   error, 91, 65537, 5, 3) + MARKER)
    return b"".join(records) + MARKER
