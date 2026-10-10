"""Exercise control-port pins, held-key matrices, edge state and visible cells."""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
import struct
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parents[4]
HELPER = ROOT.parents[1] / "physics/sprite-movement-bounds/verification/verify.py"
SPEC = importlib.util.spec_from_file_location("c64_execution", HELPER)
assert SPEC is not None and SPEC.loader is not None
RUN = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUN)
require, sha = RUN.require, RUN.sha
CONTROLS = ("up", "down", "left", "right", "fire")
CAPTURES = {31, 63, 79, 95}
STAGES = [(m, 0) for m in range(32)] + [(0, m) for m in range(32)]
STAGES += [(m, 31 - m) for m in range(32)]
STAGES += [(0, 0), (16, 16), (16, 16), (16, 16), (0, 0), (16, 16), (0, 0)]


def vice(
    args: argparse.Namespace,
    dest: Path,
    model: str,
    commands: list[str],
    *,
    joystick: bool = True,
) -> None:
    path = dest / f"vice-{model}.mon"
    path.write_text("\n".join(commands + ["quit", ""]))
    result = subprocess.run(
        [
            args.vice,
            "-console",
            "-default",
            "-model",
            "c64" if model == "pal" else "ntsc",
            *(
                ["-controlport1device", "io", "-controlport2device", "io"]
                if joystick
                else []
            ),
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
        ],
        cwd=dest,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,
    )
    require(result.returncode == 0, f"VICE exit {result.returncode}: {result.stderr}")


def keyboard_snapshot(source: Path, target: Path, key: tuple[int, int] | None) -> None:
    data = bytearray(source.read_bytes())
    require(data[:19] == b"VICE Snapshot File\x1a", "wrong snapshot magic")
    require(data[37:50] == b"VICE Version\x1a", "missing snapshot version header")
    offset, matches = 58, 0
    while offset < len(data):
        require(offset + 22 <= len(data), "truncated module header")
        size = struct.unpack_from("<I", data, offset + 18)[0]
        require(size >= 22 and offset + size <= len(data), "invalid module size")
        if data[offset : offset + 16].split(b"\0")[0] == b"KEYBOARD":
            require(
                data[offset + 16 : offset + 18] == b"\1\1" and size == 118,
                "unsupported keyboard snapshot layout",
            )
            matrix = [0] * 24  # VICE has 16 rows and 8 reverse columns.
            if key is not None:
                row, col = key
                matrix[row] = 1 << col
                matrix[16 + col] = 1 << row
            struct.pack_into("<24I", data, offset + 22, *matrix)
            matches += 1
        offset += size
    require(matches == 1, "missing or duplicate keyboard module")
    target.write_bytes(data)


