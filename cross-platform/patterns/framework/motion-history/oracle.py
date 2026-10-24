"""Independent arithmetic/bounds model for motion-history."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "worldkit_models",
    Path(__file__).parents[2] / "framework/worldkit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "motion-history"
FIELDS = ['OUT_X', 'OUT_Y', 'VALID', 'HEAD', 'COUNT', 'INPUT_X', 'INPUT_Y', 'LAG', 'PUSH', 'HX0', 'HX1', 'HX2', 'HX3', 'HX4', 'HX5', 'HX6', 'HX7', 'HY0', 'HY1', 'HY2', 'HY3', 'HY4', 'HY5', 'HY6', 'HY7']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
