#!/usr/bin/env python3
"""
make_test_sprite.py — Generate a 16×16 test sprite PNG for pipeline validation.

The test pattern is designed to make off-by-one errors obvious:
- Solid border on three sides (top, left, bottom — NOT right)
- A diagonal stripe from top-left to bottom-right
- A small "L" shape in the bottom-right corner
- Transparent everywhere else

This makes shift-by-one errors visible: if the diagonal is off, the shift
maths is wrong; if the bottom-right "L" is corrupted, the right-edge byte
handling is wrong; if the asymmetric border (3 sides, not 4) flips, we have
a horizontal/vertical mix-up.
"""

import sys
from pathlib import Path


def make_test_sprite(width=16, height=16):
    try:
        from PIL import Image
    except ImportError:
        sys.exit("error: Pillow required. Install with: pip install Pillow")

    INK = (0, 0, 0, 255)       # black, opaque = sprite pixel set
    CLEAR = (255, 255, 255, 0) # transparent

    img = Image.new("RGBA", (width, height), CLEAR)
    pixels = img.load()

    # Three-sided border: top, left, bottom (NOT right)
    for x in range(width):
        pixels[x, 0] = INK              # top edge
        pixels[x, height - 1] = INK     # bottom edge
    for y in range(height):
        pixels[0, y] = INK              # left edge

    # Diagonal from top-left to bottom-right
    for d in range(min(width, height)):
        pixels[d, d] = INK

    # Small "L" shape in bottom-right (lower-right 4x4 quadrant)
    # L = vertical bar of 3 + horizontal foot of 2
    for y in range(height - 5, height - 2):
        pixels[width - 4, y] = INK      # vertical of L
    pixels[width - 4, height - 2] = INK  # bottom-left of L
    pixels[width - 3, height - 2] = INK  # foot extending right

    out_path = Path(__file__).parent.parent / "assets/test/sprites/test-pattern.png"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"wrote {out_path}")


if __name__ == "__main__":
    make_test_sprite()
