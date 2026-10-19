"""Execute software-object save/draw/restore against independent byte oracles.

Spectrum 48K CPU fixtures plus ROM tape, BBC Model B/MODE4 and A500 OCS PAL
with local Kickstart1.3. No original-hardware, tear-free or whole-game frame
budget claim. Firmware stays local; every emulator is closed after its run.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SP = ROOT / "sinclair-zx-spectrum/patterns/assembly/rendering/sprite-lifecycle"
BB = ROOT / "bbc-micro/patterns/assembly/rendering/sprite-lifecycle"
AM = ROOT / "commodore-amiga/patterns/assembly/rendering/sprite-lifecycle"
spec = importlib.util.spec_from_file_location(
    "render", ROOT / "scripts/verify-rendering-families.py"
)
assert spec and spec.loader
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)
T, Z = R.T, R.Z


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def shape_pairs() -> tuple[bytes, bytes]:
    # Treat assets as inputs; composition below is independent of the draw loop.
    lines = (SP / "shapes.inc").read_text().splitlines()
    return tuple(
        bytes(int(x) for x in line.split("defb ")[1].split(",")) for line in lines
    )  # type: ignore[return-value]


def masked_picture(background: bytes, pairs: bytes, x: int, y: int) -> bytes:
    out = bytearray(background)
    for row in range(16):
        for column in range(2):
            address = Z.screen_address(y + row, x // 8 + column) - 0x4000
            n = (row * 2 + column) * 2
            out[address] = (out[address] & pairs[n]) | pairs[n + 1]
    return bytes(out)


def spectrum(args: argparse.Namespace, out: Path, mutant: str = "") -> dict:
    code = (SP / "background.inc").read_text()
    if mutant == "save":
        code = code.replace("    ld (hl),a", "    xor a\n    ld (hl),a")
    code += "\n" + (SP.parent / "bitmap-addressing/bitmap-addressing.inc").read_text()
    initial = bytes((i * 37 + i // 19 + 31) % 256 for i in range(6144))
    declarations = (
        "org $9000\ninitial: defb "
        + ",".join(map(str, initial))
        + "\norg $b100\nbuffer: defs 6145,$a7\n"
    )
    seed = "    ld hl,initial\n    ld de,$4000\n    ld bc,6144\n    ldir\n"
    cases = [
        (0, 0, 0, 16),
        (31, 191, 1, 1),
        (0, 0, 32, 192),
        (1, 63, 2, 2),
        (10, 127, 3, 2),
        (30, 176, 2, 16),
        (0, 0, 32, 0),
    ]
    for n, (column, y, width, height) in enumerate(cases):
        address = Z.screen_address(y, column)
        body = (
            seed
            + f"    ld de,${address:04x}\n    ld hl,buffer\n    ld bc,{width * 256 + height}\n    call save_rect\n    ld ($b000),hl\n"
        )
        body += "    ld hl,$4000\n    ld de,$4001\n    ld bc,6143\n    ld (hl),0\n    ldir\n"
        body += f"    ld de,${address:04x}\n    ld hl,buffer\n    ld bc,{width * 256 + height}\n    call restore_rect\n"
        actual = Z.execute(
            out / f"rect-{n}",
            Z.caller(body, code, declarations),
            [(0x4000, 6144), (0xB100, width * height + 1), (0xB000, 2)],
            argparse.Namespace(assembler=args.assembler, emulator=args.spectrum),
        )
        expected = bytearray(6144)
        saved = bytearray()
        for row in range(height):
            address = Z.screen_address(y + row, column) - 0x4000
            values = initial[address : address + width]
            expected[address : address + width] = values
            saved.extend(values)
        require(
            bytes(actual[0]) == expected and bytes(actual[1]) == saved + b"\xa7",
            "Spectrum rectangle mismatch",
        )
        require(
            int.from_bytes(bytes(actual[2]), "little") == 0xB100 + width * height,
            "Spectrum buffer pointer mismatch",
        )
    a, b = shape_pairs()
    masked = (SP.parent / "masked-sprites/masked.inc").read_text()
    extra = "\nSPRITE_W equ 2\n" + masked + "\n" + (SP / "shapes.inc").read_text()
    locations = [
        (64, 56, 72, 64),
        (112, 120, 120, 128),
        (240, 168, 232, 176),
        (0, 0, 0, 8),
    ]
    for n, (ax, ay, bx, by) in enumerate(locations):
        aa = Z.screen_address(ay, ax // 8)
        ba = Z.screen_address(by, bx // 8)
        body = seed
        for address, slot, label in [(aa, 0xD100, "shape_a"), (ba, 0xD200, "shape_b")]:
            body += f"    ld de,${address:04x}\n    ld hl,${slot:04x}\n    ld bc,$0210\n    call save_rect\n    ld de,${address:04x}\n    ld hl,{label}\n    ld c,16\n    call draw_sprite\n"
        body += "    ld hl,$4000\n    ld de,$b000\n    ld bc,6144\n    ldir\n"
        restore = [(ba, 0xD200), (aa, 0xD100)]
        if mutant == "order":
            restore.reverse()
        for address, slot in restore:
            body += f"    ld de,${address:04x}\n    ld hl,${slot:04x}\n    ld bc,$0210\n    call restore_rect\n"
        actual = Z.execute(
            out / f"overlap-{n}",
            Z.caller(body, code + extra, declarations),
            [(0x4000, 6144), (0xB000, 6144)],
            argparse.Namespace(assembler=args.assembler, emulator=args.spectrum),
        )
        composite = masked_picture(masked_picture(initial, a, ax, ay), b, bx, by)
        require(
            bytes(actual[0]) == initial and bytes(actual[1]) == composite,
            "Spectrum overlap/restoration mismatch",
        )
    return {"rectangles": len(cases), "overlaps": len(locations)}


def amiga(args: argparse.Namespace, out: Path, mutant: str = "") -> dict:
    out.mkdir(parents=True, exist_ok=True)
    code = (AM / "bob.inc").read_text()
    if mutant == "mask":
        code = code.replace("#$0fca", "#$0ff0")
    body = """    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    move.w #$8240,$096(a5)
