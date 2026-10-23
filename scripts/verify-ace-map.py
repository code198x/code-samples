"""Run checked byte-map words through stock Jupiter Ace FORTH and keyboard."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "jupiter-ace/patterns/forth/rendering/tile-map"


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


T = load("transport", ROOT / "scripts/verify-game-loops.py")
V = load("png", ROOT / "scripts/verify-tilemaps.py")
VARIANTS = ("positive", "closed-exit", "wrong-stride", "write-without-valid")
ROWS = [
    [0, 1, 2, 3, 0, 1, 2],
    [3, 0, 1, 2, 3, 0, 1],
    [2, 3, 0, 1, 2, 3, 0],
    [1, 2, 3, 0, 1, 2, 3],
    [0, 1, 2, 3, 0, 1, 2],
]


def cases() -> list[dict]:
    result = []
    for row, data in enumerate(ROWS):
        for col, value in enumerate(data):
            result.append(
                {
                    "command": f"{col} {row} MGET",
                    "expected": [value, 1],
                    "label": f"read-{col}-{row}",
                }
            )
    for col, row in [(7, 0), (0, 5), (-1, 0), (0, -1), (255, 255)]:
        result.append(
            {
                "command": f"{col} {row} MGET",
                "expected": [0, 0],
                "label": f"outside-{col}-{row}",
            }
        )
    for value, col, row in [
        (1, 7, 0),
        (1, 0, 5),
        (1, -1, 0),
        (1, 0, -1),
        (4, 0, 0),
        (-1, 0, 0),
        (256, 0, 0),
    ]:
        result.append(
            {
                "command": f"{value} {col} {row} MSET 0 SWAP",
                "expected": [0, 0],
                "label": f"rejected-write-{value}-{col}-{row}",
            }
        )
    result += [
        {"command": "4 MFLAGS", "expected": [0, 0], "label": "invalid-property"},
        {"command": "-1 MFLAGS", "expected": [0, 0], "label": "negative-property"},
        {"command": "3 MFLAGS", "expected": [4, 1], "label": "exit-property"},
        {"command": "31 23 MXY", "expected": [1, 1], "label": "world-position"},
        {"command": "55 39 MXY", "expected": [2, 1], "label": "last-world-cell"},
        {"command": "56 0 MXY", "expected": [0, 0], "label": "outside-world"},
        {"command": "2048 0 MXY", "expected": [0, 0], "label": "large-world"},
        {"command": "-1 0 MXY", "expected": [0, 0], "label": "negative-world-x"},
        {"command": "0 -1 MXY", "expected": [0, 0], "label": "negative-world-y"},
        {"command": "3 0 0 MSET 0 SWAP", "expected": [0, 1], "label": "valid-write"},
        {"command": "0 0 MGET", "expected": [3, 1], "label": "read-back"},
        {"command": "ROOM 35 + C@ 1", "expected": [165, 1], "label": "following-guard"},
    ]
    return result


def sources() -> dict[str, str]:
    files = [
        FOLDER / n
        for n in [
            "routines.fth",
            "room.fth",
            "customise.fth",
            "demo.fth",
            "mistakes/wrong-stride.fth",
            "mistakes/write-without-valid.fth",
        ]
    ]
    files += [
        ROOT / "docs/ace-map-tools.json",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-tilemaps.py",
    ]
    return {str(p.relative_to(ROOT)): T.sha(p) for p in files}


def screen(machine) -> tuple[list[int], str]:
    raw = []
    for offset in range(0, 768, 256):
        raw += machine.call("memory_read", addr=0x2400 + offset, len=256)["bytes"]
    return raw, "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)


def enter(machine, line: str) -> None:
    answer = machine.call("type_string", text=line + "\n", settle_frames=60)
    T.require(answer["chars_typed"] == len(line) + 1, "Incomplete keyboard entry")


def value(machine, line: str) -> tuple[int, list[int]]:
    enter(machine, line + " NUMBER")
    raw, text = screen(machine)
    match = re.match(r"\s*(\d+)\s", text)
    T.require(
        match is not None and "ERROR" not in text.upper(),
        f"Numeric word did not complete: {text}",
    )
    return int(match[1]), raw


def query(machine, line: str, index: int) -> tuple[list[int], list[int]]:
    enter(machine, f"77 {line} {index} OBSERVE")
    raw, text = screen(machine)
    match = re.match(
        r"\s*CASE\s+(\d+)\s+FLAG\s+(\d+)\s+VALUE\s+(\d+)\s+STACK\s+(\d+)\s",
        text,
        re.IGNORECASE,
    )
    T.require(
        match is not None
        and "ERROR" not in text.upper()
        and int(match[1]) == index
        and int(match[4]) == 77,
        f"Word did not complete or disturbed stack: {line}: {text}",
    )
    return [int(match[3]), int(match[2])], raw


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument(
        "--firmware",
        type=Path,
        default=Path.home() / ".emu198x/roms/jupiter-ace/ace.rom",
    )
    args = p.parse_args()
    out = FOLDER / "build/verification"
    out.mkdir(parents=True, exist_ok=True)
    retained = FOLDER / "verification"
    retained.mkdir(exist_ok=True)
    (retained / "results.json").unlink(missing_ok=True)
    emulator = args.native.resolve() / "emu198x-jupiter-ace"
    firmware = args.firmware.resolve()
    locked = json.loads((ROOT / "docs/ace-map-tools.json").read_text())
    T.require(T.sha(emulator) == locked["emulator_sha256"], "Wrong released emulator")
    T.require(
        T.sha(firmware) == locked["firmware_sha256"]
        and firmware.stat().st_size == locked["firmware_bytes"],
        "Wrong stock FORTH ROM",
    )
    observations = {}
    for variant in VARIANTS:
        machine = T.Machine([str(emulator), "--mcp", "--rom", str(firmware)])

        try:
            machine.call("run_frames", frames=150)
            enter(machine, ": NUMBER CLS U. ;")
            before, before_screen = value(machine, "HERE")
            core = FOLDER / (
                "routines.fth"
                if variant in ("positive", "closed-exit")
                else f"mistakes/{variant}.fth"
            )
            for line in core.read_text().splitlines():
                enter(machine, line)
                _, text = screen(machine)
                T.require(
                    "ERROR" not in text.upper(), f"Compile error after {line}: {text}"
                )
            after_core, core_screen = value(machine, "HERE")
            for line in (FOLDER / "room.fth").read_text().splitlines():
                enter(machine, line)
            after, after_screen = value(machine, "HERE")
            ram_top, ram_screen = value(machine, "15384 @")
            T.require(ram_top == 16384, "Not the unexpanded 3 KiB Ace")
            room, _ = value(machine, "ROOM")
            flags, _ = value(machine, "FLAGS")
            if variant == "closed-exit":
                for line in (FOLDER / "customise.fth").read_text().splitlines():
                    enter(machine, line)
            enter(machine, (FOLDER / "demo.fth").read_text().splitlines()[0])
            rows = []
            enter(
                machine,
                ': OBSERVE CLS ." CASE " U. ." FLAG " U. ." VALUE " U. ." STACK " U. ;',
            )
            before_map = machine.call("memory_read", addr=room, len=36)["bytes"]
            for index, c in enumerate(cases()):
                actual, raw = query(machine, c["command"], index)
                expected = list(c["expected"])
                if variant == "closed-exit" and c["label"] == "exit-property":
                    expected = [5, 1]
                rows.append(
                    {
                        "label": c["label"],
                        "actual": actual,
                        "screen_hex": bytes(raw).hex(),
                    }
                )
                if c["label"] == "rejected-write-256-0-0":
                    unchanged = machine.call("memory_read", addr=room, len=36)["bytes"]
                if c["label"] in ("read-0-1", "exit-property"):
                    machine.call(
                        "save_screenshot", path=str(out / f"{variant}-{c['label']}.png")
                    )
                if variant in ("positive", "closed-exit"):
                    T.require(
                        actual == expected,
                        f"{variant} {c['label']}: {actual} != {expected}",
                    )
            # Put a sentinel below a real call; consume its results and recover it.
            sentinel, raw = value(machine, "77 0 0 MGET DROP DROP")
            T.require(sentinel == 77, "Caller stack prefix damaged")
            final_map = machine.call("memory_read", addr=room, len=36)["bytes"]
            final_properties = machine.call("memory_read", addr=flags, len=4)["bytes"]
            result = {
                "cases": rows,
                "room_address": room,
                "flags_address": flags,
                "before_map": before_map,
                "after_rejected_writes": unchanged,
                "final_map": final_map,
                "properties": final_properties,
                "dictionary_before": before,
                "dictionary_after": after,
                "allocation_screens": {
                    "before": bytes(before_screen).hex(),
                    "core": bytes(core_screen).hex(),
                    "after": bytes(after_screen).hex(),
                    "ram_top": bytes(ram_screen).hex(),
                },
                "dictionary_core_bytes": after_core - before,
                "dictionary_data_bytes": after - after_core,
                "ram_top": ram_top,
                "dictionary_bytes": after - before,
                "stack_sentinel": sentinel,
                "stack_screen_hex": bytes(raw).hex(),
            }
            observations[variant] = result
            print(
                "PASS completed",
                variant,
                "dictionary bytes",
                after - before,
                flush=True,
            )
        except Exception:
            machine.call("save_screenshot", path=str(out / "failure.png"))
            raise
        finally:
            machine.close()
    record = {
        "status": "passed",
        "machine": "jupiter-ace",
        "language": "forth",
        "configuration": "Unexpanded Jupiter Ace; stock FORTH ROM; actual keyboard definitions",
        "sources": sources(),
        "observations": observations,
        "emulator_sha256": T.sha(emulator),
        "firmware_sha256": T.sha(firmware),
        "limits": "ROM-executed FORTH queries and byte memory; no frame deadline, native drawing or original-hardware claim",
    }
    (retained / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print("Completed all four variants")


if __name__ == "__main__":
    main()
