"""Execute the baseline, movement matrix and actual control-port demo.

The matrix injects direction masks into the arithmetic routine. The separate
interactive run uses Emu198x buttons or VICE's simulated joyport pins.
"""

from __future__ import annotations

import argparse
import importlib.util
import itertools
import json
import shutil
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT.parents[1] / "rendering/hardware-sprites"
HELPER = SHARED.parent / "sprite-multiplexing/verification/verify.py"
SPEC = importlib.util.spec_from_file_location("sprite_pixels", HELPER)
assert SPEC is not None and SPEC.loader is not None
PNG = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PNG)
require, sha = PNG.require, PNG.sha
Case = tuple[int, int, int, int]


def expected(x: int, y: int, mask: int, frames: int = 1) -> tuple[int, int]:
    dx = int(bool(mask & 8)) - int(bool(mask & 4))
    dy = int(bool(mask & 2)) - int(bool(mask & 1))
    return max(24, min(320, x + 2 * dx * frames)), max(
        50, min(229, y + 2 * dy * frames)
    )


def build(
    args: argparse.Namespace, dest: Path, source: str
) -> tuple[Path, dict[str, int]]:
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "demo.asm").write_text(source)
    prg = dest / "demo.prg"
    subprocess.run(
        [
            args.assembler,
            "--dialect",
            "acme",
            "--prg",
            "demo.asm",
            f"--sym={dest / 'demo.sym'}",
            "-o",
            str(prg),
        ],
        cwd=dest,
        check=True,
        capture_output=True,
    )
    subprocess.run(
        [args.acme, "-f", "cbm", "-o", str(dest / "acme.prg"), "demo.asm"],
        cwd=dest,
        check=True,
        capture_output=True,
    )
    require(prg.read_bytes() == (dest / "acme.prg").read_bytes(), "assemblers disagree")
    symbols = {
        key: int(value, 16)
        for key, value in (
            line.split(" = $") for line in (dest / "demo.sym").read_text().splitlines()
        )
    }
    return prg, symbols


def keys_run() -> list[dict[str, Any]]:
    script = []
    for key in ("R", "U", "N", "RETURN"):
        for pressed, frames in ((True, 4), (False, 3)):
            script += [
                {
                    "action": "input",
                    "events": [{"Key": {"name": key, "pressed": pressed}}],
                },
                {"action": "run_frames", "frames": frames},
            ]
    return script


