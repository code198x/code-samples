"""Independent BASIC attack-hit-window outcomes."""

from __future__ import annotations

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "basic_platform_models",
    Path(__file__).parents[2] / "framework/basic-combat-focus-models/cases.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
TOPIC = "attack-hit-window"
CATEGORY = M.CATEGORIES[TOPIC]
LABEL = M.LABELS[TOPIC]
FIELDS = M.FIELDS[TOPIC]


def packet(variant: str) -> list[int]:
    return M.packet(TOPIC, variant)
