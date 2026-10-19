"""Verify signed clipping and aligned masked drawing in three guest CPUs.

Spectrum 48K PAL, BBC Model B MOS1.20/BASICII MODE4, A500 OCS PAL/KS1.3.
No original-hardware, arbitrary-X, display-deadline or whole-game budget claim.
Firmware and synthetic snapshots stay local. Every emulator is closed.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "lifecycle", ROOT / "scripts/verify-sprite-lifecycle.py"
)
assert spec and spec.loader
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)
R, Z, T = L.R, L.Z, L.T
SYSTEMS = {
    "spectrum": "sinclair-zx-spectrum",
    "bbc": "bbc-micro",
    "amiga": "commodore-amiga",
}
POSITIONS = [
    -32768,
    -257,
    -256,
    -255,
    -33,
    -32,
    -17,
    -16,
    -2,
    -1,
    0,
    1,
    15,
    31,
    32,
    63,
    127,
    191,
    192,
    255,
    256,
    32767,
]
CASES = [(p, s, 256) for p in POSITIONS for s in [0, 1, 2, 16, 32, 256]] + [
    (p, 16, limit) for p in POSITIONS for limit in [1, 20, 32, 192]
]


def folder(system: str) -> Path:
    return ROOT / SYSTEMS[system] / "patterns/assembly/rendering/clipped-sprites"


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def interval(position: int, size: int, limit: int) -> tuple[int, int, int]:
    # Enumerate source samples that actually fall inside the destination.
    # This is independent of the routines' subtraction/clamping algorithm.
    visible = [(position + i, i) for i in range(size) if 0 <= position + i < limit]
    return (visible[0][0], visible[0][1], len(visible)) if visible else (0, 0, 0)


def table(big: bool = False) -> bytes:
    order = "big" if big else "little"
    return b"".join(
        b"".join((v & 65535).to_bytes(2, order) for v in c) + b"\xa7" * 10
        for c in CASES
    )


def check_table(actual: bytes, big: bool = False) -> None:
    order = "big" if big else "little"
    expected = bytearray(table(big))
    for i, c in enumerate(CASES):
        expected[i * 16 + 6 : i * 16 + 12] = b"".join(
            v.to_bytes(2, order) for v in interval(*c)
        )
    # Scratch +12/+13 is deliberately unspecified; input, outputs and guard are checked.
    require(len(actual) == len(expected), "Axis record size mismatch")
    for i in range(len(CASES)):
        require(
            actual[i * 16 : i * 16 + 12] == expected[i * 16 : i * 16 + 12]
            and actual[i * 16 + 14 : i * 16 + 16] == b"\xa7\xa7",
            f"Axis output/input/guard mismatch at {CASES[i]}",
        )


def data_bytes(data: bytes, directive: str) -> str:
    return (
        "\n".join(
            ("    " if directive.startswith("dc.") else "")
            + directive
            + " "
            + ",".join(map(str, data[i : i + 16]))
            for i in range(0, len(data), 16)
        )
        + "\n"
    )


def compile_bbc(args: argparse.Namespace, out: Path, source: str) -> tuple[bytes, dict]:
    out.mkdir(parents=True, exist_ok=True)
    (out / "fixture.asm").write_text(source)
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
    return (out / "fixture.bin").read_bytes(), T.symbols(out / "fixture.sym")


def bbc_cpu_load(args: argparse.Namespace, data: bytes) -> Any:
    # Large axis tables do not fit a BASIC DATA program below HIMEM=&3000.
    # Inject only this CPU fixture, verify every byte, then enter through MOS/BASIC CALL.
    m = T.Machine(
        [
            args.bbc,
            "--mcp",
            "--mos",
            str(args.mos),
            "--rom",
            "acorn-bbc-basic=" + str(args.basic),
        ]
    )
    try:
        m.call("run_frames", frames=150)
        m.call("type_string", text="MODE 4\n", hold_frames=2, settle_frames=2)
        m.call("run_frames", frames=20)
        for i in range(0, len(data) - 1, 2):
            m.call(
                "poke_word",
                addr=0x3000 + i,
                value=int.from_bytes(data[i : i + 2], "little"),
            )
        if len(data) % 2:
            m.call("poke_byte", addr=0x3000 + len(data) - 1, value=data[-1])
        require(R.read(m, 0x3000, len(data)) == data, "BBC fixture injection mismatch")
        m.call("type_string", text="CALL &3000\n", hold_frames=2, settle_frames=10)
        return m
    except BaseException:
        m.close()
        raise


def amiga_machine(
    args: argparse.Namespace, out: Path, source: str
) -> tuple[Any, dict, int]:
    out.mkdir(parents=True, exist_ok=True)
    (out / "fixture.asm").write_text(source)
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
    R.run([args.build198x, "fixture", "-o", "fixture.adf", "--name", "fixture"], out)
    symbols = T.symbols(out / "fixture.sym")
    machine = T.Machine(
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
        return machine, symbols, L.amiga_base(machine, symbols)
    except BaseException:
        machine.close()
        raise


def axes(
    args: argparse.Namespace, out: Path, system: str, broken: bool = False
) -> None:
    code = (folder(system) / "clip.inc").read_text()
    if broken:
        code = code.replace(
            "clip_axis:\n",
            "clip_axis:\n    " + ("ret" if system == "spectrum" else "rts") + "\n",
            1,
        )
    if system == "spectrum":
        body = """    ld ix,records
