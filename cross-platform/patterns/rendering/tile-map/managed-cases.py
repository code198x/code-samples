"""Shared map conventions, independent oracle for native managed-language ports."""


def cases():
    out = []

    def add(op, x=0, y=0, tile=0, wx=0, wy=0, w=7, h=5, cap=35):
        out.append(
            {
                "op": op,
                "x": x,
                "y": y,
                "tile": tile,
                "wx": wx,
                "wy": wy,
                "w": w,
                "h": h,
                "cap": cap,
            }
        )

    for y in range(5):
        for x in range(7):
            add(0, x, y)
    for x, y in [(-1, 0), (7, 0), (0, -1), (0, 5)]:
        add(0, x, y)
    for x, y, t in [
        (-1, 0, 2),
        (7, 0, 2),
        (0, -1, 2),
        (0, 5, 2),
        (3, 2, -1),
        (3, 2, 4),
    ]:
        add(1, x, y, t)
    add(1, 3, 2, 2)
    add(0, 3, 2)
    for tile in [0, 1, 2, 3, -1, 4]:
        add(2, tile=tile)
    for wx, wy in [(0, 0), (55, 39), (56, 0), (-1, 0), (0, -1), (65535, 0), (8, 8)]:
        add(3, wx=wx, wy=wy)
    for w, h, cap in [(0, 5, 35), (256, 5, 35), (7, 0, 35), (7, 5, 34)]:
        add(0, w=w, h=h, cap=cap)
    return out


def expected(custom=False):
    grid = [(x + y * 7) % 4 for y in range(5) for x in range(7)] + [99]
    props = [0, 1, 1 if custom else 2, 3]
    result = []
    for c in cases():
        x, y, t = c["x"], c["y"], c["tile"]
        valid = 0
        prop = 0
        if c["op"] == 3:
            x = y = t = 0
            if 0 <= c["wx"] <= 65535 and 0 <= c["wy"] <= 65535:
                x, y = c["wx"] // 8, c["wy"] // 8
            else:
                result.append([0, 0, 0, 0, 0] + grid[:])
                continue
        if c["op"] == 2:
            if 0 <= t <= 3:
                valid = 1
                prop = props[t]
        else:
            valid = int(
                1 <= c["w"] <= 255
                and 1 <= c["h"] <= 255
                and c["cap"] >= c["w"] * c["h"]
                and 0 <= x < c["w"]
                and 0 <= y < c["h"]
            )
            if c["op"] in (0, 3):
                t = grid[y * c["w"] + x] if valid else 0
                if t < 0 or t > 3:
                    t = 0
                    valid = 0
            elif not 0 <= t <= 3:
                valid = 0
            if c["op"] == 1 and valid:
                grid[y * c["w"] + x] = t
        result.append([valid, t, prop, x, y] + grid[:])
    return result
