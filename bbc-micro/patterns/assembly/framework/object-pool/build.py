"""Build this maintained machine-specific pool example."""

import importlib.util
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "build_pool",
    Path(__file__).resolve().parents[5]
    / "cross-platform/patterns/framework/additional-object-pools/build.py",
)
M = importlib.util.module_from_spec(s)
s.loader.exec_module(M)
if __name__ == "__main__":
    M.main(Path(__file__).resolve().parent)
