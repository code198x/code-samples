"""Independent integer countdown and resource-aware action policy."""

REQUESTS = [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0]


def attempt(remaining, request, available, period):
    granted = int(remaining == 0 and request != 0 and available != 0)
    return [period if granted else remaining, granted]


def inputs():
    return (
        [(0, t, 1, 1) for t in range(256)]
        + [(1, 0, r, 1) for r in range(256)]
        + [(2, 0, r, 0) for r in range(256)]
        + [(3, 0, 1, a) for a in range(256)]
    )


def session(period, broken):
    remaining, total, at3, at6, blocked, trace = 0, 0, 0, 0, 0, []
    for index, request in enumerate(REQUESTS):
        if not broken or request:
            remaining = max(0, remaining - 1)
        remaining, granted = attempt(remaining, request, 1, period)
        total += granted
        blocked += int(request != 0 and granted == 0)
        if index == 3:
            at3 = granted
        if index == 6:
            at6 = granted
        trace += [remaining, request, 1, granted]
    return trace, [total, remaining, at3, at6, blocked, 1, period, granted]


def packet(period, broken=False):
    result = [165, period, 0, 0, 0, 0]
    for mode, remaining, request, available in inputs():
        if mode == 0:
            remaining = max(0, remaining - 1)
        remaining, granted = attempt(remaining, request, available, period)
        result += (
            [remaining, granted] if mode == 0 else [remaining | (128 if granted else 0)]
        )
    return result + session(period, broken)[0] + [239]


def preview(period, broken=False):
    return session(period, broken)[1]
