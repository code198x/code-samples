#!/usr/bin/env python3
"""Compose Gloaming's tape loading screen from the game's own art.

A Spectrum SCREEN$ is 256x192 under the attribute constraint: 32x24
cells of 8x8, two colours per cell (one INK, one PAPER, one BRIGHT).
Generated or photographic art fights that grid and loses. So this
composes the screen cell-by-cell from Gloaming's *own* glyphs and
palette — the lamplighter, lantern and wisp sprites, the cobble and
brick and mist textures, the exact dusk attributes — plus a bold 8x8
wordmark font. Every cell is >=2-colour-clean by construction, so the
conversion is byte-perfect (build198x reports mean_error 0.0, zero
cells over threshold, "input appears already constrained").

Pipeline:
    python3 compose.py                       # -> loading-screen.png
    build198x image loading-screen.png \\
        --machine sinclair-zx-spectrum --format scr \\
        --dither none -o gloaming.scr        # -> the SCREEN$ block

`gloaming.scr` is the loading screen the tape master embeds ahead of
the CODE block. Palette source: mediaspec `emu198x-v1` (normal 0xC2,
bright 0xFF), itself a transcription of Emu198x's Spectrum palette.
"""
from pathlib import Path
from PIL import Image

HERE = Path(__file__).resolve().parent

N, B = 0xC2, 0xFF
PAL = {
    (0, 0): (0, 0, 0), (0, 1): (0, 0, 0),
    (1, 0): (0, 0, N), (1, 1): (0, 0, B),
    (2, 0): (N, 0, 0), (2, 1): (B, 0, 0),
    (3, 0): (N, 0, N), (3, 1): (B, 0, B),
    (4, 0): (0, N, 0), (4, 1): (0, B, 0),
    (5, 0): (0, N, N), (5, 1): (0, B, B),
    (6, 0): (N, N, 0), (6, 1): (B, B, 0),
    (7, 0): (N, N, N), (7, 1): (B, B, B),
}


def bits(rows):
    return [format(r, "08b") for r in rows]


# glyphs, verbatim from the game (gloaming.asm)
LAMPLIGHTER = bits([0x3C, 0x3C, 0x18, 0x7E, 0x18, 0x18, 0x24, 0x42])
LANTERN     = bits([0x18, 0x24, 0x7E, 0x7E, 0x5A, 0x7E, 0x7E, 0x3C])
WISP        = bits([0x00, 0x3C, 0x7E, 0xFF, 0xFF, 0x7E, 0x3C, 0x00])
COBBLE      = bits([0x82, 0x00, 0x08, 0x00, 0x21, 0x00, 0x10, 0x00])
BRICK       = bits([0x08, 0x08, 0x08, 0xFF, 0x80, 0x80, 0x80, 0xFF])
MIST        = bits([0x6C, 0xDB, 0x36, 0x6D, 0xDA, 0xB6, 0x6B, 0xD6])
BLANK       = ["00000000"] * 8


def _g(s):
    return [row.replace(".", "0").replace("#", "1") for row in s]


FONT = {
 'G': _g([".#####..",".#...#..","#.......","#..###..","#....#..",".#...#..","..###.#.","........"]),
 'L': _g(["#.......","#.......","#.......","#.......","#.......","#.......","######..","........"]),
 'O': _g([".####...","#....#..","#....#..","#....#..","#....#..","#....#..",".####...","........"]),
 'A': _g([".####...","#....#..","#....#..","######..","#....#..","#....#..","#....#..","........"]),
 'M': _g(["#....#..","##..##..","#.##.#..","#....#..","#....#..","#....#..","#....#..","........"]),
 'I': _g(["#####...","..#.....","..#.....","..#.....","..#.....","..#.....","#####...","........"]),
 'N': _g(["#....#..","##...#..","#.#..#..","#..#.#..","#...##..","#....#..","#....#..","........"]),
 'T': _g(["#####...","..#.....","..#.....","..#.....","..#.....","..#.....","..#.....","........"]),
 'H': _g(["#....#..","#....#..","#....#..","######..","#....#..","#....#..","#....#..","........"]),
 'E': _g(["######..","#.......","#.......","#####...","#.......","#.......","######..","........"]),
 ' ': _g(["........"] * 8),
}

COLS, ROWS = 32, 24
grid = [[(BLANK, 0, 0, 0) for _ in range(COLS)] for _ in range(ROWS)]


def put(col, row, bmp, ink, paper, bright):
    if 0 <= row < ROWS and 0 <= col < COLS:
        grid[row][col] = (bmp, ink, paper, bright)


def text(col, row, s, ink, bright=1):
    for i, ch in enumerate(s):
        put(col + i, row, FONT[ch], ink, 0, bright)


# attributes (ink, paper, bright), matching the game's equates
COBBLE_A = (1, 0, 0); WALL_A = (7, 1, 0); GLOW_A = (6, 0, 0)
LIT_A = (6, 0, 1); UNLIT_A = (5, 0, 0); HERO_A = (7, 0, 1)
WISP_A = (5, 0, 1); MIST_A = (1, 0, 1)

# the walled square: brick frame + cobble interior
for r in range(3, 22):
    for c in range(1, 31):
        edge = r in (3, 21) or c in (1, 30)
        put(c, r, BRICK if edge else COBBLE, *(WALL_A if edge else COBBLE_A))

# two interior buildings (like the game's bldg_data), bricked
for (bc, br, bw, bh) in [(6, 6, 4, 3), (22, 6, 4, 3)]:
    for r in range(br, br + bh):
        for c in range(bc, bc + bw):
            put(c, r, BRICK, *WALL_A)

# lanterns — three lit (glow rings), three cold
RING = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
for (c, r) in [(9, 10), (16, 17), (24, 12)]:
    for dc, dr in RING:
        cc, rr = c + dc, r + dr
        if 0 <= rr < ROWS and 0 <= cc < COLS:
            _, ink, pap, br = grid[rr][cc]
            if (ink, pap, br) == COBBLE_A:
                put(cc, rr, COBBLE, *GLOW_A)
    put(c, r, LANTERN, *LIT_A)
for (c, r) in [(5, 16), (20, 9), (27, 18)]:
    put(c, r, LANTERN, *UNLIT_A)

# the lamplighter mid-square, the wisp gathered in a corner with a trail
put(15, 13, LAMPLIGHTER, *HERO_A)
put(27, 5, WISP, *WISP_A)
for (c, r) in [(28, 5), (28, 6)]:
    put(c, r, MIST, *MIST_A)

# the wordmark above, the subtitle below
text(12, 1, "GLOAMING", 6, bright=1)
text(9, 22, "THE LONG NIGHT", 7, bright=0)


def main():
    img = Image.new("RGB", (256, 192), (0, 0, 0))
    px = img.load()
    for r in range(ROWS):
        for c in range(COLS):
            bmp, ink, paper, bright = grid[r][c]
            ink_rgb, pap_rgb = PAL[(ink, bright)], PAL[(paper, bright)]
            for y in range(8):
                for x in range(8):
                    px[c * 8 + x, r * 8 + y] = ink_rgb if bmp[y][x] == "1" else pap_rgb
    out = HERE / "loading-screen.png"
    img.save(out)
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
