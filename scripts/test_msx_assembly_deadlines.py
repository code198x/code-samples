"""Require the MSX route to reject the ten shared native-evidence corruptions."""

from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "C", Path(__file__).with_name("test_dragon_assembly_deadlines.py")
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class Evidence(unittest.TestCase):
    def test_msx(self):
        C.exercise(self, "msx")


if __name__ == "__main__":
    unittest.main()
