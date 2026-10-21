"""Run original bounded drawing callers in released native emulators.

Compare all frame pixels and destination bytes with independent logical shapes.
Completed corrupted builds must fail the very same checks as the good callers.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "tile_observer", ROOT / "scripts/verify-tilemaps.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
require = T.T.require
GLYPH = [14, 17, 17, 31, 17, 17, 17]
CONFIG = {
    "atari-2600": ("playfield-kernel", "a26"),
    "atari-7800": ("maria-objects", "bin"),
}


def expected(
    system: str, reflected: bool = False
) -> tuple[list[int], tuple[int, int], bytes]:
    if system == "atari-2600":
        cells = [[0] * 20 for _ in range(24)]
        for y, bits in enumerate(GLYPH):
            for x in range(5):
                cells[y + 4][x + 2] = (bits >> (4 - x)) & 1
        cells[23][19] = 1
        # Independent serial bit positions, specified by Stella p39.
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
            word = sum(value << positions[x] for x, value in enumerate(row))
            memory += list(word.to_bytes(3, "little"))
        w, h = 160, 240

        def on(x: int, y: int) -> bool:
            if not 14 <= y < 206:
                return False
            cx = x // 4
            cx = (39 - cx if reflected else cx - 20) if cx >= 20 else cx
            return bool(cells[(y - 14) // 8][cx])
    else:
        # Caller: two two-byte 160A objects, palette 0, at x32 and x152.
        memory = []  # header high byte depends on linked ROM placement
        w, h = 374, 240
        rows = [0] + [v for v in GLYPH for _ in range(2)] + [0]

        def on(x: int, y: int) -> bool:
            if not 50 <= y < 66:
                return False
            for origin in (32, 152):
                local = (x - 27) // 2 - origin
                if 1 <= local <= 5 and x >= 27 and rows[y - 50] & (1 << (5 - local)):
                    return True
            return False

    pixels = bytes(
        channel
        for y in range(h)
        for x in range(w)
        for channel in ((236, 236, 236, 255) if on(x, y) else (0, 0, 0, 255))
    )
    return memory, (w, h), pixels


def verify(system: str, tools: Path, out: Path, mutation: str = "") -> dict:
    name, ext = CONFIG[system]
    folder = ROOT / system / "patterns/assembly/rendering" / name
    with tempfile.TemporaryDirectory(prefix="tia-maria-check-") as temporary:
        stage = Path(temporary)
        for path in folder.iterdir():
            if path.is_file():
                (stage / path.name).write_bytes(path.read_bytes())
        if mutation:
            file, old, new = {
                "wrong-bit": (
                    "playfield.inc",
                    "!byte $10,$20,$40,$80,",
                    "!byte $80,$40,$20,$10,",
                ),
                "late-registers": (
                    "kernel.inc",
                    "    lda PF_BUFFER,y",
                    "    !fill 12,$ea\n    lda PF_BUFFER,y",
                ),
                "wrong-period": ("demo.asm", "ldx #29", "ldx #30"),
                "wrong-width": ("objects.inc", "lda #32\n    sec", "lda #31\n    sec"),
                "wrong-position": (
                    "objects.inc",
                    "lda ML+6\n    sta (ML),y",
                    "lda #0\n    sta (ML),y",
                ),
                "reflection": ("demo.asm", "sta $0a", "sta $0a"),
            }[mutation]
            path = stage / file
            text = path.read_text()
            if mutation == "reflection":
                text = text.replace("    sta $0a", "    lda #1\n    sta $0a")
            else:
                require(text.count(old) == 1, "Mutation anchor must be unique")
                text = text.replace(old, new)
            path.write_text(text)
        subprocess.run(
            ["make", f"ASM198X={tools / 'asm198x'}"],
            cwd=stage,
            check=True,
            capture_output=True,
            timeout=60,
        )
        syms = T.T.symbols(stage / "build/demo.sym")
        machine = T.T.Machine(
            [
                str(tools / f"emu198x-{system}"),
                "--mcp",
                "--cart",
                str(stage / f"build/demo.{ext}"),
            ]
        )
        try:
            reply = machine.call("run_until_pc", addr=syms["ready"], max_steps=100000)
            require(reply["reached"], "Caller did not finish its requests")
            result = machine.call("memory_read", addr=syms["RESULT"], len=3)["bytes"]
            require(result == [1, 1, 0], f"Request results: {result}")
            mem, size, pixels = expected(system, mutation == "reflection")
            if system == "atari-2600":
                actual = machine.call("memory_read", addr=0x80, len=72)["bytes"]
                memory_ok = actual == mem
                times = []
                for _ in range(3):
                    hit = machine.call(
                        "run_until_pc", addr=syms["frame"], max_steps=100000
                    )
                    require(hit["reached"], "Frame marker not reached")
                    times.append(
                        machine.call("query", path="machine.master_clock")["result"][
                            "value"
                        ]
                    )
                    machine.call("step", instructions=1)
                period = times[2] - times[1]
                require(
                    machine.call("memory_read", addr=0xE8, len=4)["bytes"][::3]
                    == [165, 165],
                    "Stack/buffer guards",
                )
            else:
                g = syms["graphics"]
                mem = [g & 255, 30, g >> 8, 32, g & 255, 30, g >> 8, 152, 0, 0]
                actual = machine.call("memory_read", addr=syms["LIST"], len=10)["bytes"]
                memory_ok = actual == mem
                require(
                    T.T.memory(machine, syms["LIST"] + 18) == 165,
                    "List capacity guard changed",
                )
                period = None
            machine.call("run_frames", frames=5)
            out.mkdir(parents=True, exist_ok=True)
            capture = out / (mutation or "native")
            capture = capture.with_suffix(".png")
            machine.call("save_screenshot", path=str(capture))
            actual_size, actual_pixels = T.raster(capture)
            require(actual_size == size, f"Native geometry {actual_size}")
            observation = {
                "completed": True,
                "system": system,
                "variant": mutation or "normal",
                "memory": actual,
                "expected_memory": mem,
                "frame_sha256": T.T.sha(capture),
                "period_colour_clocks": period,
                "frame_dimensions": size,
                "cart_sha256": T.T.sha(stage / f"build/demo.{ext}"),
                "staged_source_sha256": {
                    p.name: T.T.sha(p)
                    for p in stage.iterdir()
                    if p.suffix in (".asm", ".inc")
                },
            }
            capture.with_suffix(".json").write_text(
                json.dumps(observation, indent=2) + "\n"
            )
            require(
                period is None or period == 262 * 228,
                f"Field period {period}, expected 59736 colour clocks",
            )
            require(
                actual_pixels == pixels,
                f"Native pixels differ: {sum(a != b for a, b in zip(actual_pixels, pixels))} channels",
            )
            require(memory_ok, "Destination differs from independent requests")
            return {
                "system": system,
                "variant": mutation or "normal",
                "completed": True,
                "frame_dimensions": size,
                "frame_sha256": T.T.sha(capture),
                "memory": actual,
                "period_colour_clocks": period,
                "cart_sha256": T.T.sha(stage / f"build/demo.{ext}"),
                "source_sha256": {
                    p.name: T.T.sha(p)
                    for p in folder.iterdir()
                    if p.suffix in (".asm", ".inc")
                },
                "code_bytes": syms["pf_data_end"]
                - syms["pf_clear"]
                - 64
                + syms["pf_kernel_end"]
                - syms["pf_kernel"]
                if system == "atari-2600"
                else syms["maria_code_end"] - syms["maria_begin"],
            }
        finally:
            machine.close()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    records = []
    for system in CONFIG:
        out = args.output / system
        records.append(verify(system, args.tools, out))
        if system == "atari-2600":
            records.append(verify(system, args.tools, out, "reflection"))
        for mutation in (
            ["wrong-bit", "wrong-period", "late-registers"]
            if system == "atari-2600"
            else ["wrong-width", "wrong-position"]
        ):
            try:
                verify(system, args.tools, out, mutation)
            except AssertionError as error:
                records.append(
                    {
                        "system": system,
                        "negative_control": mutation,
                        "rejected": str(error),
                    }
                )
            else:
                raise AssertionError(f"Faulty control {mutation} passed")
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").write_text(json.dumps(records, indent=2) + "\n")
    print(json.dumps(records, indent=2))


if __name__ == "__main__":
    main()
