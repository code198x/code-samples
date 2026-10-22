"""Exercise the new 6809 implementation at byte/word and dimension boundaries."""

from __future__ import annotations

import argparse
import importlib.util
import json
import struct
import subprocess
from pathlib import Path
from shutil import which

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "remaining", ROOT / "scripts/verify-remaining-assembly-maps.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
T = V.T
FOLDER = ROOT / "dragon-32/patterns/assembly/rendering/tile-map"
MAP = bytes((i * 7 + 3) % 256 for i in range(512))
PROPERTIES = bytes(i ^ 0x55 for i in range(256))
# operation, width, height, column/world-X, row/world-Y, tile, max-ID.
# Each map fits in 512 bytes; zero dimensions deliberately make every cell invalid.
CASES = [
    ["get", 1, 1, 0, 0, 0, 255],
    ["get", 1, 1, 1, 0, 0, 255],
    ["get", 255, 2, 254, 1, 0, 255],
    ["get", 2, 255, 1, 254, 0, 255],
    ["get", 255, 2, 255, 1, 0, 255],
    ["get", 2, 255, 1, 255, 0, 255],
    ["get", 0, 5, 0, 0, 0, 255],
    ["get", 5, 0, 0, 0, 0, 255],
    ["set", 255, 2, 254, 1, 255, 255],
    ["set", 2, 255, 1, 254, 0, 255],
    ["set", 7, 5, 7, 0, 1, 3],
    ["set", 7, 5, 0, 0, 4, 3],
    ["set", 1, 1, 0, 0, 0, 0],
    ["property", 1, 1, 0, 0, 255, 255],
    ["property", 1, 1, 0, 0, 0, 0],
    ["property", 1, 1, 0, 0, 1, 0],
    ["pixel8", 255, 2, 2039, 15, 0, 255],
    ["pixel8", 2, 255, 15, 2039, 0, 255],
    ["pixel8", 255, 2, 2040, 0, 0, 255],
    ["pixel8", 255, 2, 2048, 0, 0, 255],
    ["pixel8", 2, 255, 0, 2048, 0, 255],
    ["pixel8", 7, 5, 65535, 65535, 0, 255],
]
STRIDE = (
    519  # valid, tile, property, full unchanged world X/Y words, then 512 map bytes.
)


