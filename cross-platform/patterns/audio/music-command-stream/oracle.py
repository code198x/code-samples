"""Independent arithmetic/bounds model for music-command-stream."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nighttwo_models",
    Path(__file__).parents[2] / "framework/nighttwo-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "music-command-stream"
FIELDS = [
    "NOTE",
    "EVENT",
    "FINISHED",
    "VALID",
    "INDEX",
    "REMAINING",
    "COUNT",
    "N0",
    "N1",
    "N2",
    "N3",
    "N4",
    "N5",
    "N6",
    "N7",
    "U0",
    "U1",
    "U2",
    "U3",
    "U4",
    "U5",
    "U6",
    "U7",
]


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
