"""Logical 16x16 picture and screen-index oracle (MIT)."""

from __future__ import annotations

NORMAL = bytes([126, 64, 64, 124, 64, 64, 64, 0])
CUSTOM = bytes([16, 24, 252, 254, 252, 24, 16, 0])
VARIANTS = ("positive", "customise", "stride-fault", "stride-fixed")


def tiles(source: bytes) -> bytes:
    if len(source) != 8:
        raise ValueError("Expected eight rows")
    return bytes(
        sum(
            (128 >> x)
            for x in range(8)
            if source[(ty * 8 + y) // 2] & (128 >> ((tx * 8 + x) // 2))
        )
        for ty in range(2)
        for tx in range(2)
        for y in range(8)
    )


def apply(memory: bytearray, first: int, cell: int) -> bool:
    y, x = divmod(cell, 32)
    if not 0 <= first <= 252 or not 0 <= y < 23 or not 0 <= x < 31:
        return False
    for dy in range(2):
        for dx in range(2):
            memory[0x1800 + (y + dy) * 32 + x + dx] = first + dy * 2 + dx
    return True


def initial(variant: str) -> bytearray:
    custom = variant == "customise"
    first, cell, second = (16, 734, 330) if custom else (8, 330, 334)
    data = bytearray(16384)
    data[first * 8 : first * 8 + 32] = tiles(CUSTOM if custom else NORMAL)
    data[0x800:0x810] = bytes([165]) * 16
    data[0x1B00] = 208
    data[0x2000:0x2020] = bytes([241]) * 32
    apply(data, first, cell)
    apply(data, first, second)
    return data


def cases() -> list[tuple[int, int]]:
    # Every origin, including the entire rejected right/bottom edges.
    return [(8, cell) for cell in range(768)] + [
        (s, c)
        for s in (0, 4, 5, 7, 8, 249, 252, 253, 254, 255)
        for c in (0, 30, 31, 32, 734, 735, 736, 767, 768, 65535)
    ]
