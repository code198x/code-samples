"""Execute library routines against independent byte, text and rectangle oracles.

Synthetic ROM with test glyphs, DI and uncontended 48K RAM. This is CPU/routine evidence,
not ROM boot, keyboard input, video timing or original-hardware qualification.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATHS = {
    "keyboard": "sinclair-zx-spectrum/patterns/assembly/input/keyboard-reading/keyboard-code.inc",
    "characters": "sinclair-zx-spectrum/patterns/assembly/rendering/character-printing/characters.inc",
    "attributes": "sinclair-zx-spectrum/patterns/assembly/rendering/attribute-writing/attributes.inc",
    "masked": "sinclair-zx-spectrum/patterns/assembly/rendering/masked-sprites/masked.inc",
    "numbers": "sinclair-zx-spectrum/patterns/assembly/rendering/numeric-display/numeric.inc",
    "animation": "cross-platform/patterns/rendering/sprite-animation/z80.inc",
}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def command(args: list[str], cwd: Path) -> str:
    result = subprocess.run(
        args, cwd=cwd, capture_output=True, text=True, timeout=45, check=False
    )
    require(result.returncode == 0, result.stderr or result.stdout)
    return result.stdout


def screen_address(y: int, column: int) -> int:
    # Walk the physical layout rather than transcribing pixel_down's operations.
    address = 0x4000
    for third in range(3):
        for scan in range(8):
            for row in range(8):
                if y == third * 64 + row * 8 + scan:
                    return address + column
                address += 32
    raise ValueError("Invalid display row")


def execute(
    folder: Path,
    source: str,
    reads: list[tuple[int, int]],
    args: argparse.Namespace,
    inputs: list[str] | None = None,
) -> list[list[int]]:
    folder.mkdir(parents=True, exist_ok=True)
    (folder / "caller.asm").write_text(source)
    for extra in ["bitmap-addressing.inc"]:
        shutil.copy2(
            ROOT
            / "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing"
            / extra,
            folder / extra,
        )
    command(
        [
            args.assembler,
            "--dialect",
            "pasmo",
            "--cpu",
            "z80",
            "--sym=caller.sym",
            "--sna",
            "caller.asm",
            "-o",
            "caller.sna",
        ],
        folder,
    )
    symbols = {
        name: int(value, 16)
        for name, value in re.findall(
            r"^(\w+) = \$([0-9a-fA-F]+)$",
            (folder / "caller.sym").read_text(),
            re.MULTILINE,
        )
    }
    require(
        "done" in symbols and symbols["done"] < 0x9000,
        "Missing/overlapping completion marker",
    )
    rom = bytearray(16384)
    for char in range(32, 128):
        for row in range(8):
            rom[0x3C00 + char * 8 + row] = (char * 17 + row * 31) & 255
    (folder / "synthetic-fixture.rom").write_bytes(rom)
    steps = [
        {"action": "load_snapshot", "path": str(folder / "caller.sna")},
        {
            "action": "input",
            "events": [
                {"Key": {"name": key, "pressed": True}} for key in (inputs or [])
            ],
        },
        {"action": "profile_cycles", "ticks": 14_000_000, "routines": []},
        {"action": "memory_read", "addr": symbols["done"], "len": 1},
    ]
    lengths = []
    for start, length in reads:
        lengths.append((length + 255) // 256)
        for offset in range(0, length, 256):
            steps.append(
                {
                    "action": "memory_read",
                    "addr": start + offset,
                    "len": min(256, length - offset),
                }
            )
    steps.append({"action": "query_cpu"})
    (folder / "script.json").write_text(json.dumps(steps))
    report = json.loads(
        command(
            [
                args.emulator,
                "--rom",
                str(folder / "synthetic-fixture.rom"),
                "--script",
                str(folder / "script.json"),
            ],
            folder,
        )
    )
    (folder / "observations.json").write_text(json.dumps(report, indent=2) + "\n")
    memory = [o["bytes"] for o in report["observations"] if o["kind"] == "memory_read"]
    cpu = next(
        o["registers"] for o in report["observations"] if o["kind"] == "query_cpu"
    )
    require(
        memory.pop(0) == [0xCA], "Routine did not finish within the instruction budget"
    )
    require(
        cpu["halt"] and cpu["sp"] == "$FF00" and not cpu["iff1"],
        "Caller stack/interrupt/return contract failed",
    )
    result = []
    for count in lengths:
        result.append([value for block in memory[:count] for value in block])
        del memory[:count]
    return result


def caller(body: str, routine: str, declarations: str = "") -> str:
    return f"""org $8000
main:
    di
    ld sp,$ff00
{body}
    ld a,$ca
    ld (done),a
    halt
    jr $
done: defb 0
{routine}
{declarations}
    end main
