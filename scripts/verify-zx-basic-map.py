"""Execute map contracts via each stock ROM's keyword keyboard; retain D_FILE."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
SYSTEMS = ("sinclair-zx80", "sinclair-zx81")
VARIANTS = ("positive", "closed-exit", "wrong-stride", "write-without-valid")
ROWS = [
    [0, 1, 2, 3, 0, 1, 2],
    [3, 0, 1, 2, 3, 0, 1],
    [2, 3, 0, 1, 2, 3, 0],
    [1, 2, 3, 0, 1, 2, 3],
    [0, 3, 2, 1, 0, 3, 2],
]


def folder(system: str) -> Path:
    return ROOT / system / "patterns/basic/rendering/tile-map"


def sources(system: str) -> dict:
    paths = sorted(folder(system).glob("*.bas")) + sorted(
        (folder(system) / "mistakes").glob("*.bas")
    )
    paths += [Path(__file__), ROOT / "scripts/verify-game-loops.py"]
    return {str(p.relative_to(ROOT)): T.sha(p) for p in paths}


def cases(system: str) -> list[dict]:
    result = []

    def add(label: str, op: int, c: float, r: float, v: float, expected: list) -> None:
        result.append(
            {"label": label, "arguments": [op, c, r, v], "expected": expected}
        )

    for r, row in enumerate(ROWS):
        for c, tile in enumerate(row):
            add(f"read-{c}-{r}", 0, c, r, 0, [1, tile, -1, c, r])
    for c, r in [(-1, 0), (0, -1), (7, 0), (0, 5), (32767, 0)]:
        add(f"outside-{c}-{r}", 0, c, r, 0, [0, -1, -1, c, r])
    for c, r, v in [(7, 0, 1), (-1, 0, 1), (0, 5, 1), (0, 0, -1), (0, 0, 4)]:
        add(
            f"reject-write-{c}-{r}-{v}",
            1,
            c,
            r,
            v,
            [0, -1 if 0 <= v <= 3 else 77, -1, c, r],
        )
    for tile in range(4):
        add(f"property-{tile}", 2, 0, 0, tile, [1, tile, [0, 1, 2, 4][tile], 0, 0])
    for tile in [-1, 4]:
        add(f"bad-property-{tile}", 2, 0, 0, tile, [0, tile, -1, 0, 0])
    for x, y in [(0, 0), (7, 7), (8, 8), (55, 39), (56, 0), (0, 40), (-1, 0), (0, -1)]:
        c, r = (int(x // 8), int(y // 8)) if min(x, y) >= 0 else (-1, -1)
        valid = 0 <= c < 7 and 0 <= r < 5
        add(
            f"world-{x}-{y}",
            3,
            x,
            y,
            0,
            [int(valid), ROWS[r][c] if valid else -1, -1, c, r],
        )
    if system.endswith("81"):
        for c, r in [(0.5, 0), (0, 0.5)]:
            add(f"fraction-read-{c}-{r}", 0, c, r, 0, [0, -1, -1, c, r])
        add("fraction-write", 1, 0, 0, 1.5, [0, 77, -1, 0, 0])
        add("fraction-property", 2, 0, 0, 1.5, [0, 1.5, -1, 0, 0])
    for size in [0, -1]:
        add(f"bad-size-{size}", 4, 0, 0, size, [0, -1, -1, -1, -1])
    add("size-three", 4, 6, 3, 3, [1, 1, -1, 2, 1])
    if system.endswith("81"):
        add("fraction-size", 4, 0, 0, 1.5, [0, -1, -1, -1, -1])
        add("fraction-world", 3, 7.9, 8.1, 0, [1, 3, -1, 0, 1])
    if system.endswith("81"):
        add("world-too-large", 3, 32768, 0, 0, [0, -1, -1, -1, -1])
    add("write-valid", 1, 0, 0, 3, [1, 3, -1, 0, 0])
    add("readback", 0, 0, 0, 0, [1, 3, -1, 0, 0])
    return result


class Keyboard:
    def __init__(self, machine: object, system: str):
        self.machine = machine
        self.system = system
        self.expected_lines = []
        self.keys = {
            "LET": "k" if system.endswith("80") else "l",
            "CLS": "c" if system.endswith("80") else "v",
            "PRINT": "o" if system.endswith("80") else "p",
            "GOSUB": "v" if system.endswith("80") else "h",
            "RETURN": "b" if system.endswith("80") else "y",
            "STOP": "s",
            "DIM": "d",
            "FOR": "f",
            "NEXT": "n",
            "INPUT": "i",
            "GOTO": "g",
            "IF": "u",
        }

    def key(self, name: str) -> None:
        self.machine.call("press_key", key=name, hold_frames=10)
        self.machine.call("run_frames", frames=30)

    def chord(self, key: str) -> None:
        self.machine.call("press_keys", keys=["shift", key], hold_frames=10)
        self.machine.call("run_frames", frames=30)

    def literal(self, text: str) -> None:
        for ch in text.lower():
            if ch.isalnum() or ch == " ":
                self.key("space" if ch == " " else ch)
            else:
                self.machine.call(
                    "type_string", text=ch, hold_frames=10, settle_frames=30
                )
                self.machine.call("run_frames", frames=30)

    def expression(self, text: str) -> None:
        if " THEN " in text:
            condition, statement = text.split(" THEN ")
            self.expression(condition)
            self.chord("3")
            self.statement(statement)
        elif " TO " in text:
            start, end = text.split(" TO ")
            self.expression(start)
            self.chord("4")
            self.expression(end)
        elif "INT " in text:
            start, end = text.split("INT ", 1)
            self.literal(start)
            self.chord("enter")
            self.key("r")
            self.expression(end)
        else:
            self.literal(text)

    def statement(self, text: str) -> None:
        keyword, *argument = text.split(maxsplit=1)
        if keyword == "STOP" and self.system.endswith("81"):
            self.chord("a")
        else:
            self.key(self.keys[keyword])
        if argument:
            self.expression(argument[0])

    def line(self, text: str) -> None:
        number, statement = text.split(maxsplit=1)
        self.literal(number)
        self.statement(statement)
        self.key("enter")
        # Expanded ZX81's full display redraw outlasts a single key gap.
        # Wait for the ROM to finish inserting/listing the line before typing.
        if self.system.endswith("81"):
            self.machine.call("run_frames", frames=600)
            self.expected_lines.append(int(number))
            raw = read(
                self.machine,
                0x407D,
                int.from_bytes(bytes(read(self.machine, 0x400C, 2)), "little") - 0x407D,
            )
            actual = program_lines(raw)
            T.require(
                actual == sorted(self.expected_lines),
                f"ROM line-entry mismatch: expected {number}, got {actual}",
            )


def read(machine: object, addr: int, size: int) -> list:
    return [
        b
        for offset in range(0, size, 128)
        for b in machine.call(
            "memory_read", addr=addr + offset, len=min(128, size - offset)
        )["bytes"]
    ]


def program_lines(raw: list) -> list[int]:
    lines = []
    offset = 0
    while offset + 4 <= len(raw):
        number = int.from_bytes(bytes(raw[offset : offset + 2]), "big")
        size = int.from_bytes(bytes(raw[offset + 2 : offset + 4]), "little")
        T.require(
            size > 0 and offset + 4 + size <= len(raw), "Truncated ZX81 program line"
        )
        T.require(raw[offset + 3 + size] == 118, "Missing ZX81 line terminator")
        lines.append(number)
        offset += 4 + size
    T.require(offset == len(raw), "Unparsed ZX81 program bytes")
    return lines


def display(machine: object, system: str) -> tuple[int, list, str]:
    pointer = read(machine, 0x400C, 2)
    addr = int.from_bytes(bytes(pointer), "little")
    raw = read(machine, addr, 793)
    # Native character codes differ: ZX80 minus is 18, ZX81 minus is 22.
    chars = {
        0: " ",
        11: '"',
        26: ",",
        118: "\n",
        **{28 + i: str(i) for i in range(10)},
        **{38 + i: chr(65 + i) for i in range(26)},
    }
    chars[18 if system.endswith("80") else 22] = "-"
    chars[27] = "."
    text = "".join(chars.get(b, "?") for b in raw)
    return addr, raw, text


def harness(system: str) -> str:
    base = 0 if system.endswith("80") else 1
    return (
        "\n".join(
            [
                "10 GOSUB 2000",
                "20 LET Z=0",
                "30 LET F=-1",
                "35 LET T=77",
                "40 INPUT A",
                "50 INPUT C",
                "60 INPUT R",
                "70 INPUT V",
                "75 LET S=8",
                "77 IF A=4 THEN LET S=V",
                "80 LET X=C",
                "90 LET Y=R",
                "100 IF A=0 THEN GOSUB 1000",
                "110 IF A=1 THEN GOSUB 1100",
                "120 IF A=2 THEN LET T=V",
                "130 IF A=2 THEN GOSUB 1200",
                "140 IF A>2 THEN GOSUB 1300",
                "150 CLS",
                '160 PRINT Z;",";E;",";T;",";F',
                '170 PRINT C;",";R',
                f"180 FOR J={base} TO {35 + base}",
                "190 PRINT M(J);",
                "200 NEXT J",
                "210 PRINT",
                "220 LET Z=Z+1",
                "230 GOTO 30",
            ]
        )
        + "\n"
    )


def run(system: str, native: Path, firmware_root: Path, only: str | None) -> None:
    p = folder(system)
    out = p / "verification"
    out.mkdir(exist_ok=True)
    executable = native / ("emu198x-" + system)
    firmware = (
        firmware_root / system / ("zx80.rom" if system.endswith("80") else "zx81.rom")
    )
    result = {
        "status": "passed",
        "machine": system,
        "language": "basic",
        "configuration": "Stock BASIC ROM, PAL, 16384 bytes RAM, keyword keyboard entry",
        "ram_bytes": 16384,
        "sources": sources(system),
        "emulator_sha256": T.sha(executable),
        "firmware_sha256": T.sha(firmware),
        "variants": {},
        "limits": "No stock 1 KiB, native drawing, original-hardware or frame-budget claim.",
    }
    for variant in [only] if only else (*VARIANTS, "demo"):
        machine = None
        try:
            machine = T.Machine(
                [
                    str(executable),
                    "--mcp",
                    "--rom",
                    str(firmware),
                    "--ram-bytes",
                    "16384",
                ]
            )
            machine.call("run_frames", frames=150)
            kb = Keyboard(machine, system)
            routine = p / (
                "mistakes/" + variant + ".bas"
                if variant in ("wrong-stride", "write-without-valid")
                else "routines.bas"
            )
            room = (p / "room.bas").read_text()
            if variant == "closed-exit":
                room = room.replace(
                    (p / "customise.bas").read_text().replace("=5", "=4"),
                    (p / "customise.bas").read_text(),
                )
            program = (
                ((p / "demo.bas").read_text() if variant == "demo" else harness(system))
                + routine.read_text()
                + room
            )
            for i, line in enumerate(program.splitlines()):
                kb.line(line)
                if i % 25 == 0:
                    print(system, variant, "entered", i, flush=True)
            kb.key("r")
            kb.key("enter")
            machine.call("run_frames", frames=200)
            if system.endswith("81"):
                machine.call("run_frames", frames=2400)
            if variant == "demo":
                addr, raw, text = display(machine, system)
                T.require(
                    re.match(
                        r"\nTILE 3\s*\nFLAGS 4\s*\nCHANGED 3\s*\nWORLD 6,4\s*\nTILE 2",
                        text,
                    )
                    is not None,
                    f"Demo did not complete: {text[:200]!r}",
                )
                result["demo"] = {
                    "display_address": addr,
                    "display_hex": bytes(raw).hex(),
                }
                machine.call("save_screenshot", path=str(out / "demo.png"))
                continue
            observations = []
            for index, case in enumerate(cases(system)):
                for value in case["arguments"]:
                    kb.literal(str(value))
                    kb.key("enter")
                # A full-map PRINT takes materially longer in ZX81 SLOW mode.
                # Poll the indexed, complete result rather than accepting a
                # transport success or a still-changing partial display.
                for _ in range(24):
                    machine.call("run_frames", frames=250)
                    addr, raw, text = display(machine, system)
                    match = re.match(
                        r"\n(\d+),([\d.-]+),([\d.-]+),([\d.-]+)\s*\n([\d.-]+),([\d.-]+)\s*\n([0-9\s]+)",
                        text,
                    )
                    map_text = "".join(match[7].split()) if match else ""
                    if match and int(match[1]) == index and len(map_text) == 36:
                        break
                else:
                    raise AssertionError(
                        f"{system} {variant} {index}: no completed result within 6000 frames: {text[:170]!r}"
                    )
                actual = [float(match[i]) for i in range(2, 7)]
                if system.endswith("81"):
                    machine.call("run_frames", frames=600)
                observations.append(
                    {
                        "label": case["label"],
                        "actual": actual,
                        "map": [int(c) for c in map_text],
                        "display_address": addr,
                        "display_hex": bytes(raw).hex(),
                    }
                )
                if case["label"] in (
                    "read-0-1",
                    "reject-write-7-0-1",
                    "property-3",
                    "world-55-39",
                    "readback",
                ):
                    machine.call(
                        "save_screenshot",
                        path=str(out / f"{variant}-{case['label']}.png"),
                    )
                print(system, variant, index, case["label"], actual, flush=True)
            result["variants"][variant] = {
                "cases": observations,
                "program_sha256": hashlib.sha256(program.encode()).hexdigest(),
                "server": machine.server.get("serverInfo"),
            }
        except Exception:
            if machine and machine.process.poll() is None:
                addr, raw, text = display(machine, system)
                print("FAILED DISPLAY", addr, repr(text[:500]), flush=True)
                machine.call("save_screenshot", path=str(out / "failure.png"))
            raise
        finally:
            if machine:
                machine.close()
    (out / ("results.json" if not only else f"{only}.json")).write_text(
        json.dumps(result, indent=2) + "\n"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--system", choices=SYSTEMS)
    parser.add_argument("--variant", choices=(*VARIANTS, "demo"))
    args = parser.parse_args()
    for system in [args.system] if args.system else SYSTEMS:
        run(system, args.native.resolve(), args.firmware_root.resolve(), args.variant)


if __name__ == "__main__":
    main()
