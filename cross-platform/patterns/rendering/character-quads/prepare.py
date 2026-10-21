"""Prepare four row-major one-bit tiles from one 8x8 glyph (MIT)."""

from __future__ import annotations

import argparse
from pathlib import Path


def enlarge(source: bytes) -> bytes:
    if len(source) != 8:
        raise ValueError("Expected exactly eight source rows")
    tiles = bytearray(32)
    for row, bits in enumerate(source):
        left = right = 0
        for x in range(4):
            if bits & (128 >> x):
                left |= 192 >> (x * 2)
            if bits & (8 >> x):
                right |= 192 >> (x * 2)
        half, local = divmod(row, 4)
        for repeat in range(2):
            tiles[half * 16 + local * 2 + repeat] = left
            tiles[half * 16 + 8 + local * 2 + repeat] = right
    return bytes(tiles)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("source", type=Path)
    p.add_argument("destination", type=Path)
    args = p.parse_args()
    data = enlarge(args.source.read_bytes())
    args.destination.write_bytes(data)
