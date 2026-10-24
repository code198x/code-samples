"""Independent arithmetic/bounds model for contact-pair-cache."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nightone_models",
    Path(__file__).parents[2] / "framework/nightone-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "contact-pair-cache"
FIELDS = ['FIRST', 'VALID', 'MODE', 'OBJECT_A', 'OBJECT_B', 'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
