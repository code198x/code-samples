"""Independent arithmetic/bounds model for spatial-bucket."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "nightone_models",
    Path(__file__).parents[2] / "framework/nightone-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "spatial-bucket"
FIELDS = ['BUCKET', 'COUNT', 'INSERTED', 'FULL', 'VALID', 'MODE', 'INPUT_X', 'INPUT_Y', 'ITEM', 'C0', 'C1', 'C2', 'C3', 'S0', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', 'S11', 'S12', 'S13', 'S14', 'S15']


def packet(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.packet(TOPIC, custom, wrong)


def preview(custom: bool = False, wrong: bool = False) -> list[int]:
    return M.preview(TOPIC, custom, wrong)


def cases(custom: bool = False) -> list[list[int]]:
    return M.cases(TOPIC, custom)


def trace(custom: bool = False) -> list[dict[str, int]]:
    return M.trace(TOPIC, custom)
