"""Independent arithmetic/bounds model for pixel-mask-collision."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "worldkit_models",
    Path(__file__).parents[2] / "framework/worldkit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "pixel-mask-collision"
FIELDS = ['HIT', 'ROW', 'SHIFT_X', 'SHIFT_Y', 'P0', 'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7', 'Q0', 'Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
