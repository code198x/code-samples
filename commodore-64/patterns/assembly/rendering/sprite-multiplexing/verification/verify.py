"""Assemble against ACME; check the visible result on Emu198x and VICE.

No third-party Python packages. ROMs are supplied by the installed emulators.
The pixel checks use unfiltered native screenshots, not rendered CRT output.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import struct
import subprocess
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pixels(path: Path) -> tuple[int, int, dict[tuple[int, int], bytes]]:
    """Read 8-bit RGB(A) PNGs; return non-black pixels without alpha."""
    data = path.read_bytes()
    require(data[:8] == b"\x89PNG\r\n\x1a\n", "not a PNG")
    pos, compressed = 8, bytearray()
    width = height = channels = 0
    while pos < len(data):
        length = int.from_bytes(data[pos : pos + 4], "big")
        kind, body = data[pos + 4 : pos + 8], data[pos + 8 : pos + 8 + length]
        require(
            zlib.crc32(kind + body)
            == int.from_bytes(data[pos + 8 + length : pos + 12 + length], "big"),
            "PNG CRC",
        )
        if kind == b"IHDR":
            width, height, depth, colour, compression, filtering, interlace = (
                struct.unpack(">IIBBBBB", body)
            )
            require(
                depth == 8
                and colour in (2, 6)
                and (compression, filtering, interlace) == (0, 0, 0),
                "unsupported PNG",
            )
            channels = {2: 3, 6: 4}[colour]
        elif kind == b"IDAT":
            compressed.extend(body)
        pos += length + 12
    raw = zlib.decompress(compressed)
    stride = width * channels
    require(len(raw) == height * (stride + 1), "PNG raster size")
    previous, result = bytearray(stride), {}
    for y in range(height):
        start = y * (stride + 1)
        mode, row = raw[start], bytearray(raw[start + 1 : start + 1 + stride])
        require(mode <= 4, "PNG filter")
        for i in range(stride):
            a = row[i - channels] if i >= channels else 0
            b, c = previous[i], previous[i - channels] if i >= channels else 0
            p = a + b - c
            paeth = min((a, b, c), key=lambda value: abs(p - value))
            row[i] = (row[i] + (0, a, b, (a + b) // 2, paeth)[mode]) & 255
        for x in range(width):
            rgb = bytes(row[x * channels : x * channels + 3])
            if rgb != b"\0\0\0":
                result[x, y] = rgb
        previous = row
    return width, height, result


def check_picture(path: Path, counts: tuple[int, int], origin: tuple[int, int]) -> dict:
    width, height, actual = pixels(path)
    expected: dict[tuple[int, int], int] = {}
    ox, oy = origin
    for band, count in enumerate(counts):
        for slot in range(count if count <= 8 else 0):
            column = slot if band == 0 else 7 - slot
            x, y = ox + column * 40, oy + band * 112
            for dy in range(21):
                for dx in range(24):
                    if band == 0 or dx in (0, 23) or dy in (0, 20):
                        expected[x + dx, y + dy] = column + 1
    require(
        actual.keys() == expected.keys(),
        f"{path.name}: wrong pixels: missing {len(expected.keys() - actual.keys())}, extra {len(actual.keys() - expected.keys())}",
    )
    colours: dict[int, set[bytes]] = {}
    for xy, colour in expected.items():
        colours.setdefault(colour, set()).add(actual[xy])
    require(
        all(len(values) == 1 for values in colours.values()),
        "sprite colour changed within/between bands",
    )
    require(
        len({next(iter(values)) for values in colours.values()}) == len(colours),
        "distinct sprite colours lost",
    )
    return {
        "dimensions": [width, height],
        "lit_pixels": len(actual),
        "colours": len(colours),
        "sha256": sha(path),
    }


def assemble(
    args: argparse.Namespace,
    dest: Path,
    counts: tuple[int, int],
    transition: bool = False,
    broken: bool = False,
) -> tuple[Path, dict[str, int]]:
    dest.mkdir(parents=True, exist_ok=True)
    source = (ROOT / "demo.asm").read_text()
    include = (
        (ROOT / "multiplexer.inc")
        .read_text()
        .replace("!byte 8, 8", f"!byte {counts[0]}, {counts[1]}")
    )
    if transition:
        source = source.replace(
            "idle:\n    jmp idle",
            """idle:
    lda mux_frames
    cmp #60
    bcc idle
    lda #0
    sta mux_counts
    sta mux_counts + 1
