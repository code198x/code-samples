"""Independent arithmetic/bounds model for object-command-buffer."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nighttwo_models",
    Path(__file__).parents[2] / "framework/nighttwo-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "object-command-buffer"
FIELDS = [
    "APPLIED",
    "REJECTED",
    "FULL",
    "VALID",
    "MODE",
    "SLOT",
    "GENERATION",
    "ACTIVE",
    "COUNT",
    "G0",
    "G1",
    "G2",
    "G3",
    "O0",
    "O1",
    "O2",
    "O3",
    "S0",
    "S1",
    "S2",
    "S3",
    "H0",
    "H1",
    "H2",
    "H3",
]


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
