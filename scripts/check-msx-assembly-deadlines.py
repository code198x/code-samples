"""Check native MSX assembly deadline evidence with the shared retained gate."""

from __future__ import annotations

import importlib.util
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "C", Path(__file__).with_name("check-dragon-assembly-deadlines.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
if __name__ == "__main__":
    C.check("msx")
    print("MSX BIOS deadlines and native controls passed")
