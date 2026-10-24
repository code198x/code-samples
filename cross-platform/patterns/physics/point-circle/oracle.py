"""Independent arithmetic/bounds model for point-circle."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "worldkit_models",
    Path(__file__).parents[2] / "framework/worldkit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "point-circle"
FIELDS = ['HIT', 'DX', 'DY', 'POINT_X', 'POINT_Y', 'CENTRE_X', 'CENTRE_Y', 'RADIUS']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
