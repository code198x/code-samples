"""Independent outcomes for a saturating 16-bit score."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gameplay_models", Path(__file__).parents[1] / "gameplay-patterns/cases.py"
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "score-counter"
FIELDS = ["SCORE_LO", "SCORE_HI", "ADD_LO", "ADD_HI", "CLIPPED"]


def packet(custom=False, wrong=False):
    return M.packet(TOPIC, custom, wrong)


def preview(custom=False, wrong=False):
    return M.preview(TOPIC, custom, wrong)


def cases(custom=False):
    return M.cases(TOPIC, custom)


def trace(custom=False):
    return M.trace(TOPIC, custom)
