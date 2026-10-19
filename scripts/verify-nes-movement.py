"""Execute byte-coordinate movement on NTSC NROM against saturating arithmetic."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "nintendo-entertainment-system/patterns/assembly/physics/sprite-movement-bounds/movement.inc"
)
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run(args: argparse.Namespace) -> dict:
    cases = 0
    records = []
    for mask in range(16):
        folder = args.output / f"buttons-{mask:02x}"
        folder.mkdir(parents=True, exist_ok=True)
        (folder / "movement.inc").write_text(SOURCE.read_text())
        code = (
            """.segment "HEADER"
.byte "NES",$1a,2,1,0,0,0,0,0,0,0,0,0,0
.segment "CODE"
reset:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta $2000
    sta $2001
    sta $4010
    sta $4015
    lda #$40
    sta $4017
    ldx #0
next_case:
    txa
    sta player_x
    lda starts_y,x
    sta player_y
    lda #MASK
    sta buttons
    jsr move_player
    lda player_x
    sta $0400,x
    lda player_y
    sta $0500,x
    inx
    cpx #249
    bne next_case
    lda #$ca
    sta $0600
hold: jmp hold
irq: rti
.include "movement.inc"
.segment "CODE"
starts_y: .byte """
            + ",".join(str(min(x, 224)) for x in range(249))
            + """
.segment "VECTORS"
.word irq,reset,irq
.segment "CHARS"
.res 8192,0
"""
        )
        (folder / "caller.asm").write_text(code.replace("MASK", str(mask)))
        r = subprocess.run(
            [args.assembler, "--dialect", "ca65", "caller.asm", "-o", "caller.nes"],
            cwd=folder,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
        T.require(r.returncode == 0, r.stderr or r.stdout)
        m = T.Machine(
            [
                args.emulator,
                "--mcp",
                "--rom",
                str(folder / "caller.nes"),
                "--region",
                "ntsc",
            ]
        )
        try:
            m.call("run_frames", frames=5)
            T.require(T.memory(m, 0x600) == 0xCA, "Movement caller did not finish")
            xs = m.call("memory_read", addr=0x400, len=249)["bytes"]
            ys = m.call("memory_read", addr=0x500, len=249)["bytes"]
        finally:
            m.close()
        expected = []
        for start in range(249):
            x, y = start, min(start, 224)
            if mask & 8:
                y = max(0, y - 2)
            if mask & 4:
                y = min(224, y + 2)
            if mask & 2:
                x = max(0, x - 2)
            if mask & 1:
                x = min(248, x + 2)
            expected.append((x, y))
        T.require(
            list(zip(xs, ys, strict=True)) == expected,
            f"Inclusive clamp mismatch for button mask {mask}",
        )
        records.append(
            {"buttons": mask, "binary_sha256": sha(folder / "caller.nes"), "cases": 249}
        )
        cases += 249
    return {
        "status": "passed",
        "cases": cases,
        "button_masks": 16,
        "source_sha256": sha(SOURCE),
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "records": records,
        "limits": "CPU/state checks on NTSC NROM; rendering disabled, no controller hardware input or original-hardware claim. Opposing directions follow the documented sequential order.",
    }


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--expect-rejection", action="store_true")
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").unlink(missing_ok=True)
    try:
        result = run(args)
    except AssertionError as error:
        if not args.expect_rejection:
            raise
        T.require(
            str(error).startswith("Inclusive clamp mismatch"),
            "Unrelated regression failure: " + str(error),
        )
        result = {
            "status": "regression-characterised",
            "failure": str(error),
            "source_sha256": sha(SOURCE),
            "observer_sha256": sha(Path(__file__)),
        }
    else:
        T.require(not args.expect_rejection, "Unfixed movement unexpectedly passed")
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