def probe(args: argparse.Namespace) -> list[dict[str, Any]]:
    dest = args.output / "probe"
    dest.mkdir(parents=True, exist_ok=True)
    for name in ("baseline1.inc", "baseline2.inc"):
        (dest / name).write_bytes((ROOT / "verification" / name).read_bytes())
    prg, sym = RUN.build(args, dest, (ROOT / "verification/probe.asm").read_text())
    rows = []
    for model in ("pal", "ntsc"):
        base = dest / f"base-{model}.vsf"
        vice(
            args,
            dest,
            model,
            [
                f'load "{prg}" 0',
                f"break exec ${sym['ready']:04x}",
                "g $0810",
                f'dump "{base}"',
            ],
            joystick=False,
        )
        for key, position, old1, reverse in (
            ("none", None, 0, 0),
            ("1", (7, 0), 1, 0),
            ("SPACE", (7, 4), 16, 0),
            ("RETURN", (0, 1), 0, 1),
            ("A", (1, 2), 0, 0),
        ):
            case = dest / f"{model}-{key}"
            case.mkdir(exist_ok=True)
            script = [{"action": "run_until_pc", "addr": sym["ready"]}]
            if position is not None:
                script += [
                    {
                        "action": "input",
                        "events": [{"Key": {"name": key, "pressed": True}}],
                    }
                ]
            script += [
                {"action": "run_frames", "frames": 1},
                {"action": "poke_byte", "addr": sym["request"], "value": 1},
                {"action": "run_until_pc", "addr": sym["done"]},
                {"action": "memory_read", "addr": sym["observed"], "len": 7},
            ]
            obs = RUN.emu(args, case, prg, model, script)
            reads = [r["bytes"] for r in obs if r["kind"] == "memory_read"]
            require(len(reads) == 1, "missing probe observations")
            emu = reads[0]
            snap = case / "key.vsf"
            keyboard_snapshot(base, snap, position)
            dump = case / "probe.bin"
            vice(
                args,
                case,
                model,
                [
                    f'undump "{snap}"',
                    f"> ${sym['request']:04x} 01",
                    f"break exec ${sym['done']:04x}",
                    "x",
                    f'bsave "{dump}" 0 ${sym["observed"]:04x} ${sym["observed"] + 6:04x}',
                ],
                joystick=False,
            )
            reference = list(dump.read_bytes())
            expected = [0, old1, 0, 0, reverse, 0, 2 if reverse else 0]
            require(reference == expected, f"reference probe {key}: {reference}")
            # Keep the known missing reverse path visible, never count it as parity.
            allowed = [0, old1, 0, 0, 0, 0, 2 if reverse else 0]
            require(emu in (expected, allowed), f"unexpected Emu probe {key}: {emu}")
            rows.append(
                {
                    "model": model,
                    "key": key,
                    "emulator": emu,
                    "reference": reference,
                    "matches_reference": emu == reference,
                    "known_difference": "reverse keyboard scan"
                    if emu != reference
                    else None,
                }
            )
            print("PROBE", model, key, emu, reference, flush=True)
    return rows


def buttons(one: int, two: int) -> list[dict[str, Any]]:
    return [
        {"Button": {"port": port, "name": name, "pressed": bool(mask & (1 << bit))}}
        for port, mask in ((1, one), (2, two))
        for bit, name in enumerate(CONTROLS)
    ]


def oracle(
    previous: tuple[int, int], current: tuple[int, int], counts: tuple[int, int]
) -> list[int]:
    edges = [now & ~old for now, old in zip(current, previous, strict=True)]
    return [
        *current,
        *edges,
        *(
            (count + int(bool(edge & 16))) & 255
            for count, edge in zip(counts, edges, strict=True)
        ),
    ]


def screen(reads: list[list[int]], state: list[int]) -> None:
    for port in range(2):
        cells = reads[port]
        require(len(cells) == 17, "missing indicator cells")
        require(
            [cells[i * 4] for i in range(5)]
            == [160 if state[port] & (1 << i) else 32 for i in range(5)],
            "wrong displayed input",
        )
        value = state[4 + port]
        digits = [48 + n if n < 10 else n - 9 for n in (value >> 4, value & 15)]
        require(reads[2 + port] == digits, "wrong displayed fire count")


def picture(
    path: Path, masks: tuple[int, int], engine: str, model: str
) -> dict[str, Any]:
    width, height, pixels = RUN.PNG.pixels(path)
    ox, oy = (48, 51) if engine == "emu" else (32, 35 if model == "pal" else 23)
    for port, mask in enumerate(masks):
        for bit, column in enumerate((8, 12, 16, 20, 24)):
            points = {
                (ox + column * 8 + x, oy + (5 + 8 * port) * 8 + y)
                for y in range(8)
                for x in range(8)
            }
            found = {p for p in points if p in pixels}
            require(
                found == (points if mask & (1 << bit) else set()),
                f"wrong picture indicator {port + 1}/{bit}",
            )
            require(
                all(pixels[p] == b"\xff\xff\xff" for p in found),
                "indicator is not white",
            )
    return {"dimensions": [width, height], "sha256": sha(path), "checked_cells": 10}


