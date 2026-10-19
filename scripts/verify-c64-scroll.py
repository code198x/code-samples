"""Run eight fine steps and one complete character/colour scroll on PAL C64."""

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "commodore-64/patterns/assembly/rendering/smooth-scrolling/scroll.inc"


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run(args: argparse.Namespace) -> dict:
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    source = SOURCE.read_text()
    (out / "scroll.inc").write_text(source)
    caller = """*=$0801
    !byte $0b,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00
start:
    sei
    cld
    lda #$35
    sta $01
    lda #$18
    sta $d016
"""
    for n in range(1000):
        caller += f"    lda #{n % 256}\n    sta ${0x400 + n:04x}\n    lda #{n % 16}\n    sta ${0xD800 + n:04x}\n"
    caller += """    ldx #0
prepare_column:
    txa
    clc
    adc #160
    sta next_column,x
    txa
    and #15
    sta next_colour,x
    inx
    cpx #25
    bne prepare_column
    jsr init_scroll
    lda $d016
    and #$1f
    sta $c000
    ldy #0
next_step:
    jsr scroll_left
    lda $d016
    and #$1f
    sta $c001,y
    iny
    cpy #8
    bne next_step
    ldx #0
read_colours:
    lda $d800,x
    sta $c100,x
    lda $d900,x
    sta $c200,x
    lda $da00,x
    sta $c300,x
    lda $db00,x
    sta $c400,x
    inx
    bne read_colours
    lda #$ca
    sta $c010
hold: jmp hold
    !source "scroll.inc"
"""
    if "next_column:" not in source:
        caller += "next_column: !fill 25,32\nnext_colour: !fill 25,1\n"
    (out / "caller.asm").write_text(caller)
    result = subprocess.run(
        [
            args.assembler,
            "--dialect",
            "acme",
            "--prg",
            "caller.asm",
            "-o",
            "caller.prg",
        ],
        cwd=out,
        capture_output=True,
        text=True,
        timeout=40,
        check=False,
    )
    if result.returncode:
        raise ValueError(result.stderr or result.stdout)
    steps = []
    for key in ["R", "U", "N", "RETURN"]:
        for pressed, frames in [(True, 4), (False, 3)]:
            steps += [
                {
                    "action": "input",
                    "events": [{"Key": {"name": key, "pressed": pressed}}],
                },
                {"action": "run_frames", "frames": frames},
            ]
    steps += [
        {"action": "run_frames", "frames": 30},
        {"action": "memory_read", "addr": 0xC010, "len": 1},
        {"action": "memory_read", "addr": 0xC000, "len": 9},
    ]
    for start in [0x400, 0xC100]:
        for offset in range(0, 1000, 256):
            steps.append(
                {
                    "action": "memory_read",
                    "addr": start + offset,
                    "len": min(256, 1000 - offset),
                }
            )
    (out / "script.json").write_text(json.dumps(steps))
    result = subprocess.run(
        [
            args.emulator,
            "--model",
            "pal",
            "--load",
            str(out / "caller.prg"),
            "--script",
            str(out / "script.json"),
        ],
        cwd=out,
        capture_output=True,
        text=True,
        timeout=50,
        check=False,
    )
    if result.returncode:
        raise ValueError(result.stderr or result.stdout)
    report = json.loads(result.stdout)
    (out / "observations.json").write_text(json.dumps(report, indent=2) + "\n")
    memory = [o["bytes"] for o in report["observations"] if o["kind"] == "memory_read"]
    if memory[0] != [0xCA]:
        raise ValueError("Scroll caller did not finish")
    if memory[1] != [0x17, 0x16, 0x15, 0x14, 0x13, 0x12, 0x11, 0x10, 0x17]:
        raise ValueError("Fine-scroll initialisation or eight-step sequence mismatch")
    screen = [v for b in memory[2:6] for v in b]
    colours = [v & 15 for b in memory[6:10] for v in b]
    expected_screen = []
    expected_colours = []
    for row in range(25):
        expected_screen.extend(
            [(row * 40 + col + 1) % 256 for col in range(39)] + [160 + row]
        )
        expected_colours.extend(
            [(row * 40 + col + 1) % 16 for col in range(39)] + [row % 16]
        )
    if screen != expected_screen or colours != expected_colours:
        raise ValueError("Coarse-scroll character/colour footprint mismatch")
    return {
        "status": "passed",
        "rows": 25,
        "columns_per_row": 40,
        "fine_steps": 8,
        "source_sha256": sha(SOURCE),
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "binary_sha256": sha(out / "caller.prg"),
        "limits": "PAL C64 ROM-boot/PRG import with typed RUN. CPU and memory/register effects only; no tear-free display or timing-budget qualification.",
    }


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--output", type=Path, required=True)
    p.add_argument("--expect-rejection", action="store_true")
    args = p.parse_args()
    args.output = args.output.resolve()
    try:
        result = run(args)
    except ValueError as error:
        if not args.expect_rejection:
            raise
        if not str(error).startswith(("Fine-scroll", "Coarse-scroll")):
            raise ValueError("Unrelated regression failure: " + str(error)) from error
        result = {
            "status": "regression-characterised",
            "failure": str(error),
            "source_sha256": sha(SOURCE),
            "observer_sha256": sha(Path(__file__)),
        }
    else:
        if args.expect_rejection:
            raise ValueError("Unfixed scroll unexpectedly passed")
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
