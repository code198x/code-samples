"""Independent arithmetic/bounds model for bitmap-transpose."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "toolkit_models",
    Path(__file__).parents[2] / "framework/toolkit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "bitmap-transpose"
FIELDS = ['R0', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
