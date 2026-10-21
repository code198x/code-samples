"""Independent destination-to-source sampling; the target uses error accumulators."""

from __future__ import annotations


def resize(rows: bytes, width: int, height: int, *, crop_fault: bool = False) -> bytes:
    if len(rows) != 8 or not (1 <= width <= 8 and 1 <= height <= 8):
        raise ValueError("Expected eight rows and width/height 1..8")
    out = bytearray(8)
    for y in range(height):
        source_y = y * 8 // height
        for x in range(width):
            source_x = x if crop_fault else x * 8 // width
            if rows[source_y] & (128 >> source_x):
                out[y] |= 128 >> x
    return bytes(out)


def cases() -> list[dict]:
    patterns = [
        bytes([128, 64, 32, 16, 8, 4, 2, 1]),
        bytes([231, 129, 160, 8, 4, 3, 64, 255]),
        bytes(8),
        bytes([255] * 8),
    ]
    result = []
    for width in range(1, 9):
        for height in range(1, 9):
            for i, rows in enumerate(patterns):
                result.append(
                    {
                        "id": f"w{width}-h{height}-p{i}",
                        "width": width,
                        "height": height,
                        "rows": rows.hex(),
                        "overlap": 0,
                    }
                )
    for bit in range(64):
        rows = bytes((128 >> (bit % 8)) if y == bit // 8 else 0 for y in range(8))
        for width, height in [(5, 7), (3, 5), (8, 4), (8, 8)]:
            result.append(
                {
                    "id": f"pixel{bit}-{width}x{height}",
                    "width": width,
                    "height": height,
                    "rows": rows.hex(),
                    "overlap": 0,
                }
            )
    for overlap in [-7, -1, 1, 7, 8]:
        for width, height in [(1, 1), (5, 7), (8, 8)]:
            result.append(
                {
                    "id": f"overlap{overlap}-{width}x{height}",
                    "width": width,
                    "height": height,
                    "rows": patterns[1].hex(),
                    "overlap": overlap,
                }
            )
    for width, height in [(0, 1), (1, 0), (9, 1), (1, 9), (255, 8), (8, 255)]:
        result.append(
            {
                "id": f"invalid-{width}x{height}",
                "width": width,
                "height": height,
                "rows": patterns[1].hex(),
                "overlap": 0,
            }
        )
    for side in ["source", "dest"]:
        for address in [65529, 65535]:
            result.append(
                {
                    "id": f"invalid-{side}-{address}",
                    "width": 5,
                    "height": 7,
                    "rows": patterns[1].hex(),
                    "overlap": 0,
                    "invalid_side": side,
                    "invalid_address": address,
                }
            )
    return result
