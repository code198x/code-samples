"""Independent arithmetic/bounds model for camera-deadzone."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "playtools_models",
    Path(__file__).parents[2] / "framework/playtools-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "camera-deadzone"
FIELDS = [
    "CAMERA",
    "PLAYER",
    "LEFT_EDGE",
    "RIGHT_EDGE",
    "SCROLL_LIMIT",
    "SHIFTED",
    "VALID",
]


def packet(custom=False, wrong=False):
    return M.packet(TOPIC, custom, wrong)


def preview(custom=False, wrong=False):
    return M.preview(TOPIC, custom, wrong)


def cases(custom=False):
    return M.cases(TOPIC, custom)


def trace(custom=False):
    return M.trace(TOPIC, custom)
