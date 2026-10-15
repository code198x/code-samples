"""Execute the maintained bitmap routines in uncontended 48K Spectrum RAM."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TICKS = 14_000_000


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def command(args: list[str], cwd: Path) -> str:
    result = subprocess.run(
        args, cwd=cwd, capture_output=True, text=True, timeout=60, check=False
    )
    require(result.returncode == 0, f"{args[0]} failed: {result.stderr}")
    return result.stdout


def tool(name: str) -> str:
    found = shutil.which(name)
    require(found is not None, f"Executable not found: {name}")
    return str(Path(found).resolve())


def layout() -> list[list[int]]:
    # Enumerate the physical bitmap in memory order, then assign display rows.
    # This does not translate pixel_addr's rotations/masks into Python.
    rows = [[0] * 32 for _ in range(192)]
    address = 0x4000
    for third in range(3):
        for scanline in range(8):
            for character_row in range(8):
                y = third * 64 + character_row * 8 + scanline
                for column in range(32):
                    rows[y][column] = address
                    address += 1
    require(address == 0x5800, "Oracle must enumerate the whole bitmap")
    require(len({a for row in rows for a in row}) == 6144, "Oracle has gaps")
    return rows


def assemble(directory: Path, assembler: str, pasmo: str | None) -> dict[str, int]:
    args = [assembler, "--dialect", "pasmo", "--cpu", "z80"]
    command([*args, "--sym=program.sym", "caller.asm", "-o", "program.bin"], directory)
    command([*args, "--sna", "caller.asm", "-o", "program.sna"], directory)
    if pasmo:
        command([pasmo, "--bin", "caller.asm", "reference.bin"], directory)
        require(
            (directory / "reference.bin").read_bytes()
            == (directory / "program.bin").read_bytes(),
            "Pasmo binary differs",
        )
    symbols = {
        name: int(value, 16)
        for name, value in re.findall(
            r"^(\w+) = \$([0-9a-fA-F]+)$",
            (directory / "program.sym").read_text(),
            re.MULTILINE,
        )
    }
    require(symbols["end_pixel_down"] < 0x8FFF, "Code overlaps result guard")
    return symbols


def observe(
    directory: Path, emulator: str, symbols: dict[str, int], start: int, stop: int
) -> tuple[list[int], dict[str, Any]]:
    length = (stop - start) * 1024
    code = bytearray((directory / "program.bin").read_bytes())
    for label, value in [("start_y", start), ("end_y", stop)]:
        code[symbols[label] - 0x8000] = value
    steps = [
        {"action": "load_snapshot", "path": str(directory / "program.sna")},
        *[
            {"action": "poke_byte", "addr": symbols[label], "value": value}
            for label, value in [("start_y", start), ("end_y", stop)]
        ],
        {"action": "poke_byte", "addr": 0x8FFF, "value": 0x69},
        {"action": "poke_byte", "addr": 0x9000 + length, "value": 0x96},
        {
            "action": "profile_cycles",
            "ticks": TICKS,
            "routines": [
                {
                    "name": name,
                    "ranges": [{"start": symbols[name], "end": symbols["end_" + name]}],
                }
                for name in ["main", "pixel_addr", "pixel_down"]
            ],
        },
        *[
            {
                "action": "memory_read",
                "addr": 0x9000 + offset,
                "len": min(256, length - offset),
            }
            for offset in range(0, length, 256)
        ],
        {"action": "memory_read", "addr": symbols["done"], "len": 1},
        {"action": "memory_read", "addr": 0x8FFF, "len": 1},
        {"action": "memory_read", "addr": 0x9000 + length, "len": 1},
        {"action": "memory_read", "addr": 0x8000, "len": len(code)},
        {"action": "query_cpu"},
    ]
    script = directory / "script.json"
    script.write_text(json.dumps(steps))
    rom = directory / "unused-zero.rom"
    rom.write_bytes(bytes(16384))
    report = json.loads(
        command([emulator, "--rom", str(rom), "--script", str(script)], directory)
    )
    (directory / "report.json").write_text(json.dumps(report))
    observations = report["observations"]
    profile = next(o["profile"] for o in observations if o["kind"] == "profile_cycles")
    memory = [o["bytes"] for o in observations if o["kind"] == "memory_read"]
    cpu = next(o["registers"] for o in observations if o["kind"] == "query_cpu")
    require(
        memory[-4:-1] == [[1], [0x69], [0x96]],
        "Caller incomplete, register contract failed or buffer guard changed",
    )
    # The caller changes before_de and done as well as the two setup bytes.
    for label, value in [("before_de", stop - 1), ("done", 1)]:
        offset = symbols[label] - 0x8000
        if label == "before_de":
            code[offset : offset + 2] = bytes([255, stop - 1])
        else:
            code[offset] = value
    require(
        memory[-1] == list(code), "Loaded code/state differs from the same-build image"
    )
    require(
        cpu["halt"]
        and cpu["sp"] == "$FF00"
        and not cpu["iff1"]
        and cpu["bc"] == "$A55A"
        and cpu["ix"] == f"${0x9000 + length:04X}",
        "Return state, stack, buffer extent or interrupt contract failed",
    )
    counts = profile["counts"]
    require(
        profile["clock"]["unit"] == "master-cycle"
        and profile["clock"]["rate"] == {"numerator_hz": 14000000, "denominator_hz": 1},
        "Unexpected machine clock",
    )
    require(counts["interrupt_ticks"] == 0, "Unexpected interrupt entry")
    require(report["time"] == counts["ticks"] == TICKS, "Capture duration differs")
    require(
        sum(a["ticks"] for a in counts["addresses"].values())
        + sum(
            counts[k]
            for k in [
                "interrupt_ticks",
                "halt_ticks",
                "leading_partial_ticks",
                "trailing_partial_ticks",
            ]
        )
        == TICKS,
        "Time is unaccounted for",
    )
    require(
        profile["call_tracking"]["discontinuities"] == 0
        and profile["call_tracking"]["unresolved_calls"] == 0
        and not profile["call_tracking"]["depth_limit_reached"],
        "Call tracking failed",
    )
    data = [value for block in memory[:-4] for value in block]
    require(len(data) == length, "Truncated result buffer")
    routines = {r["name"]: r for r in profile["routines"]}
    return data, routines


def check(
    data: list[int],
    start: int,
    stop: int,
    rows: list[list[int]],
    bottom_probe: bool = False,
) -> None:
    for i, y in enumerate(range(start, stop)):
        for x in range(256):
            offset = i * 1024 + x * 4
            actual = int.from_bytes(bytes(data[offset : offset + 2]), "little")
            down = int.from_bytes(bytes(data[offset + 2 : offset + 4]), "little")
            require(actual == rows[y][x // 8], f"pixel_addr mismatch at ({x},{y})")
            require(
                down
                == (
                    rows[y + 1][x // 8]
                    if y < 191
                    else (0x5800 + x // 8 if bottom_probe else 0)
                ),
                f"pixel_down mismatch at ({x},{y})",
            )


def run_case(
    directory: Path,
    assembler: str,
    emulator: str,
    pasmo: str | None,
    start: int,
    stop: int,
    include: str,
    bottom_probe: bool = False,
) -> dict[str, Any]:
    directory.mkdir(parents=True, exist_ok=True)
    caller = (ROOT / "caller.asm").read_text()
    if bottom_probe:
        require(start == 191 and stop == 192, "Bottom probe must isolate row 191")
        caller = caller.replace("jr z,bottom_row", "; deliberate out-of-contract probe")
    (directory / "caller.asm").write_text(caller)
    (directory / "bitmap-addressing.inc").write_text(include)
    symbols = assemble(directory, assembler, pasmo)
    data, routines = observe(directory, emulator, symbols, start, stop)
    check(data, start, stop, layout(), bottom_probe)
    expected = {
        "pixel_addr": (256 * (stop - start), 117 * 256 * (stop - start)),
        "pixel_down": (
            256 * sum(y < 191 or bottom_probe for y in range(start, stop)),
            256
            * sum(
                46 if y % 64 == 63 else 65 if y % 8 == 7 else 26
                for y in range(start, min(stop, 192 if bottom_probe else 191))
            ),
        ),
    }
    measured = {}
    for name, (calls, cycles) in expected.items():
        routine = routines[name]
        require(
            routine["call_cost"]["completed_calls"] == calls
            and routine["call_cost"]["incomplete_calls"] == 0,
            f"{name} did not complete every call",
        )
        require(routine["exclusive_ticks"] == cycles * 4, f"{name} timing differs")
        measured[name] = {"completed_calls": calls, "measured_t_states": cycles}
    return {
        "rows": [start, stop - 1],
        "binary_sha256": sha(directory / "program.bin"),
        "snapshot_sha256": sha(directory / "program.sna"),
        "result_bytes_sha256": hashlib.sha256(bytes(data)).hexdigest(),
        "routines": measured,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assembler", default="asm198x")
    parser.add_argument("--emulator", default="emu198x-spectrum")
    parser.add_argument("--pasmo", help="Optional installed reference assembler")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    (output / "results.json").unlink(missing_ok=True)
    assembler, emulator = tool(args.assembler), tool(args.emulator)
    pasmo = tool(args.pasmo) if args.pasmo else None
    include = (ROOT / "bitmap-addressing.inc").read_text()
    cases = []
    for start in range(0, 192, 16):
        cases.append(
            run_case(
                output / f"rows-{start:03}",
                assembler,
                emulator,
                pasmo,
                start,
                start + 16,
                include,
            )
        )
        print(f"PASS rows {start}–{start + 15}", flush=True)
    timing = [
        run_case(output / f"timing-{y}", assembler, emulator, pasmo, y, y + 1, include)
        for y in [0, 7, 63]
    ]
    bottom = run_case(
        output / "bottom-row",
        assembler,
        emulator,
        pasmo,
        191,
        192,
        include,
        bottom_probe=True,
    )
    mutations = []
    for name, old, new in [
        ("wrong-base", "or   %01000000", "or   %01100000"),
        ("wrong-row", "add  a,32", "add  a,31"),
    ]:
        require(include.count(old) == 1, "Mutation anchor must be unique")
        try:
            run_case(
                output / name,
                assembler,
                emulator,
                pasmo,
                0,
                16,
                include.replace(old, new),
            )
        except ValueError as error:
            require(
                str(error).startswith(("pixel_addr mismatch", "pixel_down mismatch")),
                f"Mutation failed for an unrelated reason: {error}",
            )
            mutations.append(
                {"mutation": name, "rejected": True, "failure": str(error)}
            )
        else:
            raise ValueError(f"Mutation {name} was accepted")
    summary = {
        "status": "passed",
        "target": "48K PAL; code $8000, buffer $9000, stack $FF00; DI",
        "method": "Asm198x RAM snapshot; exhaustive outputs; Emu198x dynamic cycle profile",
        "limits": "Synthetic unused ROM; no ROM boot, tape load, contention or hardware test. "
        "Row 191 is excluded from pixel_down calls by its contract.",
        "source_sha256": {
            p.name: sha(p)
            for p in [
                ROOT / "caller.asm",
                ROOT / "bitmap-addressing.inc",
                Path(__file__),
            ]
        },
        "tools": {
            name: {"path": str(path), "sha256": sha(Path(path))}
            for name, path in [
                ("assembler", assembler),
                ("emulator", emulator),
                *([("pasmo", pasmo)] if pasmo else []),
            ]
        },
        "pixel_inputs_checked": 192 * 256,
        "valid_next_row_pixel_inputs_checked": 191 * 256,
        "distinct_next_row_addresses_checked": 191 * 32,
        "cases": cases,
        "bottom_row_characterisation": bottom,
        "timing_path_probes": timing,
        "negative_controls": mutations,
    }
    (output / "results.json").write_text(json.dumps(summary, indent=2) + "\n")
    print(
        "PASS exhaustive outputs, register/stack contracts, cycle totals and negative controls"
    )


if __name__ == "__main__":
    main()
