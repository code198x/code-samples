"""Independent ordering, set, interval and finite-bag specifications."""

from __future__ import annotations

CATEGORIES = {
    "stable-depth-order": "rendering",
    "dirty-cells": "rendering",
    "weighted-choice": "ai",
    "shuffle-bag": "ai",
}
LABELS = {
    "stable-depth-order": "SORT RESULTS",
    "dirty-cells": "DIRT RESULTS",
    "weighted-choice": "PICK RESULTS",
    "shuffle-bag": "BAGS RESULTS",
}
FIELDS = {
    "stable-depth-order": ["C", "O", "E"]
    + [f"D{i}" for i in range(1, 9)]
    + [f"P{i}" for i in range(1, 9)],
    "dirty-cells": ["L", "H", "S", "M", "O", "R", "E"],
    "weighted-choice": ["C", "A", "R", "O", "E", "T"] + [f"W{i}" for i in range(1, 9)],
    "shuffle-bag": ["C", "N", "J", "R", "O", "E"] + [f"B{i}" for i in range(1, 9)],
}


def integral(v: int, lo: int, hi: int) -> bool:
    return lo <= v <= hi and v == int(v)


def order(data: list[int]) -> list[int]:
    d = list(data)
    count = d[0]
    d[1:3] = [0, 1]
    if not integral(count, 0, 8) or any(
        not integral(x, 0, 255) for x in d[3 : 3 + count]
    ):
        return d
    d[1:3] = [1, 0]
    d[11:] = sorted(range(count), key=lambda i: (d[3 + i], i)) + list(range(count, 8))
    return d


