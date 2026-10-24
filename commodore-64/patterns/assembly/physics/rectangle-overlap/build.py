import importlib.util
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
spec = importlib.util.spec_from_file_location(
    "cases", ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py"
)
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
F = Path(__file__).parent
B = F / "build"
B.mkdir(exist_ok=True)
cases = C.cases()
(B / "cases.inc").write_text("CASE_COUNT = " + str(len(cases)) + "\n")
(B / "case-table.inc").write_text(
    "case_table:\n"
    + "".join("    !byte " + ",".join(map(str, c["a"] + c["b"])) + "\n" for c in cases)
)
for name in ("demo", "custom", "wrong", "repaired"):
    subprocess.run(
        [
            os.environ.get("ASM198X", "asm198x"),
            "--dialect",
            "acme",
            "--prg",
            "-I",
            str(B),
            "-I",
            str(F),
            "--sym",
            str(F / (name + ".asm")),
            "-o",
            str(B / (name + ".prg")),
        ],
        check=True,
    )
