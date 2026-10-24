"""Independent transition policy and scripted session model.

The machine implementations use branches; this model selects named actions
from an ordered policy table and records the complete observable trace.
"""

HELD = [0, 3, 3, 0, 0, 3, 3, 0, 3, 0, 4, 0, 8, 8, 0]
POLICY = {
    0: [(1, 1, 1)],
    1: [(4, 2, 0), (2, 3, 0)],
    2: [(8, 1, 1), (1, 0, 0)],
    3: [(2, 1, 0)],
}


def step(state, events):
    if state not in POLICY:
        return [state, 0, 0, 1]
    if events & 240:
        return [state, 0, 0, 2]
    choice = next(
        ((n, fresh) for bit, n, fresh in POLICY[state] if events & bit), (state, 0)
    )
    return [choice[0], int(choice[0] != state), choice[1], 0]


def session(health, broken):
    state = score = previous = resets = resumed = finished = 0
    life = health
    trace = []
    for index, held in enumerate(HELD):
        events = held & (previous ^ 255)
        previous = held
        if state == 1:
            score = (score + 1) % 256
        state, changed, fresh, error = step(state, events)
        if fresh or (broken and changed and state == 1):
            score, life, resets = 0, health, resets + 1
        if index == 8:
            resumed = score
        if index == 10:
            finished = score
        trace += [state, changed, fresh, error, score, previous]
    return trace, [resumed, resets, state, score, life, finished, 1, changed]


def packet(health, broken=False):
    result = [165, health]
    for state in range(4):
        for events in range(16):
            result += step(state, events)
    for state in range(4, 256):
        result += step(state, 0)
    for state in range(4):
        for events in [16, 128, 255]:
            result += step(state, events)
    return result + session(health, broken)[0] + [239]


def preview(health, broken=False):
    return session(health, broken)[1]