axis_next:
    call clip_axis
    ld de,16
    add ix,de
    push ix
    pop hl
    ld de,records_end
    or a
    sbc hl,de
    jr nz,axis_next
"""
        source = Z.caller(
            body,
            code,
            "org $9000\nrecords:\n" + data_bytes(table(), "defb") + "records_end:\n",
        )
        actual = bytes(
            Z.execute(
                out,
                source,
                [(0x9000, len(table()))],
                argparse.Namespace(assembler=args.assembler, emulator=args.spectrum),
            )[0]
        )
    elif system == "bbc":
        source = (
            """*=$3000
start:
    cld
    sei
    lda #<records
    sta clip_ptr
    lda #>records
    sta clip_ptr+1
axis_next:
    jsr clip_axis
    clc
    lda clip_ptr
    adc #16
    sta clip_ptr
    bcc axis_pointer
    inc clip_ptr+1
axis_pointer:
    lda clip_ptr+1
    cmp #>records_end
    bne axis_next
    lda clip_ptr
    cmp #<records_end
    bne axis_next
    lda #$ca
    sta $2fff
hold: jmp hold
"""
            + code
            + "\nrecords:\n"
            + data_bytes(table(), "!byte")
            + "records_end:\n"
        )
        data, symbols = compile_bbc(args, out, source)
        m = bbc_cpu_load(args, data)
        try:
            for _ in range(100):
                if R.read(m, 0x2FFF, 1) == b"\xca":
                    break
                m.call("run_frames", frames=20)
            require(R.read(m, 0x2FFF, 1) == b"\xca", "BBC axis caller did not finish")
            actual = R.read(m, symbols["records"], len(table()))
        finally:
            m.close()
    else:
        source = (
            """    section code,code_c
start:
    lea records,a3
axis_next:
    move.w (a3),d0
    move.w 2(a3),d1
    move.w 4(a3),d2
    bsr clip_axis
    move.w d0,6(a3)
    move.w d1,8(a3)
    move.w d2,10(a3)
    adda.w #16,a3
    lea records_end,a4
    cmpa.l a4,a3
    bne axis_next
    move.w #$cafe,ready
hold: bra hold
signature: dc.b "198XCLIPAXIS",0
    even
