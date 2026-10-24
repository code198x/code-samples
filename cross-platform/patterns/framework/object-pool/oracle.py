"""Independent set model for slot ownership, not a translation of 6502 branches."""


def packet(capacity):
    result = [165, capacity]
    for mask in range(256):
        live = {i for i in range(capacity) if mask & (1 << i)}
        free = sorted(set(range(capacity)) - live)
        chosen = free[0] if free else capacity
        status = 2 | (8 if free else 1)
        if free:
            live.add(chosen)
        after_allocate = sum(1 << i for i in live)
        if free:
            live.remove(chosen)
        after_release = sum(1 << i for i in live)
        result += [chosen, after_allocate, after_release, status, 147]
    return result + [0, 90, 167] + [60] * capacity + [239]


def preview(capacity, broken=False):
    return [
        0,
        1,
        2,
        255,
        255 if broken else 1,
        1,
        sum(1 << i for i in range(capacity) if i % 2),
        0,
    ]
