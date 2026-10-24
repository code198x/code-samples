"""Independent arithmetic/bounds model for rectangle-clipping."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "toolkit_models",
    Path(__file__).parents[2] / "framework/toolkit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "rectangle-clipping"
FIELDS = ['OUT_LEFT', 'OUT_TOP', 'OUT_RIGHT', 'OUT_BOTTOM', 'VISIBLE', 'VALID', 'LEFT', 'TOP', 'RIGHT', 'BOTTOM', 'VIEW_LEFT', 'VIEW_TOP', 'VIEW_RIGHT', 'VIEW_BOTTOM']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