ready: dc.w 0
"""
            + code
            + "\nrecords:\n"
            + data_bytes(table(True), "dc.b")
            + "records_end:\n"
        )
        m, symbols, base = amiga_machine(args, out, source)
        try:
            actual = R.read(m, base + symbols["records"], len(table(True)))
        finally:
            m.close()
    (out / "observations.json").write_text(json.dumps(list(actual)) + "\n")
    check_table(actual, system == "amiga")


def scene_positions(system: str) -> list[tuple[int, int]]:
    last = 19 if system == "amiga" else (39 if system == "bbc" else 31)
    bottom = 184 if system == "spectrum" else 248
    return [
        (-1, -8),
        (last, -8),
        (-1, bottom),
        (last, bottom),
        (9 if system == "amiga" else 15, 120 if system != "spectrum" else 88),
        (0, 80),
        (last - 1, 160 if system != "spectrum" else 112),
        (-2, 32),
        (last + 1, 32),
    ]


def expected_scene(system: str) -> bytes:
    path = folder(system) / "shapes.inc"
    if system == "amiga":
        lines = path.read_text().splitlines()
        mask = [int(v.strip()[1:], 16) for v in lines[0].split("dc.w ")[1].split(",")]
        image = [int(v.strip()[1:], 16) for v in lines[1].split("dc.w ")[1].split(",")]
        width, height = 20, 256
        picture = [0x5555] * (width * height)
        for x, y in scene_positions(system):
            for sy in range(16):
                for sx in range(2):
                    if 0 <= x + sx < width and 0 <= y + sy < height:
                        n = (y + sy) * width + x + sx
                        i = sy * 2 + sx
                        picture[n] = (picture[n] & (~mask[i] & 65535)) | (
                            image[i] & mask[i]
                        )
        return b"".join(v.to_bytes(2, "big") for v in picture)
    pairs = bytes(
        int(v)
        for v in re.split(r"(?:defb|!byte)\s+", path.read_text(), maxsplit=1)[1]
        .strip()
        .split(",")
    )
    width, height = (32, 192) if system == "spectrum" else (40, 256)
    picture = bytearray(b"\x55" * (6144 if system == "spectrum" else 10240))
    for x, y in scene_positions(system):
        for sy in range(16):
            for sx in range(2):
                if 0 <= x + sx < width and 0 <= y + sy < height:
                    xx, yy = x + sx, y + sy
                    a = (
                        Z.screen_address(yy, xx) - 0x4000
                        if system == "spectrum"
                        else (yy // 8) * 320 + xx * 8 + yy % 8
                    )
                    i = (sy * 2 + sx) * 2
                    picture[a] = (picture[a] & pairs[i]) | pairs[i + 1]
    return bytes(picture)


def flatten(path: Path) -> str:
    source = path.read_text()
    return re.sub(
        r'(?m)^\s*(?:include|!source) "([^"]+)"',
        lambda m: flatten(path.parent / m[1]),
        source,
    )


def scenes(
    args: argparse.Namespace, out: Path, system: str, broken: bool = False
) -> None:
    out.mkdir(parents=True, exist_ok=True)
    source = flatten(folder(system) / "demo.asm")
    if broken:
        # Deliberately lose LEFT crop source offset, leaving clipping bounds intact.
        if system == "spectrum":
            source = source.replace("    ld e,(ix+8)", "    ld e,0")
        elif system == "bbc":
            source = source.replace(
                "    ldy #8\n    lda (clip_ptr),y\n    asl",
                "    ldy #8\n    lda #0\n    asl",
            )
        else:
            source = source.replace("    add.w d6,d1", "    add.w #0,d1")
    if system == "spectrum":
        (out / "fixture.asm").write_text(source)
        R.run(
            [
                args.assembler,
                "--dialect",
                "pasmo",
                "--cpu",
                "z80",
                "--tapbas",
                "--sym=fixture.sym",
                "fixture.asm",
                "-o",
                "fixture.tap",
            ],
            out,
        )
        symbols = T.symbols(out / "fixture.sym")
        m = T.Machine([args.spectrum, "--mcp", "--rom", str(args.rom)])
        try:
            m.call(
                "load_media", slot="tape-1", kind="tape", path=str(out / "fixture.tap")
            )
            m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
            for _ in range(50):
                m.call("run_frames", frames=250)
                if R.read(m, symbols["ready"], 2) == b"\xfe\xca":
                    break
            require(
                R.read(m, symbols["ready"], 2) == b"\xfe\xca",
                "Spectrum clipping tape did not start",
            )
            actual = R.read(m, 0x4000, 6144)
            require(
                R.read(m, 0x5800, 768) == bytes([71]) * 768,
                "Spectrum attributes changed",
            )
            shape = R.read(m, symbols["shape_a"], 64)
            base = 0
            marker_size = 2
            capture = "spectrum.png"
            _scene_tail(m, symbols, base, marker_size, out, capture, broken)
        finally:
            m.close()
    elif system == "bbc":
        data, symbols = compile_bbc(args, out, source)
        m = bbc_cpu_load(args, data) if broken else L.bbc_load(args, data)
        try:
            for _ in range(100):
                if R.read(m, symbols["ready"], 1) == b"\xca":
                    break
                m.call("run_frames", frames=20)
            require(
                R.read(m, symbols["ready"], 1) == b"\xca",
                "BBC clipping caller did not finish",
            )
            actual = R.read(m, 0x5800, 10240)
            shape = R.read(m, symbols["shape_a"], 64)
            _scene_tail(m, symbols, 0, 1, out, "bbc.png", broken)
        finally:
            m.close()
    else:
        m, symbols, base = amiga_machine(args, out, source)
        try:
            actual = R.read(m, base + symbols["plane"], 10240)
            require(
                R.read(m, base + symbols["before_plane"], 16) == bytes([0xA7]) * 16
                and R.read(m, base + symbols["after_plane"], 16) == bytes([0xA7]) * 16,
                "Amiga plane guard mismatch",
            )
            shape = R.read(m, base + symbols["mask"], 192)
            _scene_tail(m, symbols, base, 2, out, "amiga.png", broken)
        finally:
            m.close()
    (out / "observations.json").write_text(
        json.dumps({"picture": list(actual), "source": list(shape)}) + "\n"
    )
    require(actual == expected_scene(system), system + " cropped image mismatch")
    if system == "amiga":
        expected = b"".join(
            int(v.strip()[1:], 16).to_bytes(2, "big")
            for line in (folder(system) / "shapes.inc").read_text().splitlines()
            for v in line.split("dc.w ")[1].split(",")
        )
    else:
        expected = bytes(
            int(v)
            for v in re.split(
                r"(?:defb|!byte)\s+",
                (folder(system) / "shapes.inc").read_text(),
                maxsplit=1,
            )[1]
            .strip()
            .split(",")
        )
    require(shape == expected, system + " source preservation mismatch")


def _scene_tail(
    m: Any, symbols: dict, base: int, size: int, out: Path, capture: str, broken: bool
) -> None:
    old = R.read(m, base + symbols["updates"], size)
    m.call("run_frames", frames=5)
    require(
        R.read(m, base + symbols["updates"], size) != old,
        "Scene did not continue servicing frames",
    )
    if not broken:
        m.call("save_screenshot", path=str(out / capture))


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    for n in ["assembler", "build198x", "spectrum", "bbc", "amiga"]:
        p.add_argument("--" + n, required=True)
    for n, r in [
        ("rom", "sinclair-zx-spectrum-48k/48.rom"),
        ("mos", "acorn-bbc-micro/os.rom"),
        ("basic", "acorn-bbc-micro/basic.rom"),
        ("kickstart", "commodore-amiga/kick13.rom"),
    ]:
        p.add_argument("--" + n, type=Path, default=Path.home() / ".emu198x/roms" / r)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    counts = {}
    controls = {}
    for system in SYSTEMS:
        print("Checking " + system, flush=True)
        axes(args, out / system / "axis", system)
        scenes(args, out / system / "scene", system)
        counts[system] = {
            "axis_cases": len(CASES),
            "native_scenes": 1,
            "objects_per_scene": 9,
        }
        for kind, fn in [("axis", axes), ("source-crop", scenes)]:
            try:
                fn(args, out / ("mutant-" + system + "-" + kind), system, True)
            except ValueError as e:
                require(
                    "mismatch" in str(e),
                    "Control failed before output oracle: " + str(e),
                )
                controls[system + "-" + kind] = str(e)
            else:
                raise ValueError(
                    "Broken clipping escaped oracle: " + system + "-" + kind
                )
    sources = []
    for s in SYSTEMS:
        sources.extend(
            p
            for p in folder(s).iterdir()
            if p.suffix in [".asm", ".inc", ".py"] or p.name == "Makefile"
        )
    sources.extend(
        ROOT / p
        for p in [
            "scripts/verify-sprite-lifecycle.py",
            "scripts/verify-rendering-families.py",
            "scripts/verify-game-loops.py",
            "scripts/verify-z80-library-routines.py",
            "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
            "commodore-amiga/patterns/assembly/framework/game-loop/frame.inc",
        ]
    )
    result = {
        "status": "passed",
        "cases": counts,
        "rejected_controls": controls,
        "sources": {str(p.relative_to(ROOT)): R.sha(p) for p in sorted(sources)},
        "observer_sha256": R.sha(Path(__file__)),
        "tools": {
            n: R.sha(Path(getattr(args, n)))
            for n in ["assembler", "build198x", "spectrum", "bbc", "amiga"]
        },
        "firmware": {
            n: R.sha(getattr(args, n)) for n in ["rom", "mos", "basic", "kickstart"]
        },
        "captures": {
            s + ".png": R.sha(out / s / "scene" / (s + ".png")) for s in SYSTEMS
        },
        "limits": __doc__,
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("All clipping cases and controls passed", flush=True)


if __name__ == "__main__":
    main()
