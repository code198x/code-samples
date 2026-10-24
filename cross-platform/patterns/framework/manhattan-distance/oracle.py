"""Independent outcomes for manhattan distance."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gameplay_models", Path(__file__).parents[1] / "gameplay-patterns/cases.py"
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "manhattan-distance"
FIELDS = ["AX", "AY", "BX", "BY", "DIST_LO", "DIST_HI"]


def cases(custom: bool = False) -> list[list[int]]:
    rows = M.cases(TOPIC, custom)
    # Equal positions and both axes at maximum belong in the native table too.
    rows[:4] = [
        [0, 0, 0, 0, 255, 255],
        [255, 255, 255, 255, 255, 255],
        [0, 0, 255, 255, 255, 255],
        [255, 255, 0, 0, 255, 255],
    ]
    return rows


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    out = [165, list(M.TOPICS).index(TOPIC), int(custom)] + [0] * len(FIELDS)
    for row in cases(custom):
        out += M.step(TOPIC, row, custom)
    state = [0] * len(FIELDS)
    for changes in trace(custom):
        for index, value in changes.items():
            state[index] = value
        state = M.step(TOPIC, state, custom, wrong)
        out += state
    return out + [239]


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return (packet(custom, wrong)[-1 - len(FIELDS) : -1] + [0] * 8)[:8]


def trace(custom: bool = False) -> list[dict[int, int]]:
    return M.trace(TOPIC, custom)
