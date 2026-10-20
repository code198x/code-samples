"""Named workloads: every machine runs the same geometry contract independently."""

from __future__ import annotations

from typing import Any


def geometry_cases(c: dict[str, Any]) -> list[dict[str, Any]]:
    out = []

    def add(kind, coords, op=0, **kw):
        out.append(
            {
                "id": f"{len(out):03d}-{kind}",
                "kind": kind,
                "coords": list(coords),
                "op": op,
                **kw,
            }
        )

    # All octants, reversal and tie slopes; nonzero targets reveal XOR duplication.
    for dx, dy in [
        (45, 19),
        (19, 45),
        (-19, 45),
        (-45, 19),
        (-45, -19),
        (-19, -45),
        (19, -45),
        (45, -19),
        (8, 4),
        (4, 8),
        (1, 1),
    ]:
        a, b = 100, 90
        for coords in [(a, b, a + dx, b + dy), (a + dx, b + dy, a, b)]:
            for op in [0, 2]:
                add("line", coords, op)
    for coords in [
        (0, 0, 0, 0),
        (0, 0, c["width"] - 1, 0),
        (c["width"] - 1, c["height"] - 1, 0, c["height"] - 1),
        (0, 0, 0, c["height"] - 1),
        (c["width"] - 1, c["height"] - 1, c["width"] - 1, 0),
        (-512, 37, 511, 37),
        (67, -512, 67, 511),
        (-512, -512, 511, 511),
        (-512, 511, 511, -512),
        (-512, -400, -300, -400),
    ]:
        for flags in [0, 1]:
            add("line", coords, 2, flags=flags)
    # A closed polygon uses omit-original-last on each edge: every corner once.
    for a, b in [
        ((20, 20), (70, 20)),
        ((70, 20), (70, 45)),
        ((70, 45), (20, 45)),
        ((20, 45), (20, 20)),
    ]:
        add("line", (*a, *b), 2, flags=1)
    for coords in [
        (-20, 10, 80, 55),
        (80, 55, -20, 10),
        (0, 0, c["width"] - 1, c["height"] - 1),
        (10, 100, 90, 10),
    ]:
        add("line", coords, 0, clip=[21, 17, 73, 61])
    for kind in ["circle", "ellipse", "fill_circle", "fill_ellipse"]:
        shapes = [
            (50, 90, 0, 0),
            (50, 90, 1, 1),
            (100, 70, 23, 13),
            (10, 10, 25, 17),
            (c["width"] - 1, c["height"] - 1, 28, 12),
            (0, 0, 255, 1),
            (150, 100, 1, 255),
            (120, 90, 255, 255),
            (120, 90, 255, 253),
            (-512, -512, 255, 255),
            (50, 60, 0, 15),
            (50, 60, 15, 0),
        ]
        for coords in shapes:
            for op in [0, 2]:
                add(kind, coords, op, pen=2 if c["machine_id"] == "amstrad-cpc" else 1)
        add(kind, (50, 45, 40, 28), 1, clip=[24, 23, 69, 64])
        add(kind, (50, 45, 40, 28), 2, clip=[24, 23, 69, 64])
    # Every public range failure must preserve the complete picture and guards.
    for coords in [
        (-513, 0, 1, 1),
        (512, 0, 1, 1),
        (0, -513, 1, 1),
        (0, 512, 1, 1),
        (0, 0, -513, 1),
        (0, 0, 512, 1),
        (0, 0, 1, -513),
        (0, 0, 1, 512),
    ]:
        add("line", coords)
    for kind in ["circle", "ellipse", "fill_circle", "fill_ellipse"]:
        for coords in [(40, 40, -1, 12), (40, 40, 256, 12), (512, 40, 20, 12)]:
            add(kind, coords)
        if kind in ["ellipse", "fill_ellipse"]:
            for coords in [(40, 40, 12, -1), (40, 40, 12, 256)]:
                add(kind, coords)
    for kw in [
        {"op": 3},
        {"flags": 2},
        {"clip": [0, 0, 0, 10]},
        {"clip": [10, 10, 5, 15]},
        {"clip": [-1, 0, 20, 20]},
        {"clip": [0, 0, c["width"] + 1, 20]},
        {"clip": [0, 0, 20, c["height"] + 1]},
    ]:
        op = kw.pop("op", 0)
        add("line", (20, 20, 70, 45), op, **kw)
    add("ellipse", (50, 50, 20, 12), flags=1)
    if c["machine_id"] == "amstrad-cpc":
        add("ellipse", (50, 50, 20, 12), pen=4)
    # Original composition retained as the article's actual native capture.
    for kind, coords, pen in [
        ("fill_ellipse", (80, 70, 44, 25), 2),
        ("ellipse", (80, 70, 44, 25), 1),
        ("circle", (172, 75, 38, 0), 3),
        ("ellipse", (208, 141, 62, 18), 1),
        ("line", (-30, 151, 300, 31), 1),
        ("fill_circle", (40, 143, 18, 0), 3),
    ]:
        add(
            kind,
            coords,
            0,
            pen=pen if c["machine_id"] == "amstrad-cpc" else 1,
            scene=True,
        )
    return out


def cpc_cases() -> list[dict[str, Any]]:
    out = []

    def add(kind, coords, op=0, pen=1):
        out.append(
            {
                "id": f"cpc-{len(out):03d}-{kind}",
                "kind": kind,
                "coords": list(coords),
                "op": op,
                "pen": pen,
            }
        )

    for phase in range(4):
        for pen in range(4):
            for kind, op in [
                ("pixel", 0),
                ("read", 0),
                ("pixel", 2),
                ("read", 0),
                ("pixel", 1),
                ("read", 0),
            ]:
                add(kind, (40 + phase, 20 + pen, 0, 0), op, pen)
            add("hspan", (41 + phase, 40 + pen, 70 + phase, 0), 0, pen)
            add("box", (11 + phase, 70 + pen * 9, 34 + phase, 76 + pen * 9), 2, pen)
    for kind, coords in [
        ("fill", (0, 0, 320, 200)),
        ("box", (0, 0, 320, 200)),
        ("hspan", (0, 0, 320, 0)),
        ("vspan", (319, 0, 0, 200)),
        ("pixel", (319, 199, 0, 0)),
        ("read", (319, 199, 0, 0)),
        ("fill", (319, 199, 320, 200)),
        ("box", (50, 30, 51, 40)),
        ("box", (50, 30, 60, 31)),
    ]:
        for op in [0, 1, 2]:
            add(kind, coords, op, 3)
    for kind, coords in [
        ("pixel", (320, 0, 0, 0)),
        ("pixel", (0, 200, 0, 0)),
        ("pixel", (65535, 0, 0, 0)),
        ("fill", (20, 20, 20, 30)),
        ("fill", (21, 20, 20, 30)),
        ("fill", (0, 0, 321, 200)),
        ("fill", (0, 0, 320, 201)),
        ("hspan", (0, 0, 321, 0)),
        ("vspan", (0, 0, 0, 201)),
    ]:
        add(kind, coords)
    add("pixel", (0, 0, 0, 0), 3)
    add("pixel", (0, 0, 0, 0), 0, 4)
    return out
