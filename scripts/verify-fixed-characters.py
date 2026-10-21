"""Execute bounded character spans on fixed-font machines; keep firmware local."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path
from types import ModuleType
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/fixed-characters"


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = load("transport", ROOT / "scripts/verify-game-loops.py")
PNG = load("png", ROOT / "scripts/verify-tilemaps.py")


def read(m: Any, addr: int, length: int) -> bytes:
    return bytes(
        v
        for o in range(0, length, 128)
        for v in m.call("memory_read", addr=addr + o, len=min(128, length - o))["bytes"]
    )


def key(m: Any, name: str) -> None:
    m.call("press_key", key=name, hold_frames=10)
    m.call("run_frames", frames=30)


def text(m: Any, s: str) -> None:
    for ch in s.lower():
        if ch.isalnum() or ch == " ":
            key(m, "space" if ch == " " else ch)
        else:
            legends = {"=": "l", "(": "i", ")": "o"}
            if ch == '"':
                m.call("type_string", text=ch, hold_frames=10, settle_frames=30)
            else:
                m.call("press_keys", keys=["shift", legends[ch]], hold_frames=10)
            m.call("run_frames", frames=30)


def boot_zx(m: Any, c: dict, p: Path) -> None:
    m.call("run_frames", frames=150)
    for line in (p / "caller.bas").read_text().splitlines():
        n, kw, *arg = line.split(maxsplit=2)
        text(m, n)
        key(
            m,
            {
                "CLS": "c" if c["id"].endswith("80") else "v",
                "PRINT": "o" if c["id"].endswith("80") else "p",
                "LET": "k" if c["id"].endswith("80") else "l",
                "INPUT": "i",
            }[kw],
        )
        if arg:
            a = arg[0]
            if kw == "LET" and c["id"].endswith("81"):
                text(m, "A=")
                m.call("press_keys", keys=["shift", "enter"], hold_frames=10)
                m.call("run_frames", frames=30)
                key(m, "l")
                text(m, "24832")
            else:
                text(m, a)
        key(m, "enter")
    data = (p / "build/demo.bin").read_bytes()
    for i, v in enumerate(data):
        m.call("poke_byte", addr=c["origin"] + i, value=v)
    # The driver owns this region; the tiny test BASIC program stays below it.
    for i in range(96):
        m.call("poke_byte", addr=c["context"] + i, value=0xA5)
    key(m, "r")
    key(m, "enter")
    m.call("run_frames", frames=150)


def execute(c: dict, args: argparse.Namespace, variant: str) -> dict:
    p = ROOT / c["id"] / "patterns/assembly/rendering/fixed-characters"
    out = p / "verification"
    out.mkdir(exist_ok=True)
    b = p / "build"
    b.mkdir(exist_ok=True)
    source = (p / "demo.asm").read_text()
    kernel = (p / "characters.inc").read_text()
    if variant == "wrong-stride":
        if c["cpu"] == "6502":
            kernel = kernel.replace("adc #40", "adc #39")
        elif "sinclair" in c["id"]:
            kernel = kernel.replace(
                "    ld a,(FC+2)\n    ld b,a\n    or a",
                "    ld a,(FC+2)\n    inc a\n    ld b,a\n    or a",
            )
        else:
            kernel = kernel.replace("ld de,40", "ld de,39")
    if variant == "unsafe-count":
        if "sinclair" in c["id"]:
            kernel = kernel.replace("    and $40\n    ret nz", "    and $40")
        elif c["cpu"] == "6502":
            kernel = kernel.replace("    bcc fc_reject\n", "")
        else:
            kernel = kernel.replace("    ret nz\nfc_count_fit:", "fc_count_fit:")
    (b / "kernel.inc").write_text(kernel)
    (b / "selected.asm").write_text(
        source.replace("characters.inc", str(b / "kernel.inc"))
    )
    subprocess.run(
        [
            str(args.assembler),
            "--dialect",
            "acme" if c["cpu"] == "6502" else "pasmo",
            "build/selected.asm",
            "-o",
            "build/demo.bin",
        ],
        cwd=p,
        check=True,
        timeout=45,
        capture_output=True,
    )
    zx = "sinclair" in c["id"]
    fw = args.firmware_root / c["id"]
    roms = []
    cmd = [str(args.native / ("emu198x-" + c["id"])), "--mcp"]
    if zx:
        rom = fw / ("zx80.rom" if c["id"].endswith("80") else "zx81.rom")
        roms = [rom]
        cmd += ["--rom", str(rom), "--ram-bytes", "16384"]
    elif c["cpu"] == "6502":
        cmd += [
            "--kernal",
            str(b / "demo.bin"),
            "--basic",
            str(fw / "basic.rom"),
            "--editor",
            str(fw / "editor.rom"),
            "--char",
            str(fw / "char.rom"),
            "--columns",
            "40",
        ]
        roms = [fw / "char.rom", fw / "basic.rom", fw / "editor.rom"]
    else:
        (b / "bios.rom").write_bytes((b / "demo.bin").read_bytes().ljust(8192, b"\0"))
        cmd += [
            "--bios",
            str(b / "bios.rom"),
            "--char",
            str(fw / "aquarius-char.rom"),
            "--expansion-kb",
            "0",
        ]
        roms = [fw / "aquarius-char.rom"]
    m = T.Machine(cmd)
    try:
        if zx:
            boot_zx(m, c, p)
        else:
            m.call("run_frames", frames=120)
        flags = read(m, c["context"] + 32, 32)
        T.require(flags[-1] == 239, f"{c['id']} incomplete {variant}: {flags.hex()}")
        if zx:
            d = int.from_bytes(read(m, 0x400C, 2), "little")
            end = int.from_bytes(read(m, 0x4010, 2), "little")
            T.require(0x4000 < d < end < 0x6000, "Display allocation")
            raw = read(m, d, end - d)
            rows = raw[1:].split(b"\x76")
            T.require(raw[0] == 118 and len(rows) >= 24, "Display-file structure")
            # Top 22 display rows remain caller-owned; lower input area may vary.
            widths = ([10, 10, 10] + [0] * 19) if c["id"].endswith("80") else [32] * 22
            observed_rows = 3 if c["id"].endswith("80") else 22
            actual = bytes([118]) + b"".join(
                row + b"\x76" for row in rows[:observed_rows]
            )
            expected = bytearray([118]) + bytearray(
                v for width in widths[:observed_rows] for v in [*([0] * width), 118]
            )
            spans = [(d, len(actual))]
        else:
            spans = [(c["screen"], 1024)] + (
                [(0x3400, 1024)] if c["id"] == "mattel-aquarius" else []
            )
            actual = b"".join(read(m, a, n) for a, n in spans)
            expected = bytearray(
                bytes([32]) * 1024 + (bytes([0xF0]) * 1024 if len(spans) == 2 else b"")
            )
        expected_flags = []
        for x, y, count, kind in c["cases"]:
            accepted = bool(
                count
                and x < c["cols"]
                and y < c["rows"]
                and count <= c["cols"] - x
                and not (c["id"] == "mattel-aquarius" and x == y == 0)
                and kind != 1
            )
            if zx and y < 22:
                accepted = accepted and x + count <= widths[y]
            expected_flags.append(128 + accepted)
            if accepted and (not zx or y < 22):
                values = (
                    [166]
                    if kind == 2
                    else (
                        [38, 39, 40, 41, 42, 43] * 7
                        if zx
                        else (
                            [1, 2, 3, 4, 5, 6] * 7
                            if c["cpu"] == "6502"
                            else [65, 66, 67, 68, 69, 70] * 7
                        )
                    )
                )[:count]
                at = 1 + sum(n + 1 for n in widths[:y]) + x if zx else y * 40 + x
                expected[at : at + count] = bytes(values)
                if len(spans) == 2:
                    expected[1024 + at : 1024 + at + count] = bytes([0x1F] * count)
        ok = (
            flags[: len(expected_flags)] == bytes(expected_flags) and actual == expected
        )
        if variant == "positive" and not ok:
            print(
                "FLAGS",
                list(flags),
                "EXPECTED",
                expected_flags,
                "DF",
                d if zx else 0,
                "DIFF",
                [(i, a, b) for i, (a, b) in enumerate(zip(actual, expected)) if a != b][
                    :30
                ],
                flush=True,
            )
        T.require(
            ok if variant == "positive" else not ok,
            "Independent memory/acceptance guard " + variant,
        )
        capture = out / (variant + ".png")
        m.call("save_screenshot", path=str(capture))
        (out / (variant + ".bin")).write_bytes(actual)
        pixel_ok, origin = check_pixels(c, expected, capture, roms[0])
        T.require(
            pixel_ok if variant == "positive" else not pixel_ok,
            "Independent visible-output guard " + variant,
        )
        record = {
            "pixel_match": pixel_ok,
            "active_origin": origin,
            "status": "passed",
            "variant": variant,
            "server": m.server["serverInfo"],
            "flags": list(flags),
            "spans": spans,
            "memory_sha256": T.sha(out / (variant + ".bin")),
            "capture_sha256": T.sha(capture),
            "firmware_sha256": [T.sha(x) for x in roms],
            "emulator_sha256": T.sha(args.native / ("emu198x-" + c["id"])),
            "fixture_sha256": T.sha(b / "demo.bin"),
            "independent_memory_match": ok,
        }
        if variant == "positive":
            record["sources"] = {
                str(f.relative_to(ROOT)): T.sha(f)
                for f in [
                    p / "demo.asm",
                    p / "characters.inc",
                    Path(__file__),
                    SHARED / "systems.json",
                ]
                + ([p / "caller.bas"] if zx else [])
            }
        (out / (variant + ".json")).write_text(json.dumps(record, indent=2) + "\n")
        print(c["id"], variant, "completed; memory guard", ok, flush=True)
        return record
    finally:
        m.close()


def check_pixels(
    c: dict, expected: bytes | bytearray, capture: Path, font_path: Path
) -> tuple[bool, tuple[int, int] | None]:
    (w, h), rgba = PNG.raster(capture)
    T.require(len(rgba) == w * h * 4, "Native capture must be RGBA")
    zx = "sinclair" in c["id"]
    pet = c["cpu"] == "6502"
    font = font_path.read_bytes()
    cols = c["cols"]
    rows = (3 if c["id"].endswith("80") else 22) if zx else 25
    font_base = (0xE00 if c["id"].endswith("80") else 0x1E00) if zx else 0
    width = cols * 8
    height = rows * 8
    body = bytearray(width * height * 4)
    for y in range(rows):
        for x in range(cols):
            at = y * 40 + x
            if zx:
                line = expected[1:].split(b"\x76")[y]
                code = line[x] if x < len(line) else 0
            else:
                code = expected[at]
            if zx:
                pattern = font[
                    font_base + (code & 63) * 8 : font_base + (code & 63) * 8 + 8
                ]
                pattern = bytes(v ^ 255 for v in pattern) if code & 128 else pattern
                fg = (0, 0, 0)
                bg = (255, 255, 255)
            else:
                pattern = font[code * 8 : code * 8 + 8]
                if pet:
                    fg = (0, 255, 0)
                    bg = (0, 0, 0)
                else:
                    attr = expected[1024 + at]
                    palette = {0: (0, 0, 0), 1: (255, 0, 0), 15: (255, 255, 255)}
                    fg = palette[attr >> 4]
                    bg = palette[attr & 15]
            for py in range(8):
                for px in range(8):
                    colour = fg if pattern[py] & (128 >> px) else bg
                    offset = ((y * 8 + py) * width + x * 8 + px) * 4
                    body[offset : offset + 4] = bytes((*colour, 255))

    def matches(left: int, top: int) -> bool:
        return all(
            rgba[((top + y) * w + left) * 4 : ((top + y) * w + left + width) * 4]
            == body[y * width * 4 : (y + 1) * width * 4]
            for y in range(height)
        )

    if not zx:
        origin = (32, 24) if pet else (16, 16)
        ok = matches(*origin)
        # Check every border pixel too; Aquarius cell zero stays a blank space.
        if ok:
            for y in range(h):
                for x in range(w):
                    outside = not (
                        origin[0] <= x < origin[0] + width
                        and origin[1] <= y < origin[1] + height
                    )
                    if outside and rgba[(y * w + x) * 4 : (y * w + x + 1) * 4] != bytes(
                        [0, 0, 0, 255]
                    ):
                        return False, origin
        return ok, origin
    # Align one six-letter landmark, then compare the ENTIRE 32x22 cell area.
    # A single global translation allows native PAL frame padding, not tile drift.
    hits = []
    for top in range(h - height + 1):
        for left in range(w - width + 1):
            row = bytes(body[width * 4 : width * 8])
            if rgba[
                ((top + 1) * w + left) * 4 : ((top + 1) * w + left + width) * 4
            ] == row and matches(left, top):
                hits.append((left, top))
    return len(hits) == 1, hits[0] if len(hits) == 1 else None


def main() -> None:
    a = argparse.ArgumentParser(description=__doc__)
    a.add_argument("--native", type=Path, required=True)
    a.add_argument("--assembler", type=Path, required=True)
    a.add_argument("--firmware-root", type=Path, default=Path.home() / ".emu198x/roms")
    a.add_argument("--only")
    args = a.parse_args()
    for c in json.loads((SHARED / "systems.json").read_text()):
        if args.only and args.only != c["id"]:
            continue
        records = [
            execute(c, args, v) for v in ["positive", "wrong-stride", "unsafe-count"]
        ]
        out = (
            ROOT / c["id"] / "patterns/assembly/rendering/fixed-characters/verification"
        )
        (out / "results.json").write_text(
            json.dumps(
                {
                    "status": "passed",
                    "machine_id": c["id"],
                    "configuration": "Stock Sinclair ROM, PAL, 16 KiB RAM; BASIC USR caller"
                    if "sinclair" in c["id"]
                    else "Original reset driver with local stock character ROM; no stock OS qualification",
                    "records": records,
                },
                indent=2,
            )
            + "\n"
        )


if __name__ == "__main__":
    main()
