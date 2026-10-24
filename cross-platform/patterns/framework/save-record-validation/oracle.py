"""Independent arithmetic/bounds model for save-record-validation."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nighttwo_models",
    Path(__file__).parents[2] / "framework/nighttwo-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "save-record-validation"
FIELDS = [
    "ACCEPTED",
    "VALID",
    "MODE",
    "L0",
    "L1",
    "L2",
    "L3",
    "C0",
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
]


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
