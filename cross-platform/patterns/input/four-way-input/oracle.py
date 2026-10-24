"""Independent arithmetic/bounds model for four-way-input."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gamekit_models",
    Path(__file__).parents[2] / "framework/gamekit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "four-way-input"
FIELDS = ['HELD', 'LAST_AXIS', 'DIRECTION', 'VALID']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
