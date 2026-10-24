"""Independent bit-equation oracle and finite-domain checks for the byte LFSR."""


def step(value):
    # Output bits expressed as parity equations, not a shift/feedback branch.
    return sum(
        ((value & mask).bit_count() & 1) << bit
        for bit, mask in enumerate((2, 4, 9, 16, 33, 65, 128, 1))
    )


def sequence(seed, count):
    result = []
    for _ in range(count):
        seed = step(seed)
        result.append(seed)
    return result


def packet():
    pairs = [v for external in range(256) for v in (external or 1, step(external or 1))]
    cycle = sequence(1, 255)
    if len(set(cycle)) != 255 or set(cycle) != set(range(1, 256)) or cycle[-1] != 1:
        raise AssertionError("Period oracle failed")
    checkpoint = sequence(90, 7)[-1]
    replay = sequence(checkpoint, 8)
    return [165] + pairs + cycle + replay + replay + [0] * 8 + [82, 147, 239]
