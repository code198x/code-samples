"""What the screen should hold: a host model of the ship as the ROM draws it.

PLOT and DRAW with OVER 1 toggle each pixel they visit. DRAW steps along its
larger axis and adds the smaller one with the ROM's own error rule (DRAW-LINE,
0x24B7): the error starts at half the larger length; each step adds the
smaller length and takes a diagonal step when the sum carries past the larger
one. Coordinates are BASIC's: x right, y up from the bottom of the screen.
"""


def draw(pixels, start, moves):
    """Toggle PLOT start then each DRAW move, as OVER 1 does."""
    x, y = start
    pixels ^= {(x, y)}
    for dx, dy in moves:
        sx, sy = (dx > 0) - (dx < 0), (dy > 0) - (dy < 0)
        ax, ay = abs(dx), abs(dy)
        big, small = max(ax, ay), min(ax, ay)
        straight = (sx, 0) if ax >= ay else (0, sy)
        error = big >> 1
        for _ in range(big):
            error += small
            if error >= big:
                error -= big
                x, y = x + sx, y + sy
            else:
                x, y = x + straight[0], y + straight[1]
            pixels ^= {(x, y)}
    return pixels


def ship(s, px, py, h):
    """The triangle lines 3000-3040 draw for heading h at whole pixels px, py."""
    i = int(h) - 1
    c, d, e, f, g, j = (int(s[name][i]) for name in 'cdefgj')
    return draw(set(), (px + c, py + d), [(e - c, f - d), (g - e, j - f), (c - g, d - j)])


def drawn_at(s):
    """The whole-pixel centre the program draws for its unrounded x and y."""
    return int((s['x'] + .5) // 1), int((s['y'] + .5) // 1)
