"""Build firmware-hosted callers and printable keyboard loaders, without ROMs."""

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
    "no-drawing": {"DRAW": 0},
    "no-sound": {"SOUND": 0},
}


def build(
    system: str, assembler: Path, variant: str = "working"
) -> tuple[Path, bytes, list[str]]:
    folder = ROOT / system / "patterns/assembly/framework/command-loop"
    out = folder / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    source_file = {
        "step-three": "customise.asm",
        "wrong-reset": "mistakes/reset-each-command.asm",
    }.get(variant, "demo.asm")
    source = (folder / source_file).read_text()
    for name, value in (
        {} if variant in ("step-three", "wrong-reset") else VARIANTS[variant]
    ).items():
        old = (
            f"{name} equ "
            + {
                "INITIAL": "0",
                "STEP": "1",
                "RESET_EACH": "0",
                "DRAW": "1",
                "SOUND": "1",
            }[name]
        )
        if source.count(old) != 1:
            raise ValueError(f"Ambiguous configuration: {name}")
        source = source.replace(old, f"{name} equ {value}")
    (out / "demo.asm").write_text(source)
    binary = out / "demo.bin"
    binary.unlink(missing_ok=True)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "lwasm" if system == "dragon-32" else "pasmo",
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
    # Assembler diagnostics must not be mistaken for a successful output.
    data = binary.read_bytes()
    if not data or len(data) >= 512:
        raise ValueError("Missing or oversized caller")
    if system == "dragon-32":
        lines = [
            "CLEAR 200,&H6FFF",
            f"10 FOR I=0 TO {len(data) - 1}:READ A:POKE &H7000+I,A:NEXT",
            "20 END",
        ]
        lines += [
            f"{100 + i} DATA " + ",".join(map(str, data[i : i + 16]))
            for i in range(0, len(data), 16)
        ]
        lines += ["RUN"]
        launch = "CLS:EXEC &H7000"
        suffix = "bas"
    else:
        lines = [
            "DECIMAL",
            ": TURNS 15616 CALL ;",
            ": RESERVE HERE 15616 > IF ABORT THEN 15616 HERE - ALLOT ;",
            "RESERVE",
        ]
        lines += [
            " ".join(f"{v} C," for v in data[i : i + 12])
            for i in range(0, len(data), 12)
        ]
        launch = "CLS TURNS"
        suffix = "fth"
    (out / f"load.{suffix}").write_text("\n".join(lines + [launch]) + "\n")
    return out, data, lines


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--system", choices=["dragon-32", "jupiter-ace"], required=True)
    p.add_argument("--variant", choices=VARIANTS, default="working")
    a = p.parse_args()
    out, _, _ = build(a.system, a.assembler.resolve(), a.variant)
    print(out)


if __name__ == "__main__":
    main()