"""


def keyboard(folder: Path, code: str, args: argparse.Namespace) -> int:
    reader = (
        ROOT
        / "sinclair-zx-spectrum/patterns/assembly/framework/input-to-sound/input.inc"
    ).read_text()
    body = "    call read_keyboard\n    ld ($b000),a\n    ld a,(controls)\n    ld ($b001),a\n    ld a,(key_pressed)\n    ld ($b002),a"
    keys = ["q", "a", "o", "p", "space"]
    for mask in range(32):
        actual = execute(
            folder / str(mask),
            caller(body, code + "\n" + reader),
            [(0xB000, 3)],
            args,
            inputs=[key for bit, key in enumerate(keys) if mask & (1 << bit)],
        )[0]
        priority = next((n + 1 for n in range(5) if mask & (1 << n)), 0)
        require(
            actual == [priority, mask, priority],
            f"Keyboard priority/held sample mismatch for mask {mask}",
        )
    return 32


def characters(folder: Path, code: str, args: argparse.Namespace) -> int:
    body = """    ld b,0
next_row:
    ld c,0
next_column:
    ld a,(glyph)
    call print_char
    inc a
    cp 128
    jr c,save_glyph
    ld a,32
save_glyph:
    ld (glyph),a
    inc c
    ld a,c
    cp 32
    jr c,next_column
    inc b
    ld a,b
    cp 24
    jr c,next_row"""
    actual = execute(
        folder / "all-cells",
        caller(body, code, "glyph: defb 32"),
        [(0x4000, 6144)],
        args,
    )[0]
    expected = [0] * 6144
    for y in range(24):
        for x in range(32):
            char = 32 + (y * 32 + x) % 96
            for scan in range(8):
                expected[screen_address(y * 8 + scan, x) - 0x4000] = (
                    char * 17 + scan * 31
                ) & 255
    require(actual == expected, "Character bitmap mismatch")
    for number, (row, col, text) in enumerate(
        [(7, 30, "ABCD"), (23, 31, "Z"), (24, 0, "A"), (0, 32, "A")]
    ):
        body = f"    ld hl,$4000\n    ld (hl),0\n    ld de,$4001\n    ld bc,6911\n    ldir\n    ld b,{row}\n    ld c,{col}\n    ld hl,message\n    call print_string"
        actual = execute(
            folder / f"string-{number}",
            caller(body, code, 'message: defm "' + text + '"\n defb 0'),
            [(0x4000, 6912)],
            args,
        )[0]
        expected = [0] * 6912
        if row < 24 and col < 32:
            for n, char in enumerate(text[: 32 - col]):
                for scan in range(8):
                    expected[screen_address(row * 8 + scan, col + n) - 0x4000] = (
                        ord(char) * 17 + scan * 31
                    ) & 255
        require(actual == expected, "Clipped string bitmap mismatch")
    return 772


def attributes(folder: Path, code: str, args: argparse.Namespace) -> int:
    cases = [(2, 3, 3, 4), (0, 0, 24, 32), (23, 31, 1, 1), (7, 7, 0, 4), (7, 7, 4, 0)]
    for index, (row, col, height, width) in enumerate(cases):
        body = f"""    ld hl,$57ff
    ld (hl),$55
    ld de,$5800
    ld bc,770
    ldir
    ld b,{row}
    ld c,{col}
    ld d,{height}
    ld e,{width}
    ld a,$47
    or a
    call fill_attributes
    ld ($b000),bc
    ld ($b002),de
    push af
    pop hl
    ld ($b004),hl"""
        actual, registers = execute(
            folder / str(index), caller(body, code), [(0x57FF, 770), (0xB000, 6)], args
        )
        require(
            registers == [col, row, width, height, 4, 0x47],
            "Rectangle register preservation failed",
        )
        expected = [0x55] * 770
        for y in range(row, row + height):
            for x in range(col, col + width):
                expected[1 + y * 32 + x] = 0x47
        require(
            actual == expected,
            f"Attribute rectangle mismatch: {row, col, height, width}",
        )
    return len(cases)


def masked(folder: Path, code: str, args: argparse.Namespace) -> int:
    cases = [(7, 2, 3), (63, 29, 3), (127, 0, 3), (189, 30, 3)]
    for index, (y, column, height) in enumerate(cases):
        pairs = [
            value
            for row in range(height)
            for value in (0x0F, 0xA0 | row, 0xF0, 0x08 | row)
        ]
        body = f"""    ld hl,$4000
    ld (hl),$55
    ld de,$4001
    ld bc,6143
    ldir
    ld de,{screen_address(y, column)}
    ld hl,sprite_data
    ld c,{height}
    call draw_sprite"""
        declaration = (
            "SPRITE_W equ 2\nsprite_data: defb "
            + ",".join(map(str, pairs))
            + '\ninclude "bitmap-addressing.inc"'
        )
        actual = execute(
            folder / str(index), caller(body, code, declaration), [(0x4000, 6144)], args
        )[0]
        expected = [0x55] * 6144
        for dy in range(height):
            for dx in range(2):
                mask, image = pairs[(dy * 2 + dx) * 2 : (dy * 2 + dx) * 2 + 2]
                expected[screen_address(y + dy, column + dx) - 0x4000] = (
                    0x55 & mask
                ) | image
        require(
            actual == expected, f"Masked sprite footprint mismatch: {y, column, height}"
        )
    return len(cases)


SINK = """print_char:
    push hl
    ld hl,(sink_ptr)
    ld (hl),a
    inc hl
    ld (sink_ptr),hl
    pop hl
    ret
