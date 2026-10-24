"""Independent arithmetic/bounds model for stable-compaction."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "worldkit_models",
    Path(__file__).parents[2] / "framework/worldkit-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "stable-compaction"
FIELDS = ['COUNT', 'REMOVED', 'VALID', 'F0', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'I0', 'I1', 'I2', 'I3', 'I4', 'I5', 'I6', 'I7']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
