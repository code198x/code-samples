#!/usr/bin/env python3
"""Compose Meteor Storm's tape loading screen from the game's own artwork.

A SCREEN$ is 256x192 pixels under the attribute grid: 32x24 cells of 8x8,
each with one INK and one PAPER. Like the game, the picture is coloured by
place: every cell has black PAPER and the BRIGHT INK of its row, so whatever
is drawn anywhere in a row takes that row's colour and no cell can clash.

    python3 compose.py                        # -> loading-screen.png
    build198x image loading-screen.png --machine sinclair-zx-spectrum \\
        --format scr --dither none -o meteor-storm.scr

The ship, meteor and star bitmaps are the 24-pixel rows in ../../assets.py;
the wordmark letters are drawn here. Palette: mediaspec emu198x-v1 (normal
0xC2, bright 0xFF), as Gloaming's loading screen uses.
"""
import importlib.util
from pathlib import Path
from PIL import Image

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('art', HERE.parents[1] / 'assets.py')
art = importlib.util.module_from_spec(spec)
spec.loader.exec_module(art)

BRIGHT = {0: (0, 0, 0), 1: (0, 0, 255), 2: (255, 0, 0), 3: (255, 0, 255),
          4: (0, 255, 0), 5: (0, 255, 255), 6: (255, 255, 0), 7: (255, 255, 255)}
BLACK, RED, MAGENTA, GREEN, CYAN, YELLOW, WHITE = 0, 2, 3, 4, 5, 6, 7

# One INK per character row, top to bottom: the wordmark, then the game's
# own bands (cyan, green, yellow, red), the white ship, and three empty rows.
ROW_INK = [BLACK,
           WHITE, CYAN, CYAN,           # METEOR
           YELLOW, RED, RED,            # STORM
           CYAN, CYAN, CYAN,
           GREEN, GREEN, GREEN,
           YELLOW, YELLOW, YELLOW,
           RED, RED, RED,
           WHITE, WHITE,                # the ship
           BLACK, BLACK, BLACK]

LETTERS = {
    'M': ["##....##", "###..###", "########", "##.##.##", "##....##", "##....##", "##....##", "........"],
    'E': ["########", "##......", "##......", "######..", "##......", "##......", "########", "........"],
    'T': ["########", "...##...", "...##...", "...##...", "...##...", "...##...", "...##...", "........"],
    'O': [".######.", "##....##", "##....##", "##....##", "##....##", "##....##", ".######.", "........"],
    'R': ["#######.", "##....##", "##....##", "#######.", "##..##..", "##...##.", "##....##", "........"],
    'S': [".######.", "##......", "##......", ".######.", "......##", "......##", ".######.", "........"],
}

pixels = [[0] * 256 for _ in range(192)]


def plot(x, y):
    if 0 <= x < 256 and 0 <= y < 192:
        pixels[y][x] = 1


def word(text, y, scale=3, pitch=26):
    x0 = (256 - (len(text) * pitch - (pitch - 8 * scale))) // 2
    for i, letter in enumerate(text):
        for row, line in enumerate(LETTERS[letter]):
            for col, bit in enumerate(line):
                if bit == '#':
                    for dy in range(scale):
                        for dx in range(scale):
                            plot(x0 + i * pitch + col * scale + dx, y + row * scale + dy)


def sprite(rows, x, y):
    # A 24-pixel-wide bitmap from assets.py, bit 23 at the left.
    for r, bits in enumerate(rows):
        for c in range(24):
            if bits & (1 << (23 - c)):
                plot(x + c, y + r)


def streak(x, y, length):
    # A dotted trail above a falling object, every other pixel.
    for d in range(2, length, 2):
        plot(x, y - d)


word('METEOR', 8)
word('STORM', 32)
# (x, y, kind): meteors and stars in the band rows, 56-151; streak lengths vary.
for x, y, kind, trail in [(18, 58, 'meteor', 0), (92, 70, 'star', 10), (166, 62, 'meteor', 0),
                          (218, 84, 'meteor', 22), (44, 96, 'meteor', 30), (130, 104, 'meteor', 34),
                          (192, 118, 'star', 24), (12, 132, 'star', 18), (78, 136, 'meteor', 40),
                          (226, 138, 'meteor', 30)]:
    sprite(art.METEOR if kind == 'meteor' else art.STAR, x, y)
    if trail:
        streak(x + 12, y, trail)
sprite(art.SHIP, 116, 152)

image = Image.new('RGB', (256, 192))
for y in range(192):
    ink = BRIGHT[ROW_INK[y // 8]]
    for x in range(256):
        image.putpixel((x, y), ink if pixels[y][x] else (0, 0, 0))
image.save(HERE / 'loading-screen.png')
print('wrote', HERE / 'loading-screen.png')
