"""Build the two machine-specific Z80 callers and their stock BASIC loaders."""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VARIANTS = {
    "working": {},
    "step-three": {"STEP": 3},
    "wrong-reset": {"RESET_EACH": 1},
    "repaired": {},
    "wrap": {"INITIAL": 254},
    "nonzero": {"INITIAL": 100, "STEP": 255},
    "no-edge": {"NO_EDGE": 1},
}


def build(
    system: str, assembler: Path, variant: str = "working"
) -> tuple[Path, bytes, list[str]]:
    folder = ROOT / system / "patterns/assembly/framework/command-loop"
    out = folder / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    filename = {
        "step-three": "customise.asm",
        "wrong-reset": "mistakes/reset-each-command.asm",
    }.get(variant, "demo.asm")
    source = (folder / filename).read_text()
    for name, value in (
        {} if variant in ("step-three", "wrong-reset") else VARIANTS[variant]
    ).items():
        old = f"{name} equ " + ("1" if name == "STEP" else "0")
        if source.count(old) != 1:
            raise ValueError("Ambiguous setting")
        source = source.replace(old, f"{name} equ {value}")
    (out / "demo.asm").write_text(source)
    binary = out / "demo.bin"
    binary.unlink(missing_ok=True)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "pasmo",
            "-I",
            str(folder),
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(binary),
        ],
        check=True,
        timeout=30,
    )
    data = binary.read_bytes()
    if not data or len(data) > 256:
        raise ValueError("Missing/oversized caller")
    if system == "mattel-aquarius":
        lines = [
            "CLEAR 50,15871",
            f"10 FOR I=0 TO {len(data) - 1}:READ A:POKE 15872+I,A:NEXT",
            "20 POKE 14340,0:POKE 14341,62",
            "30 END",
        ]
        launch = "PRINT CHR$(11):X=USR(0)"
    else:
        lines = [
            f"10 FOR A=57344 TO {57343 + len(data)}",
            "20 READ B:POKE A,B:NEXT A",
            "30 STOP",
        ]
        launch = "LET X=USR(57344)"
    lines += [
        f"{100 + i} DATA " + ",".join(map(str, data[i : i + 12]))
        for i in range(0, len(data), 12)
    ]
    lines += ["RUN"]
    (out / "load.bas").write_text("\n".join(lines + [launch]) + "\n")
    return out, data, lines


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument(
        "--system", choices=["mattel-aquarius", "memotech-mtx"], required=True
    )
    p.add_argument("--variant", choices=VARIANTS, default="working")
    a = p.parse_args()
    print(build(a.system, a.assembler.resolve(), a.variant)[0])


if __name__ == "__main__":
    main()