def emu(
    args: argparse.Namespace,
    dest: Path,
    prg: Path,
    model: str,
    script: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    path = dest / f"emu-{model}.json"
    path.write_text(json.dumps(keys_run() + script, indent=2) + "\n")
    result = subprocess.run(
        [args.emulator, "--model", model, "--load", str(prg), "--script", str(path)],
        capture_output=True,
        text=True,
        check=True,
        timeout=120,
    )
    (dest / f"emu-{model}-report.json").write_text(result.stdout)
    observations = json.loads(result.stdout)["observations"]
    require(
        all(row["reached"] for row in observations if row["kind"] == "run_until_pc"),
        "guest did not reach the requested observation point",
    )
    return observations


def vice(
    args: argparse.Namespace,
    dest: Path,
    model: str,
    commands: list[str],
    joystick: bool = False,
) -> None:
    path = dest / f"vice-{model}.mon"
    path.write_text("\n".join(commands + ["quit", ""]))
    command = [
        args.vice,
        "-console",
        "-default",
        "-model",
        "c64" if model == "pal" else "ntsc",
        "-warp",
        "+sound",
        "-logfile",
        str(dest / f"vice-{model}.log"),
        "-monlog",
        "-monlogname",
        str(dest / f"vice-{model}-monitor.log"),
        "-limitcycles",
        "16000000",
        "-initbreak",
        "ready",
        "-moncommands",
        str(path),
    ]
    if joystick:
        command += ["-controlport2device", "io"]
    result = subprocess.run(
        command, cwd=dest, capture_output=True, text=True, timeout=120, check=False
    )
    require(result.returncode == 0, f"VICE exit {result.returncode}: {result.stderr}")


def matrix_program(
    args: argparse.Namespace,
    dest: Path,
    cases: list[Case],
    baseline: bool = False,
    broken: bool = False,
) -> tuple[Path, dict[str, int]]:
    dest.mkdir(parents=True, exist_ok=True)
    data = bytes(
        value
        for x, y, mask, seed in cases
        for value in (x & 255, x >> 8, y, mask, seed)
    )
    (dest / "cases.bin").write_bytes(data)
    if baseline:
        code = (
            (ROOT / "verification/baseline.inc")
            .read_text()
            .replace("JOY2        = $DC00", "JOY2        = $06")
        )
    else:
        code = (ROOT / "movement.inc").read_text()
        if broken:
            code = code.replace(
                "    lda #MIN_Y\n    jmp store_y", "    jmp move_horizontal"
            )
    (dest / "movement.inc").write_text(code)
    source = """* = $0801
!byte $0b,$08,$0a,0,$9e
!text "2064"
!byte 0,0,0
* = $0810
start:
 sei
 lda #$35
 sta $01
 lda #<inputs
 sta $02
 lda #>inputs
 sta $03
 lda #0
 sta $04
 lda #$60
 sta $05
 lda #<COUNT
 sta $08
 lda #>COUNT
 sta $09
case_loop:
 ldy #0
 lda ($02),y
 sta sprite_x_lo
 iny
 lda ($02),y
 sta sprite_x_hi
 iny
 lda ($02),y
 sta sprite_y
 iny
 lda ($02),y
 MASK_INVERT
 sta $06
 iny
 lda ($02),y
 sta $d010
 lda $06
 jsr move_sprite
 ldy #0
 lda sprite_x_lo
 sta ($04),y
 iny
 lda sprite_x_hi
 sta ($04),y
 iny
 lda sprite_y
 sta ($04),y
 iny
 lda $d000
 sta ($04),y
 iny
 lda $d001
 sta ($04),y
 iny
 lda $d010
 sta ($04),y
 clc
 lda $02
 adc #5
 sta $02
 bcc next_output
 inc $03
next_output:
 clc
 lda $04
 adc #6
 sta $04
 bcc count_down
 inc $05
count_down:
 lda $08
 bne low_count
 dec $09
low_count:
 dec $08
 lda $08
 ora $09
 beq done
 jmp case_loop
done:
 jmp done
!source "movement.inc"
* = $3000
inputs:
!bin "cases.bin"
""".replace("COUNT", str(len(cases))).replace(
        "MASK_INVERT", "eor #$ff" if baseline else ""
    )
    return build(args, dest, source)


def run_matrix(
    args: argparse.Namespace,
    dest: Path,
    cases: list[Case],
    baseline: bool = False,
    broken: bool = False,
) -> list[dict[str, Any]]:
    prg, sym = matrix_program(args, dest, cases, baseline, broken)
    rows = []
    for model in ("pal", "ntsc"):
        for engine in ("emu", "vice"):
            if engine == "emu":
                obs = emu(
                    args,
                    dest,
                    prg,
                    model,
                    [
                        {
                            "action": "run_until_pc",
                            "addr": sym["done"],
                            "max_steps": 2000000,
                        },
                    ]
                    + [
                        {
                            "action": "memory_read",
                            "addr": 0x6000 + offset,
                            "len": min(256, len(cases) * 6 - offset),
                        }
                        for offset in range(0, len(cases) * 6, 256)
                    ],
                )
                reads = [row for row in obs if row["kind"] == "memory_read"]
                require(
                    [r["addr"] for r in reads]
                    == list(range(0x6000, 0x6000 + len(cases) * 6, 256)),
                    "missing or reordered matrix chunks",
                )
                data = bytes(value for row in reads for value in row["bytes"])
            else:
                dump = dest / f"vice-{model}.bin"
                vice(
                    args,
                    dest,
                    model,
                    [
                        f'load "{prg}" 0',
                        f"break exec ${sym['done']:04x}",
                        "g $0810",
                        f'bsave "{dump}" 0 $6000 ${0x6000 + len(cases) * 6 - 1:04x}',
                    ],
                )
                data = dump.read_bytes()
            require(len(data) == len(cases) * 6, "missing matrix observations")
            mismatches = []
            for i, (x, y, mask, seed) in enumerate(cases):
                nx, ny = expected(x, y, mask)
                wanted = [nx & 255, nx >> 8, ny, nx & 255, ny, seed | (nx >> 8)]
                actual = list(data[i * 6 : i * 6 + 6])
                if actual != wanted:
                    mismatches.append(
                        {
                            "input": [x, y, mask, seed],
                            "expected": wanted,
                            "actual": actual,
                        }
                    )
            if baseline or broken:
                require(bool(mismatches), "observer accepted a broken clamp")
            else:
                require(not mismatches, f"{engine} {model}: {mismatches[:3]}")
            rows.append(
                {
                    "engine": engine,
                    "model": model,
                    "cases": len(cases),
                    "prg_sha256": sha(prg),
                    "mismatches": mismatches,
                }
            )
            print(
                "REJECTED" if baseline or broken else "PASS",
                "matrix",
                engine,
                model,
                len(cases),
                "cases,",
                len(mismatches),
                "mismatches",
                flush=True,
            )
    return rows


def picture(path: Path, x: int, y: int, engine: str, model: str) -> dict[str, Any]:
    width, height, pixels = PNG.pixels(path)
    ox, oy = (24, 1) if engine == "emu" else (8, -15 if model == "pal" else -27)
    wanted = {
        (x + ox + dx, y + oy + dy)
        for dy in range(21)
        for dx in range(24)
        if dy in (0, 10, 20) or dx in (0, 11, 12, 23)
    }
    require(
        pixels.keys() == wanted,
        f"wrong picture {path.name}: missing {len(wanted - pixels.keys())}, extra {len(pixels.keys() - wanted)}",
    )
    require(set(pixels.values()) == {b"\xff\xff\xff"}, "wrong sprite colour")
    return {
        "dimensions": [width, height],
        "lit_pixels": len(pixels),
        "sha256": sha(path),
    }


# A sequence, not isolated resets: held input, release, both byte transitions,
# both corners, diagonals, opposite pairs, all directions and ignored fire.
STAGES = [
    (0, 3),
    (8, 60),
    (0, 4),
    (4, 20),
    (2, 80),
    (8, 60),
    (5, 170),
    (3, 4),
    (12, 4),
    (15, 4),
    (16, 4),
    (10, 3),
]


def live_demo(
    args: argparse.Namespace, dest: Path
) -> tuple[list[dict[str, Any]], dict[str, int]]:
    source = (
        (ROOT / "demo.asm")
        .read_text()
        .replace('!source "movement.inc"', f'!source "{ROOT / "movement.inc"}"')
    )
    for name in ("sprite.inc", "shape.inc"):
        source = source.replace(
            f'!source "../../rendering/hardware-sprites/{name}"',
            f'!source "{SHARED / name}"',
        )
    prg, sym = build(args, dest, source)
    rows = []
    # Five bytes: guest x low/high, y, sampled direction bits, frame count.
    for model in ("pal", "ntsc"):
        for engine in ("emu", "vice"):
            results = []
            if engine == "emu":
                script = [
                    {"action": "run_until_pc", "addr": sym["picture_ready"]},
                    {"action": "memory_read", "addr": sym["frames"], "len": 1},
                ]
                for index, (mask, frames) in enumerate(STAGES):
                    events = [
                        {
                            "Button": {
                                "port": 2,
                                "name": name,
                                "pressed": bool(mask & (1 << bit)),
                            }
                        }
                        for bit, name in enumerate(
                            ("up", "down", "left", "right", "fire")
                        )
                    ]
                    script += [
                        {"action": "input", "events": events},
                        {"action": "run_frames", "frames": frames},
                        {"action": "run_until_pc", "addr": sym["picture_ready"]},
                        {"action": "memory_read", "addr": sym["sprite_x_lo"], "len": 4},
                        {"action": "memory_read", "addr": sym["frames"], "len": 48},
                        {
                            "action": "input",
                            "events": [
                                {"Button": {"port": 2, "name": name, "pressed": False}}
                                for name in ("up", "down", "left", "right", "fire")
                            ],
                        },
                        {"action": "run_frames", "frames": 1},
                        {"action": "run_until_pc", "addr": sym["picture_ready"]},
                        {
                            "action": "save_screenshot",
                            "path": str(dest / f"emu-{model}-{index}.png"),
                        },
                    ]
                obs = emu(args, dest, prg, model, script)
                reads = [r["bytes"] for r in obs if r["kind"] == "memory_read"]
                previous = reads[0][0]
                require(len(reads) == 1 + len(STAGES) * 2, "missing live observations")
                results = [
                    (reads[1 + 2 * i], reads[2 + 2 * i]) for i in range(len(STAGES))
                ]
            else:
                # VICE jpdb numbers ports from zero; port 1 here is case-labelled port 2.
                commands = [
                    f'load "{prg}" 0',
                    "jpdb 1 $1f",
                    f"break exec ${sym['picture_ready']:04x} if @ram:${sym['frames']:04x} == $02",
                    "g $0810",
                    "delete 1",
                ]
                previous = 2
                target = previous
                for index, (mask, frames) in enumerate(STAGES):
                    target = (target + frames) & 255
                    commands += [
                        f"jpdb 1 ${(mask ^ 31):02x}",
                        f"break exec ${sym['picture_ready']:04x} if @ram:${sym['frames']:04x} == ${target:02x}",
                        "x",
                        "delete 1",
                        f'bsave "{dest / f"vice-{model}-{index}-state.bin"}" 0 ${sym["sprite_x_lo"]:04x} ${sym["sprite_x_lo"] + 3:04x}',
                        f'bsave "{dest / f"vice-{model}-{index}-regs.bin"}" 0 ${sym["frames"]:04x} ${sym["frames"] + 47:04x}',
                        "jpdb 1 $1f",
                        f"break exec ${sym['picture_ready']:04x} if @ram:${sym['frames']:04x} == ${(target + 1) & 255:02x}",
                        "x",
                        "delete 1",
                        f'screenshot "{dest / f"vice-{model}-{index}.png"}" 2',
                    ]
                    target = (target + 1) & 255
                vice(args, dest, model, commands, joystick=True)
                results = [
                    (
                        list((dest / f"vice-{model}-{i}-state.bin").read_bytes()),
                        list((dest / f"vice-{model}-{i}-regs.bin").read_bytes()),
                    )
                    for i in range(len(STAGES))
                ]
            x, y = 160, 140
            for index, ((mask, frames), (state, regs)) in enumerate(
                zip(STAGES, results, strict=True)
            ):
                delta = (regs[0] - previous) & 255
                require(
                    delta == frames,
                    f"{engine} {model} stage {index}: {delta} updates, expected {frames}",
                )
                previous = (
                    regs[0] + 1
                ) & 255  # released settling frame before the next stage
                x, y = expected(x, y, mask, frames)
                require(
                    state == [x & 255, x >> 8, y, mask & 15],
                    f"{engine} {model} stage {index}: state {state}, wanted {[x & 255, x >> 8, y, mask & 15]}",
                )
                require(
                    [regs[1], regs[2], regs[17]] == [x & 255, y, x >> 8],
                    "VIC position differs from state",
                )
                require(
                    all(regs[offset + 1] == 0 for offset in (0x17, 0x1B, 0x1C, 0x1D)),
                    "sprite modes changed",
                )
                require(regs[0x16] == 1, "sprite enable changed")
                shot = dest / f"{engine}-{model}-{index}.png"
                rows.append(
                    {
                        "engine": engine,
                        "model": model,
                        "stage": index,
                        "mask": mask,
                        "updates": delta,
                        "released_capture_frames": 1,
                        "position": [x, y],
                        "picture": picture(shot, x, y, engine, model),
                    }
                )
                print("PASS live", engine, model, index, mask, frames, x, y, flush=True)
    return rows, {
        "movement_bytes": sym["movement_end"] - sym["move_sprite"],
        "state_bytes": 4,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    for name, default in (
        ("assembler", "asm198x"),
        ("acme", "acme"),
        ("emulator", "emu198x-c64"),
        ("vice", "x64sc"),
    ):
        parser.add_argument(f"--{name}", default=default)
    parser.add_argument("--output", type=Path, default=ROOT / "build/verification")
    args = parser.parse_args()
    args.output = args.output.resolve()
    for name in ("assembler", "acme", "emulator", "vice"):
        value = shutil.which(getattr(args, name))
        require(value is not None, f"missing {name}")
        setattr(args, name, value)
    baseline = run_matrix(
        args,
        args.output / "baseline",
        [(160, 51, 1, 0), (160, 228, 2, 0)],
        baseline=True,
    )
    cases = [
        (x, y, mask, 0xAA if index % 2 else 0x54)
        for index, (x, y, mask) in enumerate(
            itertools.product(
                (24, 25, 254, 255, 256, 257, 319, 320),
                (50, 51, 52, 227, 228, 229),
                range(32),
            )
        )
    ]
    matrix = run_matrix(args, args.output / "matrix", cases)
    negative = run_matrix(
        args, args.output / "negative", [(160, 51, 1, 0)], broken=True
    )
    live, sizes = live_demo(args, args.output / "live")
    result = {
        "sources": {
            name: sha(ROOT / name)
            for name in (
                "demo.asm",
                "movement.inc",
                "verification/verify.py",
                "verification/baseline.inc",
            )
        },
        "shared_sources": {
            str(p.relative_to(ROOT.parents[4])): sha(p)
            for p in (SHARED / "sprite.inc", SHARED / "shape.inc", HELPER)
        },
        "tools": {
            name: {"sha256": sha(Path(getattr(args, name)))}
            for name in ("assembler", "acme", "emulator", "vice")
        },
        "baseline": baseline,
        "matrix": matrix,
        "negative_control": negative,
        "live": live,
        "sizes": sizes,
    }
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(
        "PASS: baseline and mutation rejected; 6144 matrix rows and 48 live captures",
        flush=True,
    )


if __name__ == "__main__":
    main()
