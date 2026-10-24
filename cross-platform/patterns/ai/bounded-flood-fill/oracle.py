"""Independent arithmetic/bounds model for bounded-flood-fill."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gamekit_models",
    Path(__file__).parents[2] / "framework/gamekit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "bounded-flood-fill"
FIELDS = ['SEED', 'REPLACEMENT', 'CHANGED', 'VALID', 'C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    out = [165, list(M.TOPICS).index(TOPIC), int(custom)] + [0] * len(FIELDS)
    for row in cases(custom):
        out += M.step(TOPIC, row, custom)
    state = [0] * len(FIELDS)
    for change in trace(custom):
        for field, value in change.items():
            state[FIELDS.index(field)] = value
        state = M.step(TOPIC, state, custom, wrong)
        out += state
    return out + [239]


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    rows = M.cases(TOPIC, custom)
    grids = [
        (0, 9, [1] * 16),
        (15, 9, [1] * 16),
        (0, 9, [1, 9, 1, 0] + [0] * 12),
        (0, 9, [1, 0, 0, 0, 0, 1, 0, 0] + [0] * 8),
        (12, 9, [1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0]),
        (16, 9, [1] * 16),
        (0, 255, [0] * 16),
        (0, 1, [1] * 16),
    ]
    for i, (seed, replacement, cells) in enumerate(grids):
        values = dict.fromkeys(FIELDS, 0)
        values.update(SEED=seed, REPLACEMENT=replacement)
        values.update({f"C{n}": value for n, value in enumerate(cells)})
        rows[len(rows) - 8 + i] = [values[field] for field in FIELDS]
    return rows


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