def matrix(
    args: argparse.Namespace, broken: bool = False
) -> tuple[list[dict[str, Any]], dict[str, int]]:
    dest = args.output / ("negative" if broken else "matrix")
    dest.mkdir(parents=True, exist_ok=True)
    caller = (
        (ROOT / "demo.asm")
        .read_text()
        .replace(
            "read_inputs:\n",
            "read_inputs:\n    lda request\n    beq read_inputs\n    dec request\n",
        )
    )
    caller += "\nrequest: !byte 0\n"
    routine = (ROOT / "joystick.inc").read_text()
    if broken:
        needle = "    and joy1_new             ; current AND NOT previous"
        require(needle in routine, "mutation target missing")
        routine = routine.replace(needle, "    nop")
    (dest / "joystick.inc").write_text(routine)
    prg, sym = RUN.build(args, dest, caller)
    stages = [(0, 0), (16, 0), (16, 0)] if broken else STAGES
    regions = [(sym["joy1"], 6), (0x04D0, 17), (0x0610, 17), (0x052A, 2), (0x066A, 2)]
    rows = []
    for model in ("pal", "ntsc"):
        for engine in ("emu", "vice"):
            if engine == "emu":
                script = [{"action": "run_until_pc", "addr": sym["read_inputs"]}]
                for index, masks in enumerate(stages):
                    script += [
                        {"action": "input", "events": buttons(*masks)},
                        {"action": "run_frames", "frames": 1},
                        {"action": "poke_byte", "addr": sym["request"], "value": 1},
                        {"action": "run_until_pc", "addr": sym["frame_done"]},
                    ]
                    script += [
                        {"action": "memory_read", "addr": addr, "len": length}
                        for addr, length in regions
                    ]
                    if not broken and index in CAPTURES:
                        script += [
                            {"action": "run_frames", "frames": 2},
                            {
                                "action": "save_screenshot",
                                "path": str(dest / f"{engine}-{model}-{index}.png"),
                            },
                        ]
                obs = RUN.emu(args, dest, prg, model, script)
                reads = [r["bytes"] for r in obs if r["kind"] == "memory_read"]
            else:
                commands = [
                    f'load "{prg}" 0',
                    f"break exec ${sym['read_inputs']:04x}",
                    "g $0810",
                    "delete 1",
                ]
                for index, (one, two) in enumerate(stages):
                    commands += [
                        f"jpdb 0 ${(one ^ 255):02x}",
                        f"jpdb 1 ${(two ^ 255):02x}",
                        f"> ${sym['request']:04x} 01",
                        f"break exec ${sym['frame_done']:04x}",
                        "x",
                        "delete 1",
                    ]
                    commands += [
                        f'bsave "{dest / f"vice-{model}-{index}-{j}.bin"}" 0 ${addr:04x} ${addr + length - 1:04x}'
                        for j, (addr, length) in enumerate(regions)
                    ]
                    if not broken and index in CAPTURES:
                        commands += [
                            f"break exec ${sym['read_inputs']:04x} if RL == $fa",
                            "x",
                            "delete 1",
                            f'screenshot "{dest / f"{engine}-{model}-{index}.png"}" 2',
                        ]
                vice(args, dest, model, commands)
                reads = [
                    list((dest / f"vice-{model}-{i}-{j}.bin").read_bytes())
                    for i in range(len(stages))
                    for j in range(len(regions))
                ]
            require(len(reads) == len(stages) * 5, "missing matrix observations")
            previous, counts = (0, 0), (0, 0)
            failures = 0
            for index, masks in enumerate(stages):
                state, *display = reads[index * 5 : index * 5 + 5]
                expected = oracle(previous, masks, counts)
                row = {
                    "engine": engine,
                    "model": model,
                    "stage": index,
                    "input": masks,
                    "observed": state,
                    "expected": expected,
                }
                if broken:
                    failures += state != expected
                    row["rejected"] = state != expected
                else:
                    require(
                        state == expected,
                        f"{engine} {model} {index}: {state}, expected {expected}",
                    )
                    screen(display, state)
                    if index in CAPTURES:
                        row["picture"] = picture(
                            dest / f"{engine}-{model}-{index}.png", masks, engine, model
                        )
                previous, counts = masks, (expected[4], expected[5])
                rows.append(row)
            require(
                failures == (1 if broken else 0),
                "negative control did not isolate held-fire failure",
            )
            print("PASS", dest.name, engine, model, len(stages), "states", flush=True)
    return rows, {
        "routine_bytes": sym["joy_code_end"] - sym["joy_init"],
        "state_bytes": 6,
    }


