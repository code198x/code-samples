"""Execute scrolling and sprite routines; retain bounded machine evidence.

Firmware remains local. Routine checks compare complete memory spans with independent
expectations. Caller captures establish a running scene, not tear-free original
hardware, every timing standard, or a worst-case frame budget.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SP = ROOT / "sinclair-zx-spectrum/patterns/assembly/rendering/software-scrolling"
NS = (
    ROOT
    / "nintendo-entertainment-system/patterns/assembly/rendering/nametable-scrolling"
)
NO = NS.parent / "multi-sprite-oam"
BB = ROOT / "bbc-micro/patterns/assembly/rendering/masked-sprites"


def module(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


T = module("transport", ROOT / "scripts/verify-game-loops.py")
Z = module("z80", ROOT / "scripts/verify-z80-library-routines.py")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def run(command: list[str], cwd: Path) -> None:
    p = subprocess.run(
        command, cwd=cwd, capture_output=True, text=True, timeout=60, check=False
    )
    require(p.returncode == 0, p.stdout + p.stderr)


def read(machine: Any, address: int, count: int) -> bytes:
    return b"".join(
        bytes(
            machine.call("memory_read", addr=address + i, len=min(256, count - i))[
                "bytes"
            ]
        )
        for i in range(0, count, 256)
    )


def spectrum(args: argparse.Namespace, out: Path, broken: bool = False) -> int:
    code = (SP / "scroll.inc").read_text()
    if broken:
        code = code.replace("    rra ", "    or a ; ")
    code += "\n" + (SP.parent / "bitmap-addressing/bitmap-addressing.inc").read_text()
    initial = bytes((i * 37 + i // 29 + 19) % 256 for i in range(6144))
    cases = [
        (0, 0, 1),
        (0, 1, 1),
        (63, 2, 1),
        (64, 64, 1),
        (127, 2, 2),
        (191, 1, 8),
        (0, 192, 1),
    ]
    for n, (top, height, steps) in enumerate(cases):
        edge = bytes((i * 17 + 1) % 256 for i in range(height))
        body = "    ld hl,initial\n    ld de,$4000\n    ld bc,6144\n    ldir\n"
        for _ in range(steps):
            body += f"    ld hl,edge\n    ld d,{top}\n    ld b,{height}\n    call scroll_band_left\n"
        # Inputs and a page-end canary must survive. Caller helper checks stack.
        data = (
            "org $9000\ninitial: defb "
            + ",".join(map(str, initial))
            + "\norg $b100\nedge: defb "
            + ",".join(map(str, edge + b"\xa7"))
        )
        actual = Z.execute(
            out / str(n),
            Z.caller(body, code, data),
            [(0x4000, 6144), (0xB100, len(edge) + 1)],
            argparse.Namespace(assembler=args.assembler, emulator=args.spectrum),
        )
        expected = bytearray(initial)
        for _ in range(steps):
            for y in range(top, top + height):
                addr = Z.screen_address(y, 0) - 0x4000
                old = int.from_bytes(expected[addr : addr + 32], "big")
                shifted = ((old << 1) | (edge[y - top] & 1)) & ((1 << 256) - 1)
                expected[addr : addr + 32] = shifted.to_bytes(32, "big")
        require(
            bytes(actual[0]) == expected,
            f"Spectrum bitmap mismatch for {(top, height, steps)}",
        )
        require(
            bytes(actual[1]) == edge + b"\xa7", "Spectrum edge source/canary changed"
        )
    return len(cases)


def nes_fixture(
    args: argparse.Namespace, out: Path, count: int, first: int, broken: bool = False
) -> None:
    out.mkdir(parents=True, exist_ok=True)
    # Same independent generated inputs on every guest, including inactive and hidden rows.
    arrays = {
        "x": bytes((i * 13 + 7) % 256 for i in range(64)),
        "y": bytes(244 if i % 11 == 0 else (i * 7) % 239 for i in range(64)),
        "tile": bytes((i + 3) % 256 for i in range(64)),
        "attr": bytes((i % 4) | ((i % 2) * 64) for i in range(64)),
        "active": bytes(int(i % 5 != 0) for i in range(64)),
    }
    code = (NO / "oam.inc").read_text()
    if broken:
        code = code.replace(
            "    sta oam_buffer,y\n    iny\n    lda obj_x,x",
            "    nop\n    iny\n    lda obj_x,x",
        )
    text = '.segment "HEADER"\n.byte "NES",$1a,2,1,1,0\n.byte 0,0,0,0,0,0,0,0\n.segment "BSS"\n'
    for label in [
        "object_count",
        "first_object",
        "oam_used",
        "oam_status",
        "objects_left",
        "object_index",
        "scroll_x",
        "scroll_y",
        "nametable",
        "ppu_ctrl_shadow",
    ]:
        text += label + ": .res 1\n"
    for label in arrays:
        text += "obj_" + label + ": .res 64\n"
    text += 'oam_buffer=$0200\n.segment "CODE"\nreset:\n sei\n cld\n ldx #$ff\n txs\n lda #0\n sta $2000\n sta $2001\n sta $07ff\n ldx #0\n lda #$a5\nseed_oam:\n sta $0200,x\n inx\n bne seed_oam\n ldx #0\ncopy_inputs:\n'
    for label in arrays:
        text += f" lda data_{label},x\n sta obj_{label},x\n"
    text += (
        f" inx\n cpx #64\n bne copy_inputs\n lda #{count}\n sta object_count\n lda #{first}\n sta first_object\n jsr build_oam\n php\n pla\n sta $07fd\n lda oam_used\n sta $07fc\n lda oam_status\n sta $07fb\n jsr advance_priority\n lda first_object\n sta $07fa\n lda #255\n sta scroll_x\n lda #2\n sta nametable\n jsr scroll_right\n lda scroll_x\n sta $07e0\n lda nametable\n sta $07e1\n lda #$ca\n sta $07ff\nhold: jmp hold\n"
        + code
        + "\n"
        + (NS / "scroll.inc").read_text()
        + "\n"
    )
    for label, data in arrays.items():
        text += f"data_{label}: .byte " + ",".join(map(str, data)) + "\n"
    text += '.segment "VECTORS"\n.word hold,reset,hold\n.segment "CHARS"\n.res 8192,0\n'
    (out / "fixture.asm").write_text(text)
    run(
        [
            args.assembler,
            "--dialect",
            "ca65",
            "fixture.asm",
            "--sym=fixture.sym",
            "-o",
            "fixture.nes",
        ],
        out,
    )
    m = T.Machine(
        [args.nes, "--mcp", "--rom", str(out / "fixture.nes"), "--region", "ntsc"]
    )
    try:
        m.call("run_frames", frames=10)
        require(read(m, 0x07FF, 1) == b"\xca", "NES caller did not finish")
        actual = read(m, 0x0200, 256)
        result = read(m, 0x07FA, 4)
        selected = []
        if count <= 64 and count:
            start = first if first < count else 0
            selected = [
                i
                for i in [(start + j) % count for j in range(count)]
                if arrays["active"][i] and arrays["y"][i] < 239
            ]
        expected = bytearray([0xA5] * 256)
        for i in range(64):
            expected[4 * i] = 255
        # Hidden entries only promise Y; initialise other bytes to guest RAM's zero.
        for slot, i in enumerate(selected):
            expected[4 * slot : 4 * slot + 4] = bytes(
                [arrays["y"][i], arrays["tile"][i], arrays["attr"][i], arrays["x"][i]]
            )
        require(actual == expected, f"NES OAM mismatch count={count},first={first}")
        require(
            read(m, 0x07E0, 2) == bytes([0, 3]),
            "NES horizontal wrap changed the vertical nametable bit",
        )
        next_first = (start + 1) % count if count and count <= 64 else 0
        require(
            result[0] == next_first
            and result[1] == int(count > 64)
            and result[2] == len(selected)
            and result[3] & 1 == int(count > 64),
            "NES count/status/rotation contract failed",
        )
        sym = T.symbols(out / "fixture.sym")
        for label, data in arrays.items():
            require(
                read(m, sym["obj_" + label], 64) == data, "NES object source changed"
            )
        (out / "observations.json").write_text(
            json.dumps(
                {
                    "count": count,
                    "first": first,
                    "result": list(result),
                    "oam": list(actual),
                },
                indent=2,
            )
            + "\n"
        )
    finally:
        m.close()


def bbc(args: argparse.Namespace, out: Path, broken: bool = False) -> int:
    out.mkdir(parents=True, exist_ok=True)
    code = (BB / "masked.inc").read_text()
    if broken:
        code = code.replace("    and mask_byte", "    ora mask_byte")
    addresses = [0x5800, 0x5808, 0x5938, 0x5940, 0x7FF8]
    bg = bytes([0x13, 0xA5, 0xFF, 0, 0x81, 0x24, 0x42, 0x7E])
    shape = bytes(
        [
            0xE7,
            0x18,
            0xC3,
            0x3C,
            0x81,
            0x7E,
            0x24,
            0xDB,
            0,
            0xFF,
            0xA5,
            0x5A,
            0xDB,
            0x24,
            0xFF,
            0,
        ]
    )
    text = "*=$3000\nstart:\n cld\n cli\n lda #<shape\n sta pairs_ptr\n lda #>shape\n sta pairs_ptr+1\n"
    for n, addr in enumerate(addresses):
        text += f" lda #<{addr}\n sta screen_ptr\n lda #>{addr}\n sta screen_ptr+1\n ldy #7\nseed_{n}:\n lda background,y\n sta (screen_ptr),y\n dey\n bpl seed_{n}\n jsr save_background\n jsr draw_masked_cell\n ldy #7\nrecord_{n}:\n lda (screen_ptr),y\n sta ${0x4000 + n * 16:04x},y\n dey\n bpl record_{n}\n jsr restore_background\n ldy #7\nrestore_{n}:\n lda (screen_ptr),y\n sta ${0x4008 + n * 16:04x},y\n dey\n bpl restore_{n}\n"
    text += (
        " lda #$ca\n sta $4100\nhold: jmp hold\n"
        + code
        + "\nbackground: !byte "
        + ",".join(map(str, bg))
        + "\nshape: !byte "
        + ",".join(map(str, shape))
        + "\n"
    )
    (out / "fixture.asm").write_text(text)
    run(
        [
            args.assembler,
            "--dialect",
            "acme",
            "fixture.asm",
            "--sym=fixture.sym",
            "-o",
            "fixture.bin",
        ],
        out,
    )
    data = (out / "fixture.bin").read_bytes()
    lines = [
        "10 MODE 4",
        "20 HIMEM=&3000",
        f"30 FOR I%=0 TO {len(data) - 1}:READ B%:I%?&3000=B%:NEXT",
        "40 CALL &3000",
    ]
    for i in range(0, len(data), 16):
        lines.append(
            f"{100 + i // 16 * 10} DATA " + ",".join(map(str, data[i : i + 16]))
        )
    m = T.Machine(
        [
            args.bbc,
            "--mcp",
            "--mos",
            str(args.mos),
            "--rom",
            f"acorn-bbc-basic={args.basic}",
        ]
    )
    try:
        m.call("run_frames", frames=150)
        for line in lines:
            m.call("type_string", text=line + "\n", hold_frames=2, settle_frames=2)
        m.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
        for _ in range(80):
            if read(m, 0x4100, 1) == b"\xca":
                break
            m.call("run_frames", frames=20)
        require(read(m, 0x4100, 1) == b"\xca", "BBC fixture never completed")
        expected = (
            bytes((bg[i] & shape[2 * i]) | shape[2 * i + 1] for i in range(8)) + bg
        )
        actual = read(m, 0x4000, 16 * len(addresses))
        require(actual == expected * len(addresses), "BBC mask/save/restore mismatch")
        sym = T.symbols(out / "fixture.sym")
        require(read(m, sym["shape"], 16) == shape, "BBC sprite source changed")
        (out / "observations.json").write_text(
            json.dumps({"addresses": addresses, "result": list(actual)}, indent=2)
            + "\n"
        )
        m.call("save_screenshot", path=str(out / "fixture.png"))
    finally:
        m.close()
    return len(addresses)


def capture_callers(args: argparse.Namespace, out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)
    for folder in [SP, NS, BB]:
        run(["make", "ASM198X=" + args.assembler], folder)
    # Real ROM startup and tape autoload; marker distinguishes our caller from ROM.
    m = T.Machine([args.spectrum, "--mcp", "--rom", str(args.rom)])
    try:
        m.call(
            "load_media", slot="tape-1", kind="tape", path=str(SP / "build/demo.tap")
        )
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        sym = T.symbols(SP / "build/demo.sym")
        for _ in range(50):
            m.call("run_frames", frames=250)
            if read(m, sym["ready"], 2) == b"\xfe\xca":
                break
        require(read(m, sym["ready"], 2) == b"\xfe\xca", "Spectrum TAP did not start")
        first = read(m, sym["updates"], 1)
        m.call("run_frames", frames=3)
        require(
            read(m, sym["updates"], 1) != first,
            "Spectrum scroll caller did not progress",
        )
        m.call("save_screenshot", path=str(out / "spectrum.png"))
    finally:
        m.close()
    m = T.Machine(
        [args.nes, "--mcp", "--rom", str(NS / "build/demo.nes"), "--region", "ntsc"]
    )
    try:
        m.call("run_frames", frames=60)
        sym = T.symbols(NS / "build/demo.sym")
        first = read(m, sym["frames"], 1)
        m.call("run_frames", frames=3)
        require(read(m, sym["frames"], 1) != first, "NES scene did not progress")
        require(
            read(m, sym["presented_objects"], 1) == bytes([12]),
            "NES scene did not build twelve objects",
        )
        m.call("save_screenshot", path=str(out / "nes.png"))
    finally:
        m.close()
    m = T.Machine(
        [
            args.bbc,
            "--mcp",
            "--mos",
            str(args.mos),
            "--rom",
            f"acorn-bbc-basic={args.basic}",
        ]
    )
    try:
        m.call("run_frames", frames=150)
        for line in (BB / "build/loader.bas").read_text().splitlines():
            m.call("type_string", text=line + "\n", hold_frames=2, settle_frames=2)
        m.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
        sym = T.symbols(BB / "build/demo.sym")
        for _ in range(80):
            if read(m, sym["updates"], 1) != b"\0":
                break
            m.call("run_frames", frames=20)
        first = read(m, sym["updates"], 1)
        m.call("run_frames", frames=20)
        require(read(m, sym["updates"], 1) != first, "BBC scene did not progress")
        m.call("save_screenshot", path=str(out / "bbc.png"))
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    for name in ["spectrum", "nes", "bbc"]:
        p.add_argument("--" + name, required=True)
    p.add_argument(
        "--rom",
        type=Path,
        default=Path.home() / ".emu198x/roms/sinclair-zx-spectrum-48k/48.rom",
    )
    p.add_argument(
        "--mos", type=Path, default=Path.home() / ".emu198x/roms/acorn-bbc-micro/os.rom"
    )
    p.add_argument(
        "--basic",
        type=Path,
        default=Path.home() / ".emu198x/roms/acorn-bbc-micro/basic.rom",
    )
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    counts = {"spectrum": spectrum(args, out / "spectrum")}
    cases = [
        (0, 0),
        (1, 0),
        (8, 0),
        (9, 8),
        (12, 11),
        (63, 32),
        (64, 63),
        (64, 255),
        (65, 0),
        (255, 0),
    ]
    for count, first in cases:
        nes_fixture(args, out / f"nes/{count}-{first}", count, first)
    counts["nes"] = len(cases)
    counts["bbc"] = bbc(args, out / "bbc")
    rejected = []
    for name, call in [
        ("spectrum", lambda: spectrum(args, out / "mutant-spectrum", True)),
        ("nes", lambda: nes_fixture(args, out / "mutant-nes", 12, 0, True)),
        ("bbc", lambda: bbc(args, out / "mutant-bbc", True)),
    ]:
        try:
            call()
        except ValueError as error:
            require(
                "mismatch" in str(error),
                f"{name} mutant failed before its oracle: {error}",
            )
            rejected.append(name)
        else:
            raise ValueError(name + " broken routine escaped the same behaviour guard")
    capture_callers(args, out / "callers")
    files = [
        SP / "scroll.inc",
        SP / "demo.asm",
        SP / "Makefile",
        SP.parent / "bitmap-addressing/bitmap-addressing.inc",
        NS / "scroll.inc",
        NS / "demo.asm",
        NS / "Makefile",
        NO / "oam.inc",
        BB / "masked.inc",
        BB / "demo.asm",
        BB / "loader.py",
        BB / "Makefile",
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-z80-library-routines.py",
    ]
    result = {
        "status": "passed",
        "routine_cases": counts,
        "mutants_rejected": rejected,
        "sources": {str(f.relative_to(ROOT)): sha(f) for f in files},
        "observer_sha256": sha(Path(__file__)),
        "captures": {p.name: sha(p) for p in sorted((out / "callers").glob("*.png"))},
        "tools": {
            name: sha(Path(getattr(args, name)))
            for name in ["assembler", "spectrum", "nes", "bbc"]
        },
        "firmware": {
            name: sha(getattr(args, name)) for name in ["rom", "mos", "basic"]
        },
        "limits": __doc__,
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
