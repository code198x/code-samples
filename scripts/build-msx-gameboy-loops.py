"""Build the independent BIOS-facing MSX and DMG cartridge callers."""

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
    "no-wait": {"NO_WAIT": 1},
}


def build(
    system: str, assembler: Path, variant: str = "working"
) -> tuple[Path, bytes, list[str]]:
    gb = system == "nintendo-game-boy"
    folder = ROOT / system / "patterns/assembly/framework/command-loop"
    out = folder / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    file = {
        "step-three": "customise.asm",
        "wrong-reset": "mistakes/reset-each-command.asm",
    }.get(variant, "demo.asm")
    source = (folder / file).read_text()
    for name, value in (
        {} if variant in ("step-three", "wrong-reset") else VARIANTS[variant]
    ).items():
        old = f"{name} {'EQU' if gb else 'equ'} {1 if name == 'STEP' else 0}"
        if source.count(old) != 1:
            raise ValueError("Ambiguous variant setting")
        source = source.replace(old, f"{name} {'EQU' if gb else 'equ'} {value}")
    (out / "demo.asm").write_text(source)
    binary = out / ("demo.gb" if gb else "demo.bin")
    binary.unlink(missing_ok=True)
    command = [
        str(assembler),
        "--dialect",
        "rgbasm" if gb else "pasmo",
        "-I",
        str(folder),
        "--sym",
    ]
    if gb:
        command += ["--gb-rom"]
    subprocess.run(
        command + [str(out / "demo.asm"), "-o", str(binary)], check=True, timeout=30
    )
    data = binary.read_bytes()
    if not data or (gb and len(data) != 32768) or (not gb and len(data) > 512):
        raise ValueError("Missing/invalid caller payload")
    lines = []
    if not gb:
        lines = [
            "CLEAR 200,49151",
            f"10 FOR I=0 TO {len(data) - 1}:READ A:POKE 49152+I,A:NEXT I",
            "20 DEF USR=49152",
            "30 END",
        ]
        lines += [
            f"{100 + i} DATA " + ",".join(map(str, data[i : i + 12]))
            for i in range(0, len(data), 12)
        ]
        lines += ["RUN"]
        (out / "load.bas").write_text(
            "\n".join(lines + ["SCREEN 0:WIDTH 40:CLS:A=USR(0)"]) + "\n"
        )
    return out, data, lines


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--system", choices=["msx", "nintendo-game-boy"], required=True)
    p.add_argument("--variant", choices=VARIANTS, default="working")
    a = p.parse_args()
    print(build(a.system, a.assembler.resolve(), a.variant)[0])


if __name__ == "__main__":
    main()
