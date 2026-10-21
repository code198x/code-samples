"""Bounded text workloads, phase/edge cases, declaration failures and visible scenes."""

from __future__ import annotations


def cases(c: dict) -> list[dict]:
    out = []

    def add(kind="string", xy=(21, 37), **kw):
        r = {"id": f"{len(out):03d}-{kind}", "kind": kind, "xy": list(xy), **kw}
        if kind == "string" and "bytes" not in r:
            r["bytes"] = list(b"PIXEL TEXT")
        out.append(r)

    for phase in range(8):
        for mode in [0, 1]:
            add(xy=(24 + phase, 24 + phase * 10), mode=mode)
    for xy in [
        (-1, 20),
        (-7, 20),
        (-8, 20),
        (-9, -3),
        (c["width"] - 1, 20),
        (c["width"] - 7, c["height"] - 3),
        (c["width"] - 8, c["height"] - 8),
        (-512, -512),
        (511, 511),
    ]:
        for mode in [0, 1]:
            add(xy=xy, mode=mode)
    for clip in [
        [25, 38, 49, 43],
        [0, 0, 1, 1],
        [c["width"] - 1, c["height"] - 1, c["width"], c["height"]],
    ]:
        add(xy=(-3, -2) if clip[2] == 1 else (21, 37), clip=clip, mode=1)
    for code in [32, 63, 65, 95, 0, 31, 96, 255]:
        add("char", code=code, mode=1)
    add(bytes=[])
    add(bytes=[0, 31, 32, 63, 95, 96, 255], mode=1)
    add(xy=(-512, 61), bytes=[65] * 255, mode=1)
    add(bytes=list(range(32, 96)), xy=(-15, 83))
    add(
        bytes=list(range(256))[:255],
        xy=(-512, 100),
        font="synthetic",
        first=0,
        count=256,
        fallback=0,
    )
    add("char", code=255, font="synthetic", first=0, count=256, fallback=0)
    for fg in range(c["pen_max"] + 1):
        for bg in range(c["pen_max"] + 1):
            add(xy=(101 + fg, 121 + bg * 10), fg=fg, bg=bg, mode=1)
    for patch in [
        {"mode": 2},
        {"fg": c["pen_max"] + 1},
        {"bg": c["pen_max"] + 1},
        {"xy": [-513, 0]},
        {"xy": [512, 0]},
        {"count": 0},
        {"count": 257},
        {"first": 250, "count": 64},
        {"fallback": 0},
        {"fallback": 96},
        {"font_ptr": 65535},
        {"source_ptr": 65535},
        {"clip": [0, 0, 0, 10]},
        {"clip": [2, 1, 1, 10]},
        {"clip": [0, 0, c["width"] + 1, c["height"]]},
        {"clip": [0, -1, c["width"], c["height"]]},
    ]:
        add(**patch)
    add(xy=(19, 25), bytes=list(b"PIXEL TEXT"), mode=0, scene=True)
    add(
        xy=(22, 53),
        bytes=list(b"SCORE 0123456789"),
        mode=1,
        fg=min(2, c["pen_max"]),
        scene=True,
    )
    add(xy=(-3, 81), bytes=list(b"CLIPPED ? 42"), mode=1, fg=c["pen_max"], scene=True)
    add(xy=(25, 109), bytes=[65, 66, 255, 67], scene=True)
    for sx in range(1, 5):
        for sy in range(1, 5):
            for mode in (0, 1):
                add(xy=(21, 37), bytes=list(b"W!"), scale=[sx, sy], mode=mode)
        for phase in range(8):
            add(xy=(16 + phase, 21), bytes=list(b"W!"), scale=[sx, 3], mode=1)
    for scale in ([0, 1], [1, 0], [5, 1], [1, 5], [255, 2], [2, 255]):
        add(scale=scale)
    for scale in ([1, 4], [4, 1], [4, 4]):
        add(xy=(-3, -5), scale=scale, mode=1)
        add(xy=(c["width"] - 3, c["height"] - 5), scale=scale, mode=1)
    add(xy=(-512, 61), bytes=[65] * 255, scale=[4, 4], mode=1)
    add(xy=(21, 37), bytes=list(b"BIG!"), scale=[3, 2], mode=1, scene=True)
    add(xy=(511, 511), bytes=[0, 255, 65], scale=[4, 4], mode=1)
    return out
