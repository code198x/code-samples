"""Execute and retain the customisation callers; compare independent logical pictures."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "drawing", ROOT / "scripts/verify-tia-maria.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
ARROW = [4, 2, 31, 2, 4, 0, 0]
SHIP = [
    "000001100000",
    "000011110000",
    "000112211000",
    "001122221100",
    "011122221110",
    "111122221111",
    "110011110011",
    "100011110001",
    "000011110000",
    "000013310000",
    "000033330000",
    "000003300000",
    "000003300000",
    "000000000000",
    "000000000000",
    "000000000000",
]
CASES = {
    "maze": ("atari-2600", "playfield-kernel", "a26"),
    "reflected": ("atari-2600", "playfield-kernel", "a26"),
    "ships": ("atari-7800", "maria-objects", "bin"),
}
# The selected release's NTSC RGB palette, not a physical television standard.
COLOURS = [
    [(0, 0, 0), (236, 236, 236), (144, 144, 144), (200, 200, 200)],
    [(0, 0, 0), (80, 92, 192), (144, 164, 236), (164, 184, 252)],
]


def expected(case: str) -> tuple[list[int], tuple[int, int], bytes]:
    if case != "ships":
        cells = [
            [int(x in (0, 19) or y in (0, 23)) for x in range(20)] for y in range(24)
        ]
        for x in range(10):
            if x != 4:
                cells[13][x] = 1
        for y in range(8, 21):
            if y != 16:
                cells[y][13] = 1
        cells[0][4] = 0
        for y, bits in enumerate(ARROW):
            for x in range(5):
                cells[y + 4][x + 2] = (bits >> (4 - x)) & 1
        positions = [
            4,
            5,
            6,
            7,
            15,
            14,
            13,
            12,
            11,
            10,
            9,
            8,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
        ]
        memory = []
        for row in cells:
            memory += list(
                sum(v << positions[x] for x, v in enumerate(row)).to_bytes(3, "little")
            )
        width, height = 160, 240

        def colour(x: int, y: int) -> tuple[int, int, int]:
            if not 14 <= y < 206:
                return (0, 0, 0)
            cx = x // 4
            if cx >= 20:
                cx = 39 - cx if case == "reflected" else cx - 20
            return (192, 88, 88) if cells[(y - 14) // 8][cx] else (0, 0, 0)
    else:
        memory = []
        width, height = 374, 240

        def colour(x: int, y: int) -> tuple[int, int, int]:
            if not 50 <= y < 66 or x < 27:
                return (0, 0, 0)
            for palette, origin in enumerate((24, 100)):
                local = (x - 27) // 2 - origin
                if 0 <= local < 12:
                    index = int(SHIP[y - 50][local])
                    if index:
                        return COLOURS[palette][index]
            return (0, 0, 0)

    pixels = bytes(
        c for y in range(height) for x in range(width) for c in (*colour(x, y), 255)
    )
    return memory, (width, height), pixels


def verify(case: str, tools: Path, output: Path) -> dict:
    machine, name, ext = CASES[case]
    folder = ROOT / machine / "patterns/assembly/rendering" / name / "customise"
    subprocess.run(
        ["make", f"ASM198X={tools / 'asm198x'}"],
        cwd=folder,
        check=True,
        capture_output=True,
        timeout=60,
    )
    symbols = V.T.T.symbols(folder / f"build/{case}.sym")
    cart = folder / f"build/{case}.{ext}"
    emulator = V.T.T.Machine(
        [str(tools / f"emu198x-{machine}"), "--mcp", "--cart", str(cart)]
    )
    try:
        V.require(
            emulator.call("run_until_pc", addr=symbols["ready"], max_steps=100000)[
                "reached"
            ],
            "Custom setup incomplete",
        )
        memory, size, pixels = expected(case)
        if case != "ships":
            actual = emulator.call("memory_read", addr=0x80, len=72)["bytes"]
            V.require(V.T.T.memory(emulator, symbols["RESULT"]) == 1, "Stamp failed")
            V.require(
                emulator.call("memory_read", addr=0xE8, len=4)["bytes"][::3]
                == [165, 165],
                "RIOT guards",
            )
            clocks = []
            for _ in range(3):
                V.require(
                    emulator.call(
                        "run_until_pc", addr=symbols["frame"], max_steps=100000
                    )["reached"],
                    "Field marker",
                )
                clocks.append(
                    emulator.call("query", path="machine.master_clock")["result"][
                        "value"
                    ]
                )
                emulator.call("step", instructions=1)
            period = clocks[-1] - clocks[-2]
            V.require(period == 59736, "Custom caller changed field timing")
        else:
            g = symbols["graphics"]
            memory = [g & 255, 29, g >> 8, 24, g & 255, 61, g >> 8, 100, 0, 0]
            actual = emulator.call("memory_read", addr=0x1900, len=10)["bytes"]
            V.require(
                emulator.call("memory_read", addr=symbols["RESULT"], len=2)["bytes"]
                == [1, 1],
                "Ship append failed",
            )
            V.require(V.T.T.memory(emulator, 0x1912) == 165, "List guard")
            # Inspect every original source row using its independent logical pixels.
            for y, row in enumerate(SHIP):
                packed = [
                    sum(int(row[j * 4 + i]) << (6 - 2 * i) for i in range(4))
                    for j in range(3)
                ]
                V.require(
                    emulator.call("memory_read", addr=g + (15 - y) * 256, len=3)[
                        "bytes"
                    ]
                    == packed,
                    "Page-stepped ship row",
                )
            period = None
        V.require(actual == memory, "Custom buffer/list mismatch")
        emulator.call("run_frames", frames=5)
        output.mkdir(parents=True, exist_ok=True)
        capture = output / (case + ".png")
        emulator.call("save_screenshot", path=str(capture))
        actual_size, actual_pixels = V.T.raster(capture)
        V.require(
            (actual_size, actual_pixels) == (size, pixels),
            "Custom native picture/palette mismatch",
        )
        sources = (
            list(folder.glob("*.asm"))
            + list(folder.glob("*.inc"))
            + [folder / "Makefile"]
            + list(folder.parent.glob("*.inc"))
        )
        record = {
            "case": case,
            "system": machine,
            "completed": True,
            "memory": actual,
            "size": size,
            "frame_sha256": V.T.T.sha(capture),
            "cart_sha256": V.T.T.sha(cart),
            "period_colour_clocks": period,
            "startup_code_bytes": symbols["ready"] - symbols["start"],
            "sources": {str(p.relative_to(ROOT)): V.T.T.sha(p) for p in sources},
        }
        (output / (case + ".json")).write_text(json.dumps(record, indent=2) + "\n")
        return record
    finally:
        emulator.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    records = [verify(case, args.tools, args.output) for case in CASES]
    (args.output / "results.json").write_text(json.dumps(records, indent=2) + "\n")
    print(json.dumps(records, indent=2))
