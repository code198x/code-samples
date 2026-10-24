"""Independent arithmetic/bounds model for viewport-world-transform."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nightone_models",
    Path(__file__).parents[2] / "framework/nightone-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "viewport-world-transform"
FIELDS = ['SCREEN_X', 'SCREEN_Y', 'VISIBLE', 'VALID', 'WORLD_X_LO', 'WORLD_X_HI', 'WORLD_Y_LO', 'WORLD_Y_HI', 'CAMERA_X_LO', 'CAMERA_X_HI', 'CAMERA_Y_LO', 'CAMERA_Y_HI', 'WIDTH', 'HEIGHT']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
