"""All phases, operations, mode bounds and interleaved-row boundaries."""

from __future__ import annotations

from typing import Any


def cases(c: dict[str, Any]) -> list[dict[str, Any]]:
    result = []

    def add(kind: Any, coords: Any, op: Any = 0, **kw) -> None:
        result.append(
            {
                "id": f"{len(result):03d}-{kind}",
                "kind": kind,
                "coords": list(coords),
                "op": op,
                **kw,
            }
        )

    width = 8
    for phase in range(width):
        for op in [0, 2, 1]:
            add("pixel", (24 + phase, 17, 0, 0), op)
            add("read", (24 + phase, 17, 0, 0))
            add("hspan", (24 + phase, 29, 24 + phase + width + 3, 0), op)
    for x in [24, 25]:
        add("fill", (x, 50, x + 32, 58), 0, workload=True)
    for kind in ["pixel", "read", "hspan", "vspan", "box", "fill"]:
        for op in [0] if kind == "read" else [0, 1, 2]:
            for coords in [
                (0, 0, 1, 1),
                (c["width"] - 1, c["height"] - 1, c["width"], c["height"]),
                (5, 100, 19, 105),
            ]:
                add(kind, coords, op)
    for y in [7, 8, 15, 16, 127, 128, 191, 192]:
        if y + 2 <= c["height"]:
            add("box", (3, y, 27, y + 2), 2)
            add("vspan", (7, y, 0, y + 2))
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
    for kind, coords in [
        ("fill", (17, 21, 83, 37)),
        ("box", (13, 47, 113, 79)),
        ("hspan", (5, 101, c["width"] - 3, 0)),
        ("vspan", (c["width"] - 13, 4, 0, c["height"] - 4)),
        ("box", (c["width"] - 31, c["height"] - 25, c["width"] - 1, c["height"] - 1)),
    ]:
        add(kind, coords, scene=True)
    return result