wait_restore:
    lda mux_frames
    cmp #120
    bcc wait_restore
    lda #8
    sta mux_counts
    sta mux_counts + 1
finished:
    jmp finished""",
        )
    if broken:
        include = include.replace("sta $d010", "sta $02ff")
    (dest / "demo.asm").write_text(source)
    (dest / "multiplexer.inc").write_text(include)
    prg = dest / "demo.prg"
    subprocess.run(
        [
            args.assembler,
            "--dialect",
            "acme",
            "--prg",
            "--sym=" + str(dest / "demo.sym"),
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
    args: argparse.Namespace,
    dest: Path,
    prg: Path,
    symbols: dict[str, int],
    model: str,
    stages: list[tuple[int, tuple[int, int]]],
) -> list[tuple[Path, list[int]]]:
    script: list[dict] = []
    for key in ["R", "U", "N", "RETURN"]:
        for pressed, frames in [(True, 4), (False, 3)]:
            script.extend(
                [
                    {
                        "action": "input",
                        "events": [{"Key": {"name": key, "pressed": pressed}}],
                    },
                    {"action": "run_frames", "frames": frames},
                ]
            )
    captures = []
    previous = 5  # RUN has already allowed about five frames; exact count read below
    for target, _ in stages:
        shot = dest / f"emu-{model}-{target}.png"
        script.extend(
            [
                {"action": "run_frames", "frames": target - previous},
                {"action": "memory_read", "addr": symbols["mux_frames"], "len": 5},
                {"action": "save_screenshot", "path": str(shot)},
            ]
        )
        captures.append(shot)
        previous = target
    path = dest / f"emu-{model}.json"
    path.write_text(json.dumps(script, indent=2) + "\n")
    result = subprocess.run(
        [args.emulator, "--model", model, "--load", str(prg), "--script", str(path)],
        capture_output=True,
        text=True,
        check=True,
        timeout=120,
    )
    (dest / f"emu-{model}-report.json").write_text(result.stdout)
    report = json.loads(result.stdout)
    values = [
        row["bytes"] for row in report["observations"] if row["kind"] == "memory_read"
    ]
    require(len(values) == len(stages), "missing Emu198x observations")
    return list(zip(captures, values, strict=True))


def run_vice(
    args: argparse.Namespace,
    dest: Path,
    prg: Path,
    symbols: dict[str, int],
    model: str,
    stages: list[tuple[int, tuple[int, int]]],
) -> list[tuple[Path, list[int]]]:
    commands = [f'load "{prg}" 0']
    captures = []
    for index, (target, _) in enumerate(stages):
        # VICE evaluates expressions left to right; parenthesise each comparison.
        commands += [
            f"break exec $0800 $1fff if (@ram:${symbols['mux_frames']:04x} == ${target:02x}) && (RL == $fa)",
            "g $0810" if index == 0 else "x",
            "delete 1",
        ]
        shot, dump = (
            dest / f"vice-{model}-{target}.png",
            dest / f"vice-{model}-{target}.bin",
        )
        commands += [
            f'screenshot "{shot}" 2',
            f'bsave "{dump}" 0 ${symbols["mux_frames"]:04x} ${symbols["mux_frames"] + 4:04x}',
        ]
        captures.append((shot, dump))
    commands.append("quit")
    monitor = dest / f"vice-{model}.mon"
    monitor.write_text("\n".join(commands) + "\n")
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
            "-monlog",
            "-monlogname",
            str(dest / f"vice-{model}-monitor.log"),
            "-limitcycles",
            "6000000",
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
    require(
        result.returncode == 0,
        f"VICE exit {result.returncode}: {result.stderr}; see {dest}",
    )
    return [(shot, list(dump.read_bytes())) for shot, dump in captures]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assembler", default="asm198x")
    parser.add_argument("--acme", default="acme")
    parser.add_argument("--emulator", default="emu198x-c64")
    parser.add_argument("--vice", default="x64sc")
    parser.add_argument("--output", type=Path, default=ROOT / "build" / "verification")
    args = parser.parse_args()
    for key in ("assembler", "acme", "emulator", "vice"):
        executable = shutil.which(getattr(args, key))
        require(executable is not None, f"missing {key}")
        setattr(args, key, executable)
    args.output = args.output.resolve()
    rows = []
    # Coordinates are native capture origins: sprite X=24, Y=64. Crop offsets
    # differ between the emulators; spacing/size and every visible pixel agree.
    origins = {
        "emu-pal": (48, 65),
        "emu-ntsc": (48, 65),
        "vice-pal": (32, 49),
        "vice-ntsc": (32, 37),
    }
    cases = [(0, 0), (1, 1), (7, 7), (8, 8), (9, 9), (255, 255), (0, 8), (8, 0)]
    for counts, transition in [(c, False) for c in cases] + [((8, 8), True)]:
        name = "transition" if transition else f"{counts[0]}-{counts[1]}"
        dest = args.output / name
        prg, symbols = assemble(args, dest, counts, transition)
        stages = (
            [(25, counts), (65, (0, 0)), (125, (8, 8))]
            if transition
            else [(25, counts)]
        )
        for model in ("pal", "ntsc"):
            for engine, runner in [("emu", run_emu), ("vice", run_vice)]:
                captures = runner(args, dest, prg, symbols, model, stages)
                for (shot, state), (target, expected) in zip(
                    captures, stages, strict=True
                ):
                    require(
                        len(state) == 5 and abs(state[0] - target) <= 2,
                        f"program did not progress: {state}",
                    )
                    require(
                        state[1:3] == [int(c > 8) for c in expected],
                        f"bad count handling: {state}",
                    )
                    require(
                        32 <= state[3] < 64 and 144 <= state[4] < 176,
                        f"missed sprite deadline: {state}",
                    )
                    picture = check_picture(
                        shot, expected, origins[f"{engine}-{model}"]
                    )
                    row = {
                        "case": name,
                        "engine": engine,
                        "model": model,
                        "frame": state[0],
                        "counts": expected,
                        "errors": state[1:3],
                        "last_write_lines": state[3:5],
                        "picture": picture,
                        "prg_sha256": sha(prg),
                    }
                    rows.append(row)
                    print("PASS", name, engine, model, state, flush=True)
    dest = args.output / "negative-missing-x-msb"
    prg, symbols = assemble(args, dest, (8, 8), broken=True)
    [(shot, _)] = run_emu(args, dest, prg, symbols, "pal", [(25, (8, 8))])
    try:
        check_picture(shot, (8, 8), origins["emu-pal"])
    except AssertionError as error:
        negative = str(error)
        print("PASS negative control rejected:", negative, flush=True)
    else:
        raise AssertionError("pixel observer accepted missing X high bits")
    result = {
        "sources": {
            name: sha(ROOT / name)
            for name in ["demo.asm", "multiplexer.inc", "verification/verify.py"]
        },
        "tools": {
            key: {"path": getattr(args, key), "sha256": sha(Path(getattr(args, key)))}
            for key in ["assembler", "acme", "emulator", "vice"]
        },
        "checks": rows,
        "negative_control": negative,
    }
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(f"{len(rows)} captures checked; negative control rejected", flush=True)


if __name__ == "__main__":
    main()
