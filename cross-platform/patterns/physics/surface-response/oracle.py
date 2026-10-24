"""Independent arithmetic/bounds model for surface-response."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nightone_models",
    Path(__file__).parents[2] / "framework/nightone-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "surface-response"
FIELDS = [
    "NORMAL_OUT",
    "DIRECTION_OUT",
    "TANGENT_OUT",
    "VALID",
    "NORMAL_IN",
    "DIRECTION_IN",
    "TANGENT_IN",
    "RESTITUTION",
]


def cases(custom: bool = False) -> list[list[int]]:
    rows = M.cases(TOPIC, custom)
    # Exercise every supported coefficient natively, not only its invalid-input path.
    for i in range(40):
        rows[i][FIELDS.index("NORMAL_IN")] = [0, 1, 3, 4, 127, 128, 254, 255][i % 8]
        rows[i][FIELDS.index("RESTITUTION")] = i // 8
        rows[i][FIELDS.index("DIRECTION_IN")] = i % 2
    rows[40][FIELDS.index("DIRECTION_IN")] = 2
    rows[40][FIELDS.index("RESTITUTION")] = 0
    return rows


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    out = [165, list(M.TOPICS).index(TOPIC), int(custom)] + [0] * len(FIELDS)
    for row in cases(custom):
        out += M.step(TOPIC, row, custom)
    state = [0] * len(FIELDS)
    for changes in trace(custom):
        for key, value in changes.items():
            state[FIELDS.index(key)] = value
        state = M.step(TOPIC, state, custom, wrong)
        out += state
    return out + [239]


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return (packet(custom, wrong)[-1 - len(FIELDS) : -1] + [0] * 8)[:8]
