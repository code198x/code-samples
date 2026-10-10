"""Build with Asm198x/ACME; inspect every lit pixel and guest register snapshot.

Reuses the adjacent multiplexer verifier's dependency-free PNG reader.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT.parent / "sprite-multiplexing/verification/verify.py"
SPEC = importlib.util.spec_from_file_location("sprite_pixels", HELPER)
assert SPEC is not None and SPEC.loader is not None
PNG = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PNG)
require, sha = PNG.require, PNG.sha


def assemble(
    args: argparse.Namespace, dest: Path, x: int, seed: int, broken: bool = False
) -> tuple[Path, dict[str, int]]:
    dest.mkdir(parents=True, exist_ok=True)
    source = (ROOT / "demo.asm").read_text().replace("DEMO_X = 160", f"DEMO_X = {x}")
    source = source.replace("SHARED_SEED = 0", f"SHARED_SEED = {seed}")
    (dest / "demo.asm").write_text(source)
    for name in ("sprite.inc", "shape.inc"):
        source = (ROOT / name).read_text()
        if broken and name == "sprite.inc":
            source = source.replace("    ora #1\nx_ready:", "    nop\nx_ready:")
        (dest / name).write_text(source)
    prg = dest / "demo.prg"
    subprocess.run(
        [
            args.assembler,
            "--dialect",
            "acme",
            "--prg",
            f"--sym={dest / 'demo.sym'}",
            "demo.asm",
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


def run_emu(
    args: argparse.Namespace, dest: Path, prg: Path, symbols: dict[str, int], model: str
) -> tuple[Path, list[int]]:
    script: list[dict[str, Any]] = []
    for key in ("R", "U", "N", "RETURN"):
        for pressed, frames in ((True, 4), (False, 3)):
            script += [
                {
                    "action": "input",
                    "events": [{"Key": {"name": key, "pressed": pressed}}],
                },
                {"action": "run_frames", "frames": frames},
            ]
    shot = dest / f"emu-{model}.png"
    script += [
        {"action": "run_frames", "frames": 25},
        {"action": "memory_read", "addr": symbols["frames"], "len": 49},
        {"action": "save_screenshot", "path": str(shot)},
    ]
    path = dest / f"emu-{model}.json"
    path.write_text(json.dumps(script, indent=2) + "\n")
    result = subprocess.run(
        [args.emulator, "--model", model, "--load", str(prg), "--script", str(path)],
        capture_output=True,
        text=True,
        check=True,
        timeout=90,
    )
    (dest / f"emu-{model}-report.json").write_text(result.stdout)
    reads = [
        row["bytes"]
        for row in json.loads(result.stdout)["observations"]
        if row["kind"] == "memory_read"
    ]
    require(len(reads) == 1, "missing guest observations")
    return shot, reads[0]


def run_vice(
    args: argparse.Namespace, dest: Path, prg: Path, symbols: dict[str, int], model: str
) -> tuple[Path, list[int]]:
    shot, dump = dest / f"vice-{model}.png", dest / f"vice-{model}.bin"
    monitor = dest / f"vice-{model}.mon"
    monitor.write_text(
        "\n".join(
            [
                f'load "{prg}" 0',
                f"break exec $0800 $1fff if (@ram:${symbols['frames']:04x} == $19) && (RL == $fa)",
                "g $0810",
                f'screenshot "{shot}" 2',
                f'bsave "{dump}" 0 ${symbols["frames"]:04x} ${symbols["frames"] + 48:04x}',
                "quit",
                "",
            ]
        )
    )
    result = subprocess.run(
        [
            args.vice,
            "-console",
            "-default",
            "-model",
            "c64" if model == "pal" else "ntsc",
            "-warp",
            "+sound",
            "-logfile",
            str(dest / f"vice-{model}.log"),
            "-limitcycles",
            "4000000",
            "-initbreak",
            "ready",
            "-moncommands",
            str(monitor),
        ],
        capture_output=True,
        text=True,
        timeout=60,
        check=False,
    )
    require(result.returncode == 0, f"VICE exit {result.returncode}: {result.stderr}")
    return shot, list(dump.read_bytes())


def picture(path: Path, x: int, engine: str, model: str) -> dict[str, Any]:
    width, height, actual = PNG.pixels(path)
    # Native capture origin relative to VIC coordinates. No alignment search.
    ox, oy = (24, 1) if engine == "emu" else (8, -15 if model == "pal" else -27)
    expected = {
        (x + ox + dx, 120 + oy + dy)
        for dy in range(21)
        for dx in range(24)
        if dy in (0, 10, 20) or dx in (0, 11, 12, 23)
    }
    require(
        actual.keys() == expected,
        f"wrong pixels: missing {len(expected - actual.keys())}, "
        f"extra {len(actual.keys() - expected)}",
    )
    require(set(actual.values()) == {b"\xff\xff\xff"}, "sprite is not white")
    return {
        "dimensions": [width, height],
        "lit_pixels": len(actual),
        "sha256": sha(path),
    }


def registers(state: list[int], x: int, seed: int) -> dict[str, int]:
    require(len(state) == 49 and 20 <= state[0] <= 35, f"guest did not run: {state}")
    expected = {
        0: x & 255,
        1: 120,
        0x10: seed | (x >> 8),
        0x15: seed | 1,
        0x17: seed,
        0x1B: seed,
        0x1C: seed,
        0x1D: seed,
    }
    for offset, value in expected.items():
        require(
            state[offset + 1] == value,
            f"register ${0xD000 + offset:04x}: {state[offset + 1]}, expected {value}",
        )
    require(state[0x28] & 15 == 1, "wrong colour register")
    require(state[-1] == 0x80, "wrong shape pointer")
    return {f"${0xD000 + offset:04x}": state[offset + 1] for offset in expected}


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
        executable = shutil.which(getattr(args, name))
        require(executable is not None, f"missing {name}")
        setattr(args, name, executable)
    rows = []
    for x, seed in ((160, 0), (24, 0xAA), (255, 0x54), (256, 0xAA), (296, 0x54)):
        dest = args.output / f"x{x}-seed{seed:02x}"
        prg, symbols = assemble(args, dest, x, seed)
        for model in ("pal", "ntsc"):
            for engine, run in (("emu", run_emu), ("vice", run_vice)):
                shot, state = run(args, dest, prg, symbols, model)
                row = {
                    "x": x,
                    "seed": seed,
                    "engine": engine,
                    "model": model,
                    "registers": registers(state, x, seed),
                    "picture": picture(shot, x, engine, model),
                    "prg_sha256": sha(prg),
                }
                rows.append(row)
                print("PASS", x, seed, engine, model, flush=True)
    dest = args.output / "negative-missing-x-high"
    prg, symbols = assemble(args, dest, 296, 0, broken=True)
    shot, _ = run_emu(args, dest, prg, symbols, "pal")
    try:
        picture(shot, 296, "emu", "pal")
    except AssertionError as error:
        negative = str(error)
        print("PASS negative control rejected:", negative, flush=True)
    else:
        raise AssertionError("observer accepted missing X-high bit")
    result = {
        "sources": {
            name: sha(ROOT / name)
            for name in (
                "demo.asm",
                "sprite.inc",
                "shape.inc",
                "verification/verify.py",
            )
        },
        "png_reader_sha256": sha(HELPER),
        "tools": {
            name: {"sha256": sha(Path(getattr(args, name)))}
            for name in ("assembler", "acme", "emulator", "vice")
        },
        "checks": rows,
        "negative_control": negative,
    }
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"{len(rows)} captures passed; negative control rejected", flush=True)


if __name__ == "__main__":
    main()
