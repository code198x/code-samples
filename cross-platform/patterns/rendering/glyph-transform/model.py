"""Independent pixel-coordinate oracle; no assembler or emulator required."""

from __future__ import annotations


def transform(rows: bytes, flags: int, *, transpose_fault: bool = False) -> bytes:
    if len(rows) != 8 or not 0 <= flags <= 7:
        raise ValueError("Expected eight rows and flags 0..7")
    # Work on a matrix, unlike the target's bit-shift/OR implementation.
    matrix = [[bool(row & (128 >> x)) for x in range(8)] for row in rows]
    for _ in range(flags & 3):
        matrix = (
            [list(column) for column in zip(*matrix, strict=True)]
            if transpose_fault
            else [list(column) for column in zip(*matrix[::-1], strict=True)]
        )
    if flags & 4:
        matrix = [row[::-1] for row in matrix]
    return bytes(sum(128 >> x for x, ink in enumerate(row) if ink) for row in matrix)


def cases() -> list[dict]:
    patterns = [
        bytes([128, 64, 32, 16, 8, 4, 2, 1]),
        bytes([231, 129, 160, 8, 4, 3, 64, 255]),
        bytes(8),
        bytes([255] * 8),
    ]
    result = []
    for flags in range(8):
        for i, rows in enumerate(patterns):
            result.append(
                {
                    "id": f"t{flags}-p{i}",
                    "flags": flags,
                    "rows": rows.hex(),
                    "overlap": 0,
                }
            )
    # Every single source pixel, every transform: catches mirrored/symmetric test assets.
    for bit in range(64):
        rows = bytes((128 >> (bit % 8)) if y == bit // 8 else 0 for y in range(8))
        for flags in range(8):
            result.append(
                {
                    "id": f"pixel{bit}-t{flags}",
                    "flags": flags,
                    "rows": rows.hex(),
                    "overlap": 0,
                }
            )
    for overlap in [-7, -1, 1, 7, 8]:
        for flags in range(8):
            result.append(
                {
                    "id": f"overlap{overlap}-t{flags}",
                    "flags": flags,
                    "rows": patterns[1].hex(),
                    "overlap": overlap,
                }
            )
    for flags in [8, 255]:
        result.append(
            {
                "id": f"invalid{flags}",
                "flags": flags,
                "rows": patterns[1].hex(),
                "overlap": 0,
            }
        )
    for side in ["source", "dest"]:
        for address in [65529, 65535]:
            result.append(
                {
                    "id": f"invalid-{side}-{address}",
                    "flags": 1,
                    "rows": patterns[1].hex(),
                    "overlap": 0,
                    "invalid_side": side,
                    "invalid_address": address,
                }
            )
    return result