"""
    data = []
    checks = []
    cases = [
        (0, 16, 40),
        (2, 0, 40),
        (1, 1, 4),
        (2, 16, 40),
        (20, 3, 40),
        (64, 1, 128),
        (1, 1024, 2),
    ]
    for n, (width, height, stride) in enumerate(cases):
        length = stride * height
        size = width * height * 2
        initial = bytes((i * 29 + i // 7 + 23) % 256 for i in range(length))
        body += f"""    lea plane{n}+2,a0
    lea under{n}+2,a1
    move.w #{width},d0
    move.w #{height},d1
    move.w #{stride},d2
    bsr bob_save
"""
        if length:
            body += f"""    lea plane{n}+2,a0
    move.w #{length - 1},d7
clear{n}: clr.b (a0)+
    dbra d7,clear{n}
"""
        body += f"""    lea under{n}+2,a0
    lea plane{n}+2,a1
    move.w #{width},d0
    move.w #{height},d1
    move.w #{stride},d2
    bsr bob_restore
"""
        expected = bytearray(length)
        saved = bytearray()
        for y in range(height):
            values = initial[y * stride : y * stride + width * 2]
            expected[y * stride : y * stride + width * 2] = values
            saved.extend(values)
        data += [
            f"plane{n}: dc.b "
            + ",".join(map(str, b"\xa5\x5a" + initial + b"\xa5\x5a")),
            f"under{n}: dc.b "
            + ",".join(map(str, b"\xa5\x5a" + bytes([0xA7]) * size + b"\xa5\x5a")),
        ]
        checks += [
            (f"plane{n}", b"\xa5\x5a" + expected + b"\xa5\x5a"),
            (f"under{n}", b"\xa5\x5a" + saved + b"\xa5\x5a"),
        ]
    initial = bytes((i * 19 + i // 9 + 7) % 256 for i in range(40 * 64))
    expected = bytearray(initial)
    masks = []
    images_a = []
    images_b = []
    for line in (AM / "shapes.inc").read_text().splitlines():
        values = bytes.fromhex(
            "".join(
                f"{int(x.strip()[1:], 16):04x}"
                for x in line.split("dc.w ")[1].split(",")
            )
        )
        if line.startswith("mask:"):
            masks = values
        elif line.startswith("image_a:"):
            images_a = values
        else:
            images_b = values
    offsets = [16 * 40 + 10, 24 * 40 + 12]
    snapshots = []
    for offset, image, slot in zip(
        offsets, [images_a, images_b], ["save_a", "save_b"], strict=True
    ):
        snapshots.append(
            b"".join(expected[offset + y * 40 : offset + y * 40 + 4] for y in range(16))
        )
        for y in range(16):
            for x in range(4):
                i = offset + y * 40 + x
                j = y * 4 + x
                expected[i] = (masks[j] & image[j]) | ((~masks[j] & 255) & expected[i])
        label = "image_a" if slot == "save_a" else "image_b"
        body += f"""    lea picture+{offset},a0
    lea {slot},a1
    moveq #2,d0
    moveq #16,d1
    moveq #40,d2
    bsr bob_save
    lea mask,a0
    lea {label},a1
    lea picture+{offset},a2
    moveq #2,d0
    moveq #16,d1
    moveq #40,d2
    bsr bob_draw