def live(args: argparse.Namespace) -> list[dict[str, Any]]:
    """Run the unchanged once-per-frame caller with held inputs and fresh pictures."""
    dest = args.output / "live"
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "joystick.inc").write_bytes((ROOT / "joystick.inc").read_bytes())
    prg, sym = RUN.build(args, dest, (ROOT / "demo.asm").read_text())
    stages = [(0, 0), (1, 2), (16, 16), (16, 16), (0, 0), (16, 16), (31, 31), (0, 0)]
    rows = []
    for model in ("pal", "ntsc"):
        for engine in ("emu", "vice"):
            if engine == "emu":
                script = []
                for index, masks in enumerate(stages):
                    script += [
                        {"action": "input", "events": buttons(*masks)},
                        {"action": "run_frames", "frames": 3},
                        {"action": "run_until_pc", "addr": sym["frame_done"]},
                        {"action": "memory_read", "addr": sym["joy1"], "len": 6},
                        {
                            "action": "save_screenshot",
                            "path": str(dest / f"{engine}-{model}-{index}.png"),
                        },
                    ]
                obs = RUN.emu(args, dest, prg, model, script)
                states = [r["bytes"] for r in obs if r["kind"] == "memory_read"]
            else:
                commands = [f'load "{prg}" 0']
                for index, (one, two) in enumerate(stages):
                    commands += [
                        f"jpdb 0 ${(one ^ 255):02x}",
                        f"jpdb 1 ${(two ^ 255):02x}",
                        f"break exec ${sym['frame_done']:04x} if @ram:${sym['frames']:04x} == ${(3 * (index + 1)):02x}",
                        "g $0810" if index == 0 else "x",
                        "delete 1",
                        f'bsave "{dest / f"vice-{model}-{index}.bin"}" 0 ${sym["joy1"]:04x} ${sym["joy1"] + 5:04x}',
                        f'screenshot "{dest / f"{engine}-{model}-{index}.png"}" 2',
                    ]
                vice(args, dest, model, commands)
                states = [
                    list((dest / f"vice-{model}-{i}.bin").read_bytes())
                    for i in range(len(stages))
                ]
            require(len(states) == len(stages), "missing live observations")
            previous, counts = (0, 0), (0, 0)
            for index, (masks, state) in enumerate(zip(stages, states, strict=True)):
                transition = oracle(previous, masks, counts)
                counts = (transition[4], transition[5])
                expected = [*masks, 0, 0, *counts]  # several samples into a hold
                require(
                    state == expected,
                    f"live {engine}/{model}/{index}: {state}, expected {expected}",
                )
                rows.append(
                    {
                        "engine": engine,
                        "model": model,
                        "stage": index,
                        "input": masks,
                        "observed": state,
                        "prg_sha256": sha(prg),
                        "picture": picture(
                            dest / f"{engine}-{model}-{index}.png", masks, engine, model
                        ),
                    }
                )
                previous = masks
            print("PASS live", engine, model, len(stages), "captures", flush=True)
    return rows


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
    probes = probe(args)
    cases, sizes = matrix(args)
    negative, _ = matrix(args, broken=True)
    live_cases = live(args)
    record = {
        "sources": {
            name: sha(ROOT / name)
            for name in (
                "demo.asm",
                "joystick.inc",
                "verification/verify.py",
                "verification/probe.asm",
                "verification/baseline1.inc",
                "verification/baseline2.inc",
            )
        },
        "shared_sources": {
            str(path.relative_to(REPO)): sha(path) for path in (HELPER, RUN.HELPER)
        },
        "tools": {
            name: {"sha256": sha(Path(getattr(args, name)))}
            for name in ("assembler", "acme", "emulator", "vice")
        },
        "keyboard_probe": probes,
        "cases": cases,
        "negative_control": negative,
        "sizes": sizes,
        "live": live_cases,
    }
    (args.output / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print(
        "PASS supported reader cases; known reverse-keyboard difference remains recorded",
        flush=True,
    )


if __name__ == "__main__":
    main()
