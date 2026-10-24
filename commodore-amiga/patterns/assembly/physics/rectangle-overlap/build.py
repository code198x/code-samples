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
cases = C.cases(65535)
(B / "cases.inc").write_text("CASE_COUNT equ " + str(len(cases)) + "\n")
(B / "case-table.inc").write_text(
    "case_table:\n"
    + "".join("    dc.w " + ",".join(map(str, c["a"] + c["b"])) + "\n" for c in cases)
)
for n in ("demo", "custom", "wrong", "repaired"):
    subprocess.run(
        [
            os.environ.get("ASM198X", "asm198x"),
            "--dialect",
            "vasm",
            "--exe",
            "-I",
            str(B),
            "-I",
            str(F),
            "--sym=" + str(B / (n + ".sym")),
            str(F / (n + ".asm")),
            "-o",
            str(B / n),
        ],
        check=True,
    )
    subprocess.run(
        [
            os.environ.get("BUILD198X", "build198x"),
            "adf",
            str(B / n),
            "-o",
            str(B / (n + ".adf")),
            "--name",
            n,
            "--volume",
            "Rectangles",
        ],
        check=True,
    )