"""
    body += """    lea picture,a0
    lea composite,a1
    move.w #2559,d7
copy_composite: move.b (a0)+,(a1)+
    dbra d7,copy_composite
"""
    restore = [(offsets[1], "save_b"), (offsets[0], "save_a")]
    if mutant == "order":
        restore.reverse()
    for offset, slot in restore:
        body += f"""    lea {slot},a0
    lea picture+{offset},a1
    moveq #2,d0
    moveq #16,d1
    moveq #40,d2
    bsr bob_restore
"""
    body += (
        """    move.w #$cafe,ready
hold: bra.s hold
signature: dc.b "198XLIFECHK!",0
    even
ready: dc.w 0
"""
        + code
        + "\n"
        + (AM / "shapes.inc").read_text()
        + "\n"
    )
    data += [
        "picture: dc.b " + ",".join(map(str, initial)),
        "composite: dcb.b 2560,0",
        "save_a: dcb.b 64,0",
        "save_b: dcb.b 64,0",
    ]
    checks += [
        ("picture", initial),
        ("composite", bytes(expected)),
        ("save_a", snapshots[0]),
        ("save_b", snapshots[1]),
        ("mask", masks),
        ("image_a", images_a),
        ("image_b", images_b),
    ]
    (out / "fixture.asm").write_text(body + "\n".join(data) + "\n")
    R.run(
        [
            args.assembler,
            "--dialect",
            "vasm",
            "--exe",
            "--sym=fixture.sym",
            "fixture.asm",
            "-o",
            "fixture",
        ],
        out,
    )
    R.run(
        [args.build198x, "adf", "fixture", "-o", "fixture.adf", "--name", "fixture"],
        out,
    )
    symbols = T.symbols(out / "fixture.sym")
    m = T.Machine(
        [
            args.amiga,
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(out / "fixture.adf"),
        ]
    )
    try:
        base = amiga_base(m, symbols)
        observed = {}
        for label, expected in checks:
            actual = R.read(m, base + symbols[label], len(expected))
            require(actual == expected, "Amiga save/draw/restore mismatch: " + label)
            observed[label] = list(actual)
        (out / "observations.json").write_text(json.dumps(observed, indent=2) + "\n")
    finally:
        m.close()
    return {"rectangles": len(cases), "overlaps": 1}


def amiga_base(m: Any, symbols: dict) -> int:
    for _ in range(25):
        m.call("run_frames", frames=100)
        scan = m.call("memory_scan", start=0, end=0x80000, value=0x31393858)
        require(not scan["truncated"], "Amiga signature scan truncated")
        bases = []
        for hit in scan["hits"]:
            base = int(hit["addr"][1:], 16) - symbols["signature"]
            if base >= 0 and R.read(m, base + symbols["ready"], 2) == b"\xca\xfe":
                bases.append(base)
        if bases:
            require(len(bases) == 1, "Amiga caller signature ambiguous")
            return bases[0]
    raise ValueError("Amiga executable did not reach its ready marker")


def bbc(args: argparse.Namespace, out: Path, wrong_order: bool = False) -> dict:
    out.mkdir(parents=True, exist_ok=True)
    bg = bytes([0x13, 0xA5, 0xFF, 0, 0x81, 0x24, 0x42, 0x7E])
    a = bytes(
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
    b = bytes(
        [
            0x81,
            0x7E,
            0xBD,
            0x42,
            0xBD,
            0x42,
            0x81,
            0x7E,
            0xE7,
            0x18,
            0xE7,
            0x18,
            0xE7,
            0x18,
            0xC3,
            0x3C,
        ]
    )
    body = "*=$3000\nstart:\n cld\n cli\n"
    expected = bytearray()
    cases = [(0x5800, 0x5800), (0x5938, 0x5940), (0x7FF8, 0x7FF8)]
    for n, (aa, ba) in enumerate(cases):
        scene = {aa: bg, ba: bg}
        for k, address in enumerate(dict.fromkeys([aa, ba])):
            body += f" ldy #7\nseed_{n}_{k}:\n lda background,y\n sta ${address:04x},y\n dey\n bpl seed_{n}_{k}\n"
        for address, shape, slot in [
            (aa, "shape_a", "under_a"),
            (ba, "shape_b", "under_b"),
        ]:
            body += (
                bbc_ptr(address, slot)
                + f" lda #<{shape}\n sta pairs_ptr\n lda #>{shape}\n sta pairs_ptr+1\n jsr save_cell_to_buffer\n jsr draw_masked_cell\n"
            )
            pairs = a if shape == "shape_a" else b
            scene[address] = bytes(
                (v & pairs[2 * i]) | pairs[2 * i + 1]
                for i, v in enumerate(scene[address])
            )
        for k, address in enumerate([aa, ba]):
            body += f" ldy #7\nread_{n}_{k}:\n lda ${address:04x},y\n sta ${0x4000 + n * 32 + k * 8:04x},y\n dey\n bpl read_{n}_{k}\n"
        expected.extend(scene[aa] + scene[ba])
        restore = [(ba, "under_b"), (aa, "under_a")]
        if wrong_order:
            restore.reverse()
        for address, slot in restore:
            body += bbc_ptr(address, slot) + " jsr restore_cell_from_buffer\n"
        for k, address in enumerate([aa, ba]):
            body += f" ldy #7\nrestored_{n}_{k}:\n lda ${address:04x},y\n sta ${0x4010 + n * 32 + k * 8:04x},y\n dey\n bpl restored_{n}_{k}\n"
        expected.extend(bg + bg)
    body += (
        " lda #$ca\n sta $4100\nhold: jmp hold\n"
        + (BB.parent / "masked-sprites/masked.inc").read_text()
        + "\n"
        + (BB / "background.inc").read_text()
        + "\n"
    )
    body += (
        "background: !byte "
        + ",".join(map(str, bg))
        + "\nshape_a: !byte "
        + ",".join(map(str, a))
        + "\nshape_b: !byte "
        + ",".join(map(str, b))
        + "\nunder_a: !fill 8,0\nunder_b: !fill 8,0\n"
    )
    (out / "fixture.asm").write_text(body)
    R.run(
        [
            args.assembler,
            "--dialect",
            "acme",
            "--sym=fixture.sym",
            "fixture.asm",
            "-o",
            "fixture.bin",
        ],
        out,
    )
    m = bbc_load(args, (out / "fixture.bin").read_bytes())
    try:
        for _ in range(100):
            if R.read(m, 0x4100, 1) == b"\xca":
                break
            m.call("run_frames", frames=20)
        require(R.read(m, 0x4100, 1) == b"\xca", "BBC executable did not finish")
        actual = R.read(m, 0x4000, len(expected))
        require(actual == expected, "BBC overlap/restoration mismatch")
        symbols = T.symbols(out / "fixture.sym")
        require(
            R.read(m, symbols["shape_a"], 16) == a
            and R.read(m, symbols["shape_b"], 16) == b,
            "BBC image source changed",
        )
        (out / "observations.json").write_text(json.dumps(list(actual)) + "\n")
    finally:
        m.close()
    return {"overlaps": len(cases)}


def bbc_ptr(address: int, slot: str) -> str:
    return f" lda #<{address}\n sta screen_ptr\n lda #>{address}\n sta screen_ptr+1\n lda #<{slot}\n sta back_ptr\n lda #>{slot}\n sta back_ptr+1\n"


def bbc_load(args: argparse.Namespace, data: bytes) -> Any:
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
        for line in lines:
            m.call("type_string", text=line + "\n", hold_frames=2, settle_frames=2)
        m.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
        return m
    except BaseException:
        m.close()
        raise


def callers(args: argparse.Namespace, out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)
    for folder in [SP, BB, AM]:
        R.run(
            ["make", "ASM198X=" + args.assembler, "BUILD198X=" + args.build198x], folder
        )
    m = T.Machine([args.spectrum, "--mcp", "--rom", str(args.rom)])
    try:
        m.call(
            "load_media", slot="tape-1", kind="tape", path=str(SP / "build/demo.tap")
        )
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        symbols = T.symbols(SP / "build/demo.sym")
        for _ in range(50):
            m.call("run_frames", frames=250)
            if R.read(m, symbols["ready"], 2) == b"\xfe\xca":
                break
        require(
            R.read(m, symbols["ready"], 2) == b"\xfe\xca", "Spectrum tape did not start"
        )
        old = R.read(m, symbols["updates"], 1)
        m.call("run_frames", frames=5)
        require(
            R.read(m, symbols["updates"], 1) != old, "Spectrum caller did not progress"
        )
        m.call("save_screenshot", path=str(out / "spectrum.png"))
    finally:
        m.close()
    m = bbc_load(args, (BB / "build/demo.bin").read_bytes())
    try:
        symbols = T.symbols(BB / "build/demo.sym")
        for _ in range(100):
            if R.read(m, symbols["updates"], 1) != b"\0":
                break
            m.call("run_frames", frames=20)
        old = R.read(m, symbols["updates"], 1)
        m.call("run_frames", frames=20)
        require(R.read(m, symbols["updates"], 1) != old, "BBC caller did not progress")
        m.call("save_screenshot", path=str(out / "bbc.png"))
    finally:
        m.close()
    symbols = T.symbols(AM / "build/demo.sym")
    m = T.Machine(
        [
            args.amiga,
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(AM / "build/demo.adf"),
        ]
    )
    try:
        base = amiga_base(m, symbols)
        old = R.read(m, base + symbols["updates"], 2)
        m.call("run_frames", frames=5)
        require(
            R.read(m, base + symbols["updates"], 2) != old,
            "Amiga caller did not progress",
        )
        m.call("save_screenshot", path=str(out / "amiga.png"))
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    for name in ["spectrum", "bbc", "amiga", "assembler", "build198x"]:
        p.add_argument("--" + name, required=True)
    for name, relative in [
        ("rom", "sinclair-zx-spectrum-48k/48.rom"),
        ("mos", "acorn-bbc-micro/os.rom"),
        ("basic", "acorn-bbc-micro/basic.rom"),
        ("kickstart", "commodore-amiga/kick13.rom"),
    ]:
        p.add_argument(
            "--" + name, type=Path, default=Path.home() / ".emu198x/roms" / relative
        )
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    counts = {
        "spectrum": spectrum(args, out / "spectrum"),
        "amiga": amiga(args, out / "amiga"),
        "bbc": bbc(args, out / "bbc"),
    }
    controls = {}
    for name, check in [
        ("spectrum-save", lambda: spectrum(args, out / "mutant-spectrum-save", "save")),
        (
            "spectrum-order",
            lambda: spectrum(args, out / "mutant-spectrum-order", "order"),
        ),
        ("amiga-mask", lambda: amiga(args, out / "mutant-amiga-mask", "mask")),
        ("amiga-order", lambda: amiga(args, out / "mutant-amiga-order", "order")),
        ("bbc-order", lambda: bbc(args, out / "mutant-bbc-order", True)),
    ]:
        try:
            check()
        except ValueError as error:
            require(
                "mismatch" in str(error),
                "Mutant failed before its output oracle: " + str(error),
            )
            controls[name] = str(error)
        else:
            raise ValueError("Broken variant escaped the guard: " + name)
    callers(args, out / "callers")
    files = []
    for folder in [SP, BB, AM]:
        files.extend(
            p
            for p in folder.iterdir()
            if p.suffix in [".asm", ".inc", ".py"] or p.name == "Makefile"
        )
    files.extend(
        [
            SP.parent / "masked-sprites/masked.inc",
            SP.parent / "bitmap-addressing/bitmap-addressing.inc",
            BB.parent / "masked-sprites/masked.inc",
            AM.parent.parent / "framework/game-loop/frame.inc",
            ROOT / "scripts/verify-rendering-families.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-z80-library-routines.py",
        ]
    )
    result = {
        "status": "passed",
        "cases": counts,
        "rejected_controls": controls,
        "sources": {str(p.relative_to(ROOT)): R.sha(p) for p in sorted(files)},
        "observer_sha256": R.sha(Path(__file__)),
        "tools": {
            n: R.sha(Path(getattr(args, n)))
            for n in ["assembler", "build198x", "spectrum", "bbc", "amiga"]
        },
        "firmware": {
            n: R.sha(getattr(args, n)) for n in ["rom", "mos", "basic", "kickstart"]
        },
        "captures": {p.name: R.sha(p) for p in sorted((out / "callers").glob("*.png"))},
        "limits": __doc__,
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
