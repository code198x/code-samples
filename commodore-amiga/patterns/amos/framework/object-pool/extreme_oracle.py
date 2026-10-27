"""Independent full signed-minimum pool rejection records."""
import struct

MARKER = bytes((26, 43, 60, 77))
RECORD_BYTES = 108
MINIMUM = -2147483648


def cases():
    return ((1, MINIMUM, 4, -1, 0), (2, 4, MINIMUM, -1, 1),
            (3, 4, MINIMUM, -1, 1)) + tuple((3, cap, cap, MINIMUM, 2) for cap in (1, 4, 8))


def packet():
    outcomes = ((0, 0, 0, 1), (MINIMUM, MINIMUM, 0, 1),
                (MINIMUM, -1, 0, 1), (1, MINIMUM, 0, 2),
                (4, MINIMUM, 0, 2), (8, MINIMUM, 0, 2))
    flags = struct.pack(">9i", *([77] * 8 + [99]))
    payload = struct.pack(">9i", *([65537] * 9))
    return b"".join(struct.pack(">8i", *row[:4], *outcome) + flags + payload + MARKER
                    for row, outcome in zip(cases(), outcomes, strict=True)) + MARKER
