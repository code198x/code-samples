"""Independent flag, graph, geometric and timeline models for BASIC examples."""

from __future__ import annotations

from collections import deque

CATEGORIES = {
    "dialogue-gates": "framework",
    "bounded-grid-path": "ai",
    "grid-line-sight": "ai",
    "animation-timeline": "rendering",
}
LABELS = {
    "dialogue-gates": "TALK RESULTS",
    "bounded-grid-path": "PATH RESULTS",
    "grid-line-sight": "LINE RESULTS",
    "animation-timeline": "ANIM RESULTS",
}
FIELDS = {
    "dialogue-gates": ["F", "R", "B", "S", "C", "A", "O", "T", "E"],
    "bounded-grid-path": ["W", "H", "S", "T", "P", "F", "O", "E", "C"]
    + [a + str(i) for a in ["M", "D", "R", "Q"] for i in range(1, 17)],
    "grid-line-sight": ["W", "H", "S", "T", "O", "E", "C"]
    + [a + str(i) for a in ["M", "V"] for i in range(1, 17)],
    "animation-timeline": ["F", "T", "C", "D", "L", "O", "E"],
}


def byte(value: int) -> bool:
    return int(value) == value and 0 <= value <= 255


def talk(row: list[int]) -> list[int]:
    f, r, b, s, c, a, _, _, _ = row
    if not all(byte(v) for v in [f, r, b, s, c]) or a not in [0, 1]:
        return [f, r, b, s, c, a, 0, 0, 1]
    flags = {i for i in range(8) if f & (1 << i)}
    required = {i for i in range(8) if r & (1 << i)}
    forbidden = {i for i in range(8) if b & (1 << i)}
    if required & forbidden:
        return [f, r, b, s, c, a, 0, 0, 2]
    available = int(required <= flags and not forbidden & flags)
    taken = int(available and a)
    if taken:
        flags = flags - {i for i in range(8) if c & (1 << i)} | {
            i for i in range(8) if s & (1 << i)
        }
        f = sum(1 << i for i in flags)
    return [f, r, b, s, c, a, available, taken, 0]


def dimensions(w: int, h: int, s: int, t: int) -> bool:
    return (
        all(int(v) == v for v in [w, h, s, t])
        and 1 <= w <= 4
        and 1 <= h <= 4
        and 0 <= s < w * h
        and 0 <= t < w * h
    )