sink_ptr: defw $b000
case_value: defw 0
score_bcd: defb 0
"""


def numbers(folder: Path, code: str, args: argparse.Namespace) -> int:
    for digits, limit, routine in [
        (2, 100, "print_two_digits"),
        (3, 1000, "print_three_digits"),
    ]:
        load = "ld a,(case_value)" if digits == 2 else "ld hl,(case_value)"
        body = f"""    ld ix,$c000
next_number:
    ld b,10
    ld c,3
    {load}
    call {routine}
    ld (ix+0),c
    inc ix
    ld hl,(case_value)
    inc hl
    ld (case_value),hl
    ld de,{limit}
    or a
    sbc hl,de
    jr nz,next_number"""
        text, columns = execute(
            folder / str(digits),
            caller(body, code, SINK),
            [(0xB000, digits * limit), (0xC000, limit)],
            args,
        )
        expected = "".join(f"{value:0{digits}d}" for value in range(limit)).encode()
        require(bytes(text) == expected, f"{digits}-digit character sequence mismatch")
        require(
            columns == [3 + digits] * limit,
            f"{digits}-digit routine did not return the advanced column",
        )
    return 1100


def animation(folder: Path, code: str, args: argparse.Namespace) -> int:
    declaration = """ANIM_DELAY equ 6
ANIM_LENGTH equ 4
anim_counter: defb 5
anim_frame: defb 2
sprite_index: defb 2
    org $90fe
walk_frames: defb 0,1,2,1
"""
    body = """    ld a,$ee
    ld ($9001),a
    call update_animation
    ld ($b000),a"""
    actual = execute(folder, caller(body, code, declaration), [(0xB000, 1)], args)[0]
    require(actual == [1], "Animation lookup lost page carry")
    body_parts = []
    expected = []
    frames = [0, 1, 2, 1]
    for frame in range(4):
        for counter in range(6):
            offset = len(expected)
            body_parts.append(
                f"    ld a,{frame}\n    ld (anim_frame),a\n    ld a,{counter}\n    ld (anim_counter),a\n    ld a,{frames[frame]}\n    ld (sprite_index),a\n    call update_animation\n    ld a,(anim_frame)\n    ld (${0xB000 + offset:04x}),a\n    ld a,(anim_counter)\n    ld (${0xB001 + offset:04x}),a\n    ld a,(sprite_index)\n    ld (${0xB002 + offset:04x}),a"
            )
            target = (frame + 1) % 4 if counter == 5 else frame
            expected.extend(
                [target, 0 if counter == 5 else counter + 1, frames[target]]
            )
    actual = execute(
        folder / "phases",
        caller("\n".join(body_parts), code, declaration),
        [(0xB000, len(expected))],
        args,
    )[0]
    require(actual == expected, "Animation counter/phase sequence mismatch")
    return 25


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assembler", default="asm198x")
    parser.add_argument("--emulator", default="emu198x-spectrum")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--only", choices=PATHS)
    parser.add_argument(
        "--expect-rejection",
        action="store_true",
        help="Characterise an unfixed source; never records it as passing",
    )
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    target = args.output / "results.json"
    target.unlink(missing_ok=True)
    results = []
    for name, rel in PATHS.items():
        if args.only and args.only != name:
            continue
        path = ROOT / rel
        try:
            count = globals()[name](args.output / name, path.read_text(), args)
        except ValueError as error:
            if not args.expect_rejection:
                raise
            expected = {
                "attributes": "Routine did not finish",
                "masked": "Masked sprite footprint mismatch",
                "numbers": "2-digit routine did not return",
                "animation": "Animation lookup lost page carry",
            }
            require(
                str(error).startswith(expected[name]),
                f"Unrelated regression failure: {error}",
            )
            results.append(
                {
                    "routine": name,
                    "status": "rejected",
                    "failure": str(error),
                    "source": rel,
                    "source_sha256": sha(path),
                }
            )
            print("REJECTED", name, str(error), flush=True)
        else:
            require(
                not args.expect_rejection, f"{name}: regression unexpectedly passed"
            )
            results.append(
                {
                    "routine": name,
                    "status": "passed",
                    "cases": count,
                    "source": rel,
                    "source_sha256": sha(path),
                }
            )
            print("PASS", name, count, flush=True)
    require(bool(results), "No routines executed")
    report = {
        "status": "regressions-characterised" if args.expect_rejection else "passed",
        "cases": results,
        "observer_sha256": sha(Path(__file__)),
        "tools": {
            name: {
                "sha256": sha(Path(shutil.which(value) or value)),
                "name": Path(value).name,
            }
            for name, value in [
                ("assembler", args.assembler),
                ("emulator", args.emulator),
            ]
        },
        "input_dependency_sha256": sha(
            ROOT
            / "sinclair-zx-spectrum/patterns/assembly/framework/input-to-sound/input.inc"
        ),
        "bitmap_dependency_sha256": sha(
            ROOT
            / "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc"
        ),
        "limits": __doc__,
    }
    target.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
