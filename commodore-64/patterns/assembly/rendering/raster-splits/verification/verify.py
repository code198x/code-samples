"""Observe delayed raster splits, foreground survival and complete pictures."""

from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
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


def picture(path: Path, line: int, engine: str, model: str) -> dict[str, Any]:
    width, height, pixels = RUN.PNG.pixels(path)
    # Native raster origins, not sprite Y coordinates (sprites start a line later).
    # Emu198x stores all lines; VICE's normal crop begins at PAL 16 / NTSC 28.
    ox, oy = (24, 0) if engine == "emu" else (8, -16 if model == "pal" else -28)
    actual = {(x - ox, y - oy): colour for (x, y), colour in pixels.items()}
    require(bool(actual), "missing blue region")
    require(
        all(24 <= x <= 343 and line <= y <= 250 for x, y in actual),
        "colour outside the lower display region",
    )
    colours = set(actual.values())
    require(len(colours) == 1, "lower region has more than one colour")
    red, green, blue = next(iter(colours))
    require(blue > red and blue > green, "lower region is not blue")
    starts = []
    for x in range(24, 344):
        rows = sorted(y for px, y in actual if px == x)
        require(bool(rows), f"missing blue column {x}")
        start = rows[0]
        # A bounded demo check, not a universal interrupt latency guarantee.
        require(line <= start <= line + 3, f"late transition at {x}: {start}")
        require(rows == list(range(start, 251)), f"holes in column {x}")
        starts.append(start)
    # Observed in the separately executed VICE 3.10 fixture, with this caller.
    # These are regression expectations for the example, not hardware guarantees.
    expected_range = [line + 1, line + (2 if line == 131 else 1)]
    require(
        [min(starts), max(starts)] == expected_range,
        "transition differs from reference capture",
    )
    runs = []
    for x, start in enumerate(starts, 24):
        if runs and runs[-1][2] == start:
            runs[-1][1] = x
        else:
            runs.append([x, x, start])
    return {
        "dimensions": [width, height],
        "compare_line": line,
        "first_blue_line_range": [min(starts), max(starts)],
        "first_blue_line_runs": runs,
        "blue_rgb": [red, green, blue],
        "blue_pixels": len(actual),
        "sha256": sha(path),
    }


def execute(
    args: argparse.Namespace,
    dest: Path,
    line: int,
    *,
    baseline: bool = False,
    broken: bool = False,
) -> tuple[list[dict[str, Any]], dict[str, int]]:
    dest.mkdir(parents=True, exist_ok=True)
    caller = (ROOT / "demo.asm").read_text()
    include = ROOT / ("verification/baseline.inc" if baseline else "split.inc")
    routine = include.read_text().replace("SPLIT_LINE  = 130", f"SPLIT_LINE  = {line}")
    if baseline:
        caller = caller.replace("jsr split_init", "jsr setup")
    if broken:
        original = "    lda #$06               ; blue below the split"
        require(original in routine, "negative control did not find the colour write")
        routine = routine.replace(original, "    lda #$00")
    (dest / "split.inc").write_text(routine)
    prg, sym = RUN.build(args, dest, caller)
    results = []
    for model in ("pal", "ntsc"):
        for engine in ("emu", "vice"):
            if engine == "emu":
                script = [
                    {"action": "run_frames", "frames": 20},
                    {"action": "run_until_pc", "addr": sym["picture_ready"]},
                ]
                for index in range(3):
                    for _ in range(3):
                        script += [
                            {"action": "run_until_pc", "addr": sym["wait_top"]},
                            {"action": "run_until_pc", "addr": sym["picture_ready"]},
                        ]
                    script += [
                        {"action": "memory_read", "addr": sym["frames"], "len": 2},
                        {
                            "action": "save_screenshot",
                            "path": str(dest / f"{engine}-{model}-{index}.png"),
                        },
                    ]
                obs = RUN.emu(args, dest, prg, model, script)
                states = [r["bytes"] for r in obs if r["kind"] == "memory_read"]
            else:
                commands = [f'load "{prg}" 0']
                for index in range(3):
                    commands += [
                        f"break exec ${sym['picture_ready']:04x} if @ram:${sym['frames']:04x} == ${20 + 3 * index:02x}",
                        "g $0810" if index == 0 else "x",
                        "delete 1",
                        f'bsave "{dest / f"{engine}-{model}-{index}.bin"}" 0 ${sym["frames"]:04x} ${sym["errors"]:04x}',
                        f'screenshot "{dest / f"{engine}-{model}-{index}.png"}" 2',
                    ]
                RUN.vice(args, dest, model, commands)
                states = [
                    list((dest / f"{engine}-{model}-{i}.bin").read_bytes())
                    for i in range(3)
                ]
            require(len(states) == 3, "missing foreground observations")
            previous = None
            for index, state in enumerate(states):
                require(
                    len(state) == 2 and state[0] >= 20 and state[1] == 0,
                    f"foreground failed: {state}",
                )
                if previous is not None:
                    require(
                        state[0] - previous == 3, "foreground frame progress differs"
                    )
                previous = state[0]
                shot = dest / f"{engine}-{model}-{index}.png"
                row = {
                    "engine": engine,
                    "model": model,
                    "frame": state[0],
                    "errors": state[1],
                    "prg_sha256": sha(prg),
                }
                if broken:
                    try:
                        picture(shot, line, engine, model)
                    except AssertionError as error:
                        require(
                            str(error) == "missing blue region",
                            f"unexpected failure: {error}",
                        )
                        row["rejected"] = str(error)
                    else:
                        raise AssertionError("missing colour write was accepted")
                else:
                    row["picture"] = picture(shot, line, engine, model)
                results.append(row)
                print(
                    "PASS",
                    dest.name,
                    engine,
                    model,
                    index,
                    row.get("picture", {}).get(
                        "first_blue_line_range", row.get("rejected")
                    ),
                    flush=True,
                )
    sizes = {} if baseline else {"routine_bytes": sym["split_end"] - sym["split_init"]}
    return results, sizes


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
    baseline, _ = execute(args, args.output / "baseline", 130, baseline=True)
    rows = []
    for line in (64, 130, 131, 200):
        observed, sizes = execute(args, args.output / f"line-{line}", line)
        rows += observed
    negative, _ = execute(args, args.output / "negative", 130, broken=True)
    record = {
        "sources": {
            name: sha(ROOT / name)
            for name in (
                "demo.asm",
                "split.inc",
                "verification/verify.py",
                "verification/baseline.inc",
            )
        },
        "shared_sources": {
            str(path.relative_to(REPO)): sha(path) for path in (HELPER, RUN.HELPER)
        },
        "tools": {
            name: {"sha256": sha(Path(getattr(args, name)))}
            for name in ("assembler", "acme", "emulator", "vice")
        },
        "baseline": baseline,
        "cases": rows,
        "negative_control": negative,
        "sizes": sizes,
    }
    (args.output / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print(
        "PASS: 12 baseline captures, 48 maintained captures, 12 rejected colour mutations",
        flush=True,
    )


if __name__ == "__main__":
    main()
