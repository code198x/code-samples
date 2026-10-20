"""All phases, operations, mode bounds, control rejection and LMS split workloads."""

from __future__ import annotations


def cases(c):
    result = []

    def add(kind, coords, op=0, **kw):
        result.append(
            {
                "id": f"{len(result):03d}-{kind}",
                "kind": kind,
                "coords": list(coords),
                "op": op,
                **kw,
            }
        )

    width = 6 if c["machine_id"] == "oric" else 8
    for phase in range(width):
        for op in [0, 2, 1]:
            add("pixel", (24 + phase, 17, 0, 0), op)
            add("read", (24 + phase, 17, 0, 0))
            add("hspan", (24 + phase, 29, 24 + phase + width + 3, 0), op)
    for kind in ["pixel", "read", "hspan", "vspan", "box", "fill"]:
        for op in [0] if kind == "read" else [0, 1, 2]:
            for coords in [
                (0, 0, 1, 1),
                (c["width"] - 1, c["height"] - 1, c["width"], c["height"]),
                (5, 100, 19, 105),
            ]:
                add(kind, coords, op)
    for op in [0, 1, 2]:
        add("fill", (0, 0, c["width"], c["height"]), op)
    for coords in [
        (5, 5, 5, 7),
        (9, 5, 3, 7),
        (0, 0, c["width"] + 1, 3),
        (0, 0, 1, c["height"] + 1),
        (65535, 0, 2, 1),
        (0, 65535, 1, 2),
        (0, 0, 0, 0),
    ]:
        for kind in ["fill", "box"]:
            add(kind, coords)
    for kind in ["pixel", "read", "hspan", "vspan", "fill", "box"]:
        add(kind, (5, 5, 17, 13), 3)
    add("read", (5, 5, 0, 0), 1)
    add("read", (5, 5, 0, 0), 2)
    for kind in ["pixel", "read"]:
        add(kind, (c["width"], 0, 0, 0))
        add(kind, (0, c["height"], 0, 0))
    if c["machine_id"] == "oric":
        add("fill", (12, 39, 60, 43), control=[24, 40])
        add("pixel", (24, 40, 0, 0), control=[24, 40])
        add("read", (24, 40, 0, 0), control=[24, 40])
        add("box", (12, 39, 60, 43), control=[24, 40])
        add("fill", (12, 39, 60, 43), control=[24, 40], value=32)
        add("read", (24, 40, 0, 0), control=[24, 40], value=32)
    for kind, coords in [
        ("fill", (17, 21, 83, 37)),
        ("box", (13, 47, 113, 79)),
        ("hspan", (5, 101, c["width"] - 3, 0)),
        ("vspan", (c["width"] - 13, 4, 0, c["height"] - 4)),
        ("box", (c["width"] - 31, c["height"] - 25, c["width"] - 1, c["height"] - 1)),
    ]:
        add(kind, coords, scene=True)
    return result
