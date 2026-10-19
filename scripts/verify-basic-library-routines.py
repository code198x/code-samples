"""Build and ROM-load the four maintained Spectrum BASIC routines.

Pixel/attribute oracles describe rectangles, digit segments and text positions.
Firmware is supplied locally and identified by hash, never distributed.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT / "sinclair-zx-spectrum/patterns/basic"
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def addr(y: int, x: int) -> int:
    # Enumerate memory's thirds / pixel rows / character rows in address order.
    offset = 0
    for third in range(3):
        for scan in range(8):
            for row in range(8):
                if y == third * 64 + row * 8 + scan:
                    return 0x4000 + offset + x
                offset += 32
    raise ValueError("Invalid pixel row")


def boot(name: str, lines: list[str], args: argparse.Namespace) -> tuple[bytes, bytes]:
    out = args.output / name
    out.mkdir(parents=True, exist_ok=True)
    body = [
        line
        for line in (PATTERNS / (name + ".bas")).read_text().splitlines()
        if int(line.split()[0]) >= 2000
    ]
    canonical = []
    for line in sorted(lines + body, key=lambda line: int(line.split()[0])):
        number, rest = line.strip().split(maxsplit=1)
        canonical.append(f"{int(number):4d} {rest}")
    (out / "caller.bas").write_text("\n".join(canonical) + "\n")
    subprocess.run(
        [
            args.build198x,
            "basic",
            "caller.bas",
            "--machine",
            "sinclair-zx-spectrum",
            "-o",
            "caller.tap",
        ],
        cwd=out,
        capture_output=True,
        text=True,
        timeout=40,
        check=True,
    )
    m = T.Machine([args.emulator, "--mcp", "--rom", str(args.rom)])
    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(out / "caller.tap"))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        for _ in range(80):
            m.call("run_frames", frames=250)
            if T.memory(m, 60000) == 0xCA:
                break
        T.require(T.memory(m, 60000) == 0xCA, f"{name}: BASIC caller did not finish")
        data = bytearray()
        for offset in range(0, 6912, 256):
            data.extend(
                m.call(
                    "memory_read", addr=0x4000 + offset, len=min(256, 6912 - offset)
                )["bytes"]
            )
        m.call("save_screenshot", path=str(out / "finished.png"))
    finally:
        m.close()
    (out / "display.bin").write_bytes(data)
    return bytes(data[:6144]), bytes(data[6144:])


def run(args: argparse.Namespace) -> dict:
    outcomes = []
    for name in [
        "text-utilities",
        "progress-bar",
        "screen-frame",
        "seven-segment-digits",
    ]:
        if args.only and args.only != name:
            continue
        prefix = ["10 BORDER 0: PAPER 0: INK 7: BRIGHT 0: FLASH 0: CLS"]
        if name == "text-utilities":
            calls = [
                '20 LET r=2: LET t$="HELLO": GO SUB 3000',
                '30 LET r=3: LET t$="": GO SUB 3000',
                '40 LET r=4: LET t$="01234567890123456789012345678901": GO SUB 3000',
                '50 PRINT AT 5,0;"################################"',
                "60 LET r=5: GO SUB 3100",
            ]
        elif name == "progress-bar":
            calls = [
                "20 LET vm=100",
                "30 FOR b=2 TO 10: READ v: LET br=b: GO SUB 2200: NEXT b",
                "5000 DATA -1,0,1,34,36,65,68,100,200",
            ]
        elif name == "screen-frame":
            calls = ["20 LET fc=1: GO SUB 3200"]
        else:
            calls = [
                "20 INK 6",
                "30 FOR d=0 TO 9",
                "40 LET px=8+(d-INT (d/5)*5)*48: LET py=168-INT (d/5)*80",
                "50 GO SUB 2000: NEXT d",
            ]
        source = (
            prefix
            + [x for x in calls if not x.startswith("5000")]
            + ["100 POKE 60000,202: STOP"]
            + [x for x in calls if x.startswith("5000")]
        )
        bitmap, attributes = boot(name, source, args)
        if name == "text-utilities":
            expected = bytearray(6144)
            rom = args.rom.read_bytes()
            for row, col, text in [
                (2, 13, "HELLO"),
                (4, 0, "01234567890123456789012345678901"),
                (5, 0, "##"),
                (5, 30, "##"),
            ]:
                for x, char in enumerate(text):
                    for scan in range(8):
                        expected[addr(row * 8 + scan, col + x) - 0x4000] = rom[
                            0x3C00 + ord(char) * 8 + scan
                        ]
            T.require(
                all(
                    bitmap[addr(y, x) - 0x4000] == expected[addr(y, x) - 0x4000]
                    for y in range(176)
                    for x in range(32)
                ),
                "Text bitmap mismatch: odd-length floor centring or clear-row footprint",
            )
        elif name == "progress-bar":
            for row, value in enumerate([-1, 0, 1, 34, 36, 65, 68, 100, 200], start=2):
                count = min(28, max(0, value * 28 // 100))
                colour = 2 if count < 10 else 6 if count < 19 else 4
                for col in range(32):
                    paper = colour if 2 <= col < 2 + count else 0
                    T.require(
                        attributes[row * 32 + col] == paper * 8 + 7,
                        f"Progress footprint mismatch at {row, col}",
                    )
        elif name == "screen-frame":
            for row in range(22):
                for col in range(32):
                    T.require(
                        attributes[row * 32 + col]
                        == (15 if row in [0, 21] or col in [0, 31] else 7),
                        f"Frame footprint mismatch at {row, col}",
                    )
        else:
            # Named seven-segment geometry, independent of the source DATA encoding.
            active = [
                {0, 1, 2, 4, 5, 6},
                {2, 5},
                {0, 2, 3, 4, 6},
                {0, 2, 3, 5, 6},
                {1, 2, 3, 5},
                {0, 1, 3, 5, 6},
                {0, 1, 3, 4, 5, 6},
                {0, 2, 5},
                set(range(7)),
                {0, 1, 2, 3, 5, 6},
            ]
            expected = set()
            boxes = [
                (9, 30, 1, 6),
                (1, 6, 9, 22),
                (34, 39, 9, 22),
                (9, 30, 26, 31),
                (1, 6, 33, 46),
                (34, 39, 33, 46),
                (9, 30, 50, 55),
            ]
            for digit, segments in enumerate(active):
                px = 8 + (digit % 5) * 48
                py = 168 - (digit // 5) * 80
                for segment in segments:
                    l, r, t, b = boxes[segment]
                    for x in range(px + l, px + r + 1):
                        for y in range(py - b, py - t + 1):
                            expected.add((x, 175 - y))
            actual = {
                (x, y)
                for y in range(176)
                for x in range(256)
                if bitmap[addr(y, x // 8) - 0x4000] & (0x80 >> (x % 8))
            }
            T.require(actual == expected, "Seven-segment pixel geometry mismatch")
        outcomes.append(
            {"routine": name, "source_sha256": sha(PATTERNS / (name + ".bas"))}
        )
        print("PASS", name, flush=True)
    return {
        "status": "passed",
        "routines": outcomes,
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "firmware_sha256": sha(args.rom),
        "limits": "Spectrum48K ROM TAP loading, declared valid inputs and exact static display footprints. No speed or original-hardware qualification. Seven-segment rendering adds lit segments; caller clears its old rectangle before replacing a digit.",
    }


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--build198x", required=True)
    p.add_argument(
        "--rom",
        type=Path,
        default=Path.home() / ".emu198x/roms/sinclair-zx-spectrum-48k/48.rom",
    )
    p.add_argument("--output", type=Path, required=True)
    p.add_argument(
        "--only",
        choices=[
            "text-utilities",
            "progress-bar",
            "screen-frame",
            "seven-segment-digits",
        ],
    )
    p.add_argument("--expect-rejection", action="store_true")
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").unlink(missing_ok=True)
    try:
        result = run(args)
    except AssertionError as error:
        if not args.expect_rejection:
            raise
        T.require(
            str(error).startswith("Text bitmap mismatch"),
            "Unrelated regression failure: " + str(error),
        )
        result = {
            "status": "regression-characterised",
            "failure": str(error),
            "source_sha256": sha(PATTERNS / "text-utilities.bas"),
            "observer_sha256": sha(Path(__file__)),
        }
    else:
        T.require(not args.expect_rejection, "Unfixed centring unexpectedly passed")
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