def dirty(data: list[int]) -> list[int]:
    d = list(data)
    lo, hi, slot, mode = d[:4]
    d[4:] = [0, 255, 1]
    if not integral(lo, 0, 255) or not integral(hi, 0, 255):
        return d
    d[6] = 2
    if not integral(mode, 0, 3) or (mode < 2 and not integral(slot, 0, 15)):
        return d
    cells = {i for i in range(16) if (lo + 256 * hi) & (1 << i)}
    d[6] = 0
    if mode < 2:
        present = slot in cells
        d[4] = int(not present) if mode == 0 else int(present)
        d[5] = slot
        cells = (cells | {slot}) if mode == 0 else (cells - {slot})
    elif cells:
        d[4:6] = [1, min(cells)]
        if mode == 2:
            cells.remove(d[5])
    mask = sum(1 << i for i in cells)
    d[:2] = [mask % 256, mask // 256]
    return d


def choice(data: list[int]) -> list[int]:
    d = list(data)
    count, draw = d[:2]
    d[2:6] = [255, 0, 1, 0]
    if not integral(count, 0, 8):
        return d
    weights = d[6 : 6 + count]
    if any(not integral(x, 0, 255) for x in weights) or sum(weights) > 255:
        return d
    d[4] = 0
    d[5] = sum(weights)
    if not d[5]:
        return d
    if not integral(draw, 0, d[5] - 1):
        d[4] = 2
        return d
    # Build disjoint half-open intervals from prefix sums, not a mutable traversal.
    bounds = [sum(weights[:i]) for i in range(count + 1)]
    selected = next(i for i in range(count) if bounds[i] <= draw < bounds[i + 1])
    d[2:4] = [selected, 1]
    return d


def reset_bag(data: list[int]) -> list[int]:
    d = list(data)
    d[3:6] = [255, 0, 1]
    if not integral(d[0], 1, 8):
        return d
    d[1] = d[0]
    d[3:6] = [255, 1, 0]
    d[6:] = list(range(8))
    return d


def bag(data: list[int]) -> list[int]:
    d = list(data)
    cap, left, draw = d[:3]
    d[3:6] = [255, 0, 1]
    if not integral(cap, 1, 8) or not integral(left, 0, cap):
        return d
    active = d[6 : 6 + left]
    if any(not integral(x, 0, cap - 1) for x in active) or len(set(active)) != left:
        return d
    d[5] = 0
    if not left:
        return d
    if not integral(draw, 0, left - 1):
        d[5] = 2
        return d
    d[3:5] = [active[draw], 1]
    d[1] = left - 1
    d[6:] = [active[-1] if i == draw else x for i, x in enumerate(d[6:])]
    return d


FUNCTIONS = {
    "stable-depth-order": order,
    "dirty-cells": dirty,
    "weighted-choice": choice,
    "shuffle-bag": bag,
}


def initial(topic: str, custom: bool = False) -> list[int]:
    if topic == "stable-depth-order":
        return [4 if custom else 8, 0, 0] + [0] * 8 + list(range(8))
    if topic == "dirty-cells":
        return [0, 0, 0, 0, 0, 255, 0]
    if topic == "weighted-choice":
        return [4, 0, 255, 0, 0, 0] + [0] * 8
    return reset_bag([4 if custom else 8, 0, 0, 0, 0, 0] + [0] * 8)


def rows(topic: str, custom: bool = False) -> list[list[int]]:
    if topic == "stable-depth-order":
        depths = [
            [6, 2, 2, 9, 1, 6, 0, 3],
            list(range(8)),
            list(range(7, -1, -1)),
            [5] * 8,
            [255, 0, 255, 0, 1, 1, 128, 128],
        ]
        out = [[8, 9, 9] + v + [7] * 8 for v in depths]
        out += [[c, 9, 9] + depths[0] + [6] * 8 for c in [0, 1, 2, 4, 7, 9, 255]]
        return out
    if topic == "dirty-cells":
        return [
            [lo, hi, slot, mode, 9, 9, 9]
            for lo, hi, slot, mode in [
                (0, 0, 0, 0),
                (0, 0, 7, 0),
                (0, 0, 8, 0),
                (0, 0, 15, 0),
                (128, 0, 7, 0),
                (0, 128, 15, 1),
                (255, 255, 0, 1),
                (0, 0, 0, 1),
                (128, 1, 255, 3),
                (128, 1, 255, 2),
                (0, 128, 255, 2),
                (0, 0, 255, 2),
                (255, 255, 0, 3),
                (0, 0, 16, 0),
                (0, 0, 255, 1),
                (1, 0, 0, 4),
                (1, 0, 255, 3),
            ]
        ]
    if topic == "weighted-choice":
        weights = [
            [1, 3, 0, 4, 0, 0, 0, 0],
            [0, 0, 5, 0, 0, 0, 0, 0],
            [255, 0, 0, 0, 0, 0, 0, 0],
            [200, 100, 0, 0, 0, 0, 0, 0],
        ]
        out = [[4, a, 9, 9, 9, 9] + weights[0] for a in [0, 1, 3, 4, 7, 8, 255]]
        out += [[4, a, 9, 9, 9, 9] + weights[1] for a in [0, 4, 5]]
        out += [
            [1, 254, 9, 9, 9, 9] + weights[2],
            [2, 0, 9, 9, 9, 9] + weights[3],
            [0, 255, 9, 9, 9, 9] + weights[2],
            [9, 0, 9, 9, 9, 9] + [0] * 8,
            [4, 255, 9, 9, 9, 9] + [0] * 8,
        ]
        return out
    out = []
    for cap, left, draw, cells in [
        (8, 8, 0, list(range(8))),
        (8, 8, 7, list(range(8))),
        (4, 4, 2, list(range(8))),
        (1, 1, 0, list(range(8))),
        (8, 0, 255, [9] * 8),
        (8, 8, 8, list(range(8))),
        (8, 8, 255, list(range(8))),
        (8, 9, 0, list(range(8))),
        (0, 0, 0, list(range(8))),
        (9, 8, 0, list(range(8))),
        (4, 3, 1, [0, 0, 2, 9, 9, 9, 9, 9]),
        (4, 3, 1, [0, 1, 4, 9, 9, 9, 9, 9]),
        (4, 3, 1, [3, 0, 2, 9, 9, 9, 9, 9]),
        (8, 1, 0, [7] * 8),
    ]:
        out.append([cap, left, draw, 9, 9, 9] + cells)
    return out


def clients(topic: str, custom: bool, wrong: bool) -> list[list[int]]:
    out = []
    if topic == "stable-depth-order":
        c = 4 if custom else 8
        d = [0 if wrong else c, 0, 0] + [6, 2, 2, 9, 1, 6, 0, 3] + list(range(8))
        d = order(d)
        out.append(list(d))
        d[0] = c
        d[3] = 0
        d = order(d)
        out.append(list(d))
        d[0] = 9
        d = order(d)
        out.append(list(d))
        d[0] = c
        d = order(d)
        out.append(list(d))
        return out
    if topic == "dirty-cells":
        slots = [1, 6, 9, 14] if custom else [0, 7, 8, 15]
        d = initial(topic)
        for slot in slots:
            d[2:4] = [slot, 0]
            d = dirty(d)
            out.append(list(d))
        d[2:4] = [slots[0], 0]
        d = dirty(d)
        out.append(list(d))
        if wrong:
            d[:2] = [0, 0]
        d[2:4] = [255, 3]
        d = dirty(d)
        out.append(list(d))
        d[3] = 2
        d = dirty(d)
        out.append(list(d))
        d[2:4] = [slots[-1], 1]
        d = dirty(d)
        out.append(list(d))
        for _ in range(3):
            d[3] = 2
            d = dirty(d)
            out.append(list(d))
        return out
    if topic == "weighted-choice":
        weights = ([2, 0, 5, 1] if custom else [1, 3, 0, 4]) + [0] * 4
        d = [4, 0, 255, 0, 0, 0] + weights
        for draw in [7 if custom else 6, 5, 0]:
            d[1] = draw % 4 if wrong else draw
            d = choice(d)
            out.append(list(d))
        d[1] = 255
        d[6:] = [0] * 8
        d = choice(d)
        out.append(list(d))
        return out
    d = initial(topic, custom)
    out.append(list(d))
    for _ in range(d[0]):
        if wrong:
            d = reset_bag(d)
        d[2] = d[1] - 1 if custom else 0
        d = bag(d)
        out.append(list(d))
    d[2] = 0
    d = bag(d)
    out.append(list(d))
    return out


def packet(topic: str, variant: str) -> list[int]:
    custom = variant == "custom"
    wrong = variant == "wrong"
    states = (
        [initial(topic, custom)]
        + [FUNCTIONS[topic](r) for r in rows(topic, custom)]
        + clients(topic, custom, wrong)
    )
    assert all(len(r) == len(FIELDS[topic]) for r in states)
    result = [v for row in states for v in row]
    assert len(result) < 995 and all(integral(v, 0, 255) for v in result)
    return result
