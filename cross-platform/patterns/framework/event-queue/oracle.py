"""Independent outcomes for a bounded event queue."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "gameplay_models", Path(__file__).parents[1] / "gameplay-patterns/cases.py"
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "event-queue"
FIELDS = ["HEAD", "TAIL", "COUNT", "VALUE", "MODE", "OK", "B0", "B1", "B2", "B3"]


def packet(custom=False, wrong=False):
    return M.packet(TOPIC, custom, wrong)


def preview(custom=False, wrong=False):
    return M.preview(TOPIC, custom, wrong)


def cases(custom=False):
    return M.cases(TOPIC, custom)


def trace(custom=False):
    return M.trace(TOPIC, custom)