def expected() -> bytes:
    output = bytearray()
    for op, w, h, x, y, tile, maximum in CASES:
        cells = bytearray(MAP)
        valid = prop = 0
        if op == "property":
            valid = int(tile <= maximum)
            prop = PROPERTIES[tile] if valid else 0
        else:
            col, row = (x // 8, y // 8) if op == "pixel8" else (x, y)
            valid = int(col < w and row < h and (op != "set" or tile <= maximum))
            if op == "set":
                if valid:
                    cells[row * w + col] = tile
            else:
                tile = cells[row * w + col] if valid else 0
        output += bytes([valid, tile, prop]) + struct.pack(">HH", x, y) + cells
    return bytes(output) + b"\xef"


def source() -> str:
    lines = [
        "    org $8000",
        "TM equ $2000",
        "start:",
        "    orcc #$50",
        "    lds #$7ff0",
    ]
    for i, (op, w, h, x, y, tile, maximum) in enumerate(CASES):
        target = 0x4000 + STRIDE * i
        lines += [
            "    ldx #TM",
            "    ldb #20",
            f"clear_{i}:",
            "    clr ,x+",
            "    decb",
            f"    bne clear_{i}",
            "    ldx #initial_map",
            "    ldy #$30f0",
            "    ldu #512",
            f"copy_{i}:",
            "    lda ,x+",
            "    sta ,y+",
            "    leau -1,u",
            "    cmpu #0",
            f"    bne copy_{i}",
            "    ldd #$30f0",
            "    std TM",
            "    ldd #properties",
            "    std TM+12",
        ]
        for offset, value in [
            (2, w),
            (3, h),
            (4, x & 255),
            (5, y & 255),
            (6, tile),
            (14, maximum),
        ]:
            lines += [f"    lda #{value}", f"    sta TM+{offset}"]
        lines += [
            f"    ldd #{x}",
            "    std TM+16",
            f"    ldd #{y}",
            "    std TM+18",
            f"    jsr tile_{op}",
        ]
        for offset, field in [(0, 7), (1, 6), (2, 11)]:
            lines += [f"    lda TM+{field}", f"    sta ${target + offset:04x}"]
        lines += [
            "    ldd TM+16",
            f"    std ${target + 3:04x}",
            "    ldd TM+18",
            f"    std ${target + 5:04x}",
            "    ldx #$30f0",
            f"    ldy #${target + 7:04x}",
            "    ldu #512",
            f"snapshot_{i}:",
            "    lda ,x+",
            "    sta ,y+",
            "    leau -1,u",
            "    cmpu #0",
            f"    bne snapshot_{i}",
        ]
    lines += [
        "    lda #239",
        f"    sta ${0x4000 + STRIDE * len(CASES):04x}",
        "done:",
        "    bra done",
        f'    include "{ROOT}/cross-platform/patterns/rendering/tile-map/m6809.inc"',
        "initial_map:",
        "    fcb " + ",".join(map(str, MAP)),
        "properties:",
        "    fcb " + ",".join(map(str, PROPERTIES)),
    ]
    return "\n".join(lines) + "\n"


def validate(record: dict) -> None:
    T.require(record["cases"] == CASES, "Boundary cases changed")
    T.require(bytes(record["actual"]) == expected(), "6809 boundary result changed")
    T.require(record["sources"] == bindings(), "Stale 6809 boundary evidence")
    for key in ("assembler_sha256", "emulator_sha256", "fixture_sha256"):
        T.require(
            len(record[key]) == 64
            and all(c in "0123456789abcdef" for c in record[key]),
            "Bad digest",
        )


def bindings() -> dict[str, str]:
    return {
        str(p.relative_to(ROOT)): T.sha(p)
        for p in [
            Path(__file__),
            ROOT / "cross-platform/patterns/rendering/tile-map/m6809.inc",
            ROOT / "scripts/verify-remaining-assembly-maps.py",
            ROOT / "scripts/verify-game-loops.py",
        ]
    }


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", default="asm198x")
    args = p.parse_args()
    assembler = which(args.assembler)
    T.require(assembler is not None, "Missing assembler")
    out = FOLDER / "build/boundaries"
    out.mkdir(parents=True, exist_ok=True)
    retained = FOLDER / "verification/boundaries.json"
    retained.unlink(missing_ok=True)
    caller = out / "caller.asm"
    caller.write_text(source())
    raw = out / "raw.bin"
    subprocess.run(
        [assembler, "--dialect", "lwasm", str(caller), "-o", str(raw)],
        check=True,
        timeout=45,
    )
    T.require(raw.stat().st_size <= 16382, "Boundary caller exceeds firmware socket")
    image = out / "fixture.bin"
    image.write_bytes(
        raw.read_bytes().ljust(16382, b"\x00") + struct.pack(">H", 0x8000)
    )
    emulator = args.native.resolve() / "emu198x-dragon"
    machine = T.Machine(
        [str(emulator), "--mcp", "--model", "dragon32", "--rom", str(image)]
    )
    actual = []
    try:
        machine.call("run_frames", frames=120)
        for offset in range(0, len(expected()), 256):
            actual += machine.call(
                "memory_read",
                addr=0x4000 + offset,
                len=min(256, len(expected()) - offset),
            )["bytes"]
    finally:
        machine.close()
    record = {
        "cases": CASES,
        "actual": actual,
        "sources": bindings(),
        "assembler_sha256": T.sha(Path(assembler)),
        "emulator_sha256": T.sha(emulator),
        "fixture_sha256": T.sha(image),
    }
    validate(record)
    retained.write_text(json.dumps(record, indent=2) + "\n")
    print(f"PASS 6809 {len(CASES)} boundary operations; full 512-byte map snapshots")


if __name__ == "__main__":
    main()
