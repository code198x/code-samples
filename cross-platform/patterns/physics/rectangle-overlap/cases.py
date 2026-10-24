"""Independent interval-intersection oracle; no machine arithmetic is reused."""

import random


def overlap(a, b):
    return (
        a[0] < a[2]
        and a[1] < a[3]
        and b[0] < b[2]
        and b[1] < b[3]
        and max(a[0], b[0]) < min(a[2], b[2])
        and max(a[1], b[1]) < min(a[3], b[3])
    )


def cases(limit=255):
    named = [
        ("overlap", [2, 2, 8, 6], [6, 4, 11, 7]),
        ("touch-right", [2, 2, 8, 6], [8, 2, 13, 6]),
        ("touch-bottom", [2, 2, 8, 6], [2, 6, 8, 9]),
        ("corner", [2, 2, 8, 6], [8, 6, 13, 9]),
        ("contained", [2, 2, 8, 6], [3, 3, 7, 5]),
        ("same", [2, 2, 8, 6], [2, 2, 8, 6]),
        ("apart", [2, 2, 8, 6], [9, 8, 13, 9]),
        ("zero-width", [2, 2, 2, 6], [1, 1, 9, 9]),
        ("zero-height", [2, 2, 8, 2], [1, 1, 9, 9]),
        ("reversed", [8, 2, 2, 6], [1, 1, 9, 9]),
        (
            "high",
            [limit - 1, limit - 1, limit, limit],
            [limit - 2, limit - 2, limit, limit],
        ),
        ("high-touch", [0, 0, limit - 1, limit], [limit - 1, 0, limit, limit]),
    ]
    named += [(n + "-swapped", b, a) for n, a, b in list(named)]
    rng = random.Random(1984)
    for i in range(160):
        values = [rng.randrange(limit + 1) for _ in range(8)]
        if i % 2 == 0:
            values = [
                *sorted(values[0:4:2]),
                *sorted(values[1:4:2]),
                *sorted(values[4:8:2]),
                *sorted(values[5:8:2]),
            ]
            # Convert x-pair,y-pair to left,top,right,bottom.
            values = [values[j] for j in [0, 2, 1, 3, 4, 6, 5, 7]]
        named.append(("generated-" + str(i), values[:4], values[4:]))
    return [
        {"name": n, "a": a, "b": b, "expected": int(overlap(a, b))} for n, a, b in named
    ]