def path(row: list[int]) -> list[int]:
    w, h, s, t = row[:4]
    cells = row[9:25]
    dist = [255] * 16
    parents = [255] * 16
    q = []
    prefix = [w, h, s, t, 255, 255, 0, 1, 0]

    def finish() -> list[int]:
        return prefix + cells + dist + parents + q + [0] * (16 - len(q))

    if not dimensions(w, h, s, t):
        return finish()
    if any(v not in [0, 1] for v in cells[: w * h]):
        prefix[7] = 2
        return finish()
    prefix[7] = 0
    if cells[s]:
        return finish()
    graph = {
        v: [
            ny * w + nx
            for nx, ny in [
                (v % w, v // w - 1),
                (v % w + 1, v // w),
                (v % w, v // w + 1),
                (v % w - 1, v // w),
            ]
            if 0 <= nx < w and 0 <= ny < h and not cells[ny * w + nx]
        ]
        for v in range(w * h)
        if not cells[v]
    }
    frontier = deque([s])
    dist[s] = 0
    q = [s]
    while frontier:
        v = frontier.popleft()
        for neighbour in graph[v]:
            if dist[neighbour] == 255:
                dist[neighbour] = dist[v] + 1
                parents[neighbour] = v
                frontier.append(neighbour)
                q.append(neighbour)
    prefix[8] = len(q)
    if dist[t] != 255:
        steps = []
        at = t
        while at != s:
            steps.append(at)
            at = parents[at]
        prefix[4:7] = [len(steps), steps[-1] if steps else s, 1]
    return finish()


def sampled_cells(w: int, s: int, t: int) -> list[int]:
    x, y = s % w, s // w
    tx, ty = t % w, t // w
    dx, dy = abs(tx - x), abs(ty - y)
    sx = 1 if tx >= x else -1
    sy = 1 if ty >= y else -1
    if max(dx, dy) == 0:
        return [s]
    if dx >= dy:
        return [
            (y + sy * ((2 * i * dy + dx) // (2 * dx))) * w + x + sx * i
            for i in range(dx + 1)
        ]
    return [
        (y + sy * i) * w + x + sx * ((2 * i * dx + dy) // (2 * dy))
        for i in range(dy + 1)
    ]


def sight(row: list[int]) -> list[int]:
    w, h, s, t = row[:4]
    cells = row[7:23]
    result = [w, h, s, t, 0, 1, 0] + cells
    visited = []
    if dimensions(w, h, s, t):
        if any(v not in [0, 1] for v in cells[: w * h]):
            result[5] = 2
        else:
            result[5] = 0
            for v in sampled_cells(w, s, t):
                visited.append(v)
                if cells[v]:
                    break
            else:
                result[4] = 1
    result[6] = len(visited)
    return result + visited + [255] * (16 - len(visited))


def animation(row: list[int]) -> list[int]:
    f, t, c, d, l, o, _ = row
    valid = (
        all(byte(v) for v in [f, t, c, d])
        and c > 0
        and d > 0
        and f < c
        and t < d
        and l in [0, 1]
        and o in [0, 1]
    )
    if not valid:
        return [f, t, c, d, l, o, 1]
    if o:
        return [f, t, c, d, l, o, 0]
    position = f * d + t + 1
    if l:
        position %= c * d
        f, t = divmod(position, d)
    elif position >= c * d:
        f, t, o = c - 1, 0, 1
    else:
        f, t = divmod(position, d)
    return [f, t, c, d, l, o, 0]


def call(topic: str, row: list[int]) -> list[int]:
    return {
        "dialogue-gates": talk,
        "bounded-grid-path": path,
        "grid-line-sight": sight,
        "animation-timeline": animation,
    }[topic](row)


def initial(topic: str, custom: bool = False) -> list[int]:
    if topic == "dialogue-gates":
        return [0] * 9
    if topic == "animation-timeline":
        return [0, 0, 4 if custom else 3, 3 if custom else 2, int(custom), 0, 0]
    w, h = (3, 4) if custom else (4, 4)
    if topic == "bounded-grid-path":
        return [w, h, 0, w - 1, 255, 255, 0, 0, 0] + [0] * 16 + [255] * 32 + [0] * 16
    return [w, h, 0, w * h - 1, 0, 0, 0] + [0] * 16 + [255] * 16


def rows(topic: str, custom: bool = False) -> list[list[int]]:
    if topic == "dialogue-gates":
        edges = [0, 1, 3, 15, 127, 128, 254, 255]
        return [
            [
                edges[i % 8],
                edges[(i // 8) % 8],
                edges[(i + 2) % 8],
                2,
                1,
                i % 2,
                9,
                9,
                9,
            ]
            for i in range(32)
        ]
    if topic == "animation-timeline":
        out = []
        for i in range(32):
            c = [1, 2, 3, 255][i % 4]
            d = [1, 2, 3, 255][(i // 4) % 4]
            row = [c - 1, d - 1, c, d, i % 2, (i // 16) % 2, 9]
            if i == 24:
                row[2] = 0
            if i == 25:
                row[3] = 0
            if i == 26:
                row[0] = c
            if i == 27:
                row[1] = d
            if i == 28:
                row[4] = 2
            if i == 29:
                row[5] = 2
            out.append(row)
        return out
    if topic == "bounded-grid-path":
        configs = [
            (4, 4, 0, 15, []),
            (4, 4, 0, 3, [1]),
            (4, 4, 0, 3, [3]),
            (4, 4, 0, 3, [0]),
            (4, 4, 5, 5, []),
            (1, 4, 0, 3, []),
            (4, 4, 3, 4, []),
            (0, 4, 0, 3, []),
            (4, 4, 0, 3, []),
            (4, 4, 16, 3, []),
        ]
        out = []
        for index, (w, h, s, t, walls) in enumerate(configs):
            cells = [int(i in walls) for i in range(16)]
            if index == 5:
                cells[4:] = [2] * 12
            if index == 8:
                cells[7] = 2
            out.append([w, h, s, t, 9, 9, 9, 9, 9] + cells + [42] * 48)
        return out
    pairs = [
        (0, 15),
        (15, 0),
        (3, 12),
        (12, 3),
        (0, 3),
        (3, 0),
        (0, 12),
        (12, 0),
        (0, 6),
        (6, 0),
        (0, 9),
        (9, 0),
        (5, 5),
        (0, 15),
        (0, 6),
        (6, 0),
        (0, 3),
        (0, 3),
        (0, 3),
        (0, 3),
        (0, 3),
    ]
    out = []
    for index, (s, t) in enumerate(pairs):
        w, h = (1, 4) if index == 20 else (4, 4)
        cells = [0] * 16
        if index in [13, 14, 15]:
            cells[5] = 1
        if index == 16:
            cells[s] = 1
        if index == 17:
            cells[t] = 1
        if index == 18:
            w = 0
        if index == 19:
            cells[0] = 2
        if index == 20:
            cells[4:] = [2] * 12
        out.append([w, h, s, t, 9, 9, 9] + cells + [42] * 16)
    return out


def clients(topic: str, custom: bool, wrong: bool) -> list[list[int]]:
    if topic == "dialogue-gates":
        f = 4 if custom else 1
        r = f
        b = 8 if custom else 2
        s = b
        c = f
        d = [0 if wrong else f, r, b, s, c, 0, 0, 0, 0]
        out = []
        for accept in [0, 1, 1]:
            d[5] = accept
            d = talk(d)
            out.append(list(d))
        d[1:6] = [b, f, 16, 0, 1]
        d = talk(d)
        out.append(list(d))
        d[5] = 0
        d = talk(d)
        out.append(list(d))
        return out
    if topic == "animation-timeline":
        d = initial(topic, custom)
        out = []
        for _ in range(12):
            if wrong:
                d[1] = 0
            d = animation(d)
            out.append(list(d))
        return out
    d = initial(topic, custom)
    w = d[0]
    if topic == "bounded-grid-path":
        d[9 + 1] = 0 if wrong else 1
        d = path(d)
        out = [list(d)]
        d[9 + w] = 1
        out.append(path(d))
        return out
    d[7 + w + 1] = 0 if wrong else 1
    d = sight(d)
    out = [list(d)]
    d[7 + w + 1] = 0
    out.append(sight(d))
    return out


def packet(topic: str, variant: str) -> list[int]:
    custom = variant == "custom"
    result = initial(topic, custom)
    for row in rows(topic, custom):
        result += call(topic, row)
    for row in clients(topic, custom, variant == "wrong"):
        result += row
    return result
