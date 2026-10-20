"""Execute four native region adapters and independently check memory and pixels."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/region-architectures"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = load("region_transport", ROOT / "scripts/verify-game-loops.py")
B = load("region_builder", SHARED / "build.py")
PNG = load("region_png", ROOT / "scripts/verify-tilemaps.py")


def cells(c: dict) -> list[list[int]]:
    rows = [[0] * c["cols"] for _ in range(c["rows"])]
    for y, line in enumerate([[0, 1, 2, 3, 0], [2, 3, 0, 1, 2], [0, 1, 2, 3, 0]]):
        rows[y + 3][4:9] = line
    rows[4][6] = 0
    rows[-1][-1] = 1
    return rows


def pen(tile: int, x: int, y: int, width: int) -> int:
    if tile == 1:
        return 1 if (x + y) % 2 == 0 else 0
    if tile == 2:
        return 2 if x in (0, width - 1) or y in (0, 7) else 0
    if tile == 3:
        return 3 if x == y or x == width - 1 - y else 0
    return 0


def expected_memory(c: dict) -> bytes:
    ident = c["machine_id"]
    data = bytearray([64 if ident == "oric" else 0] * c["length"])
    grid = cells(c)
    if ident == "oric":
        for y in range(200):
            data[y * 40 : y * 40 + 2] = bytes([16, 7])
    for ty, row in enumerate(grid):
        for tx, tile in enumerate(row):
            if ident == "nintendo-game-boy":
                data[ty * 32 + tx] = tile
                continue
            for py in range(8):
                y = ty * 8 + py
                bits = [
                    pen(tile, x, py, c["pixel_width"]) for x in range(c["pixel_width"])
                ]
                if ident == "oric":
                    data[y * 40 + tx + 2] = 64 | sum(
                        bool(p) << (5 - x) for x, p in enumerate(bits)
                    )
                elif ident == "atari-800xl":
                    data[(y // 102) * 4096 + (y % 102) * 40 + tx] = sum(
                        bool(p) << (7 - x) for x, p in enumerate(bits)
                    )
                else:
                    for plane in range(2):
                        word = sum(
                            ((p >> plane) & 1) << (15 - x) for x, p in enumerate(bits)
                        )
                        offset = plane * 10240 + y * 40 + tx * 2
                        data[offset : offset + 2] = word.to_bytes(2, "big")
    return bytes([165] * 16) + data + bytes([165] * 16)


def expected_pixels(c: dict) -> tuple[tuple[int, int], bytes]:
    ident = c["machine_id"]
    geometry = {
        "oric": (240, 224, 12, 0, 1, 1),
        "atari-800xl": (376, 240, 28, 24, 1, 1),
        "nintendo-game-boy": (160, 144, 0, 0, 1, 1),
        "commodore-amiga": (768, 576, 82, 38, 2, 2),
    }
    w, h, left, top, sx, sy = geometry[ident]
    bg = (
        (4, 4, 4)
        if ident == "atari-800xl"
        else (255, 255, 255)
        if ident == "nintendo-game-boy"
        else (0, 0, 0)
    )
    raw = bytearray(bytes([*bg, 255]) * (w * h))
    grid = cells(c)
    width = c["pixel_width"]
    for y in range(c["rows"] * 8):
        for x in range(c["cols"] * width):
            p = pen(grid[y // 8][x // width], x % width, y % 8, width)
            if ident == "commodore-amiga":
                rgb = [(0, 0, 0), (255, 255, 255), (0, 255, 0), (255, 0, 0)][p]
            elif ident == "nintendo-game-boy":
                v = [255, 170, 85, 0][p]
                rgb = (v, v, v)
            elif ident == "atari-800xl":
                rgb = (211, 211, 211) if p else bg
            else:
                rgb = (255, 255, 255) if p else bg
            for dy in range(sy):
                for dx in range(sx):
                    px = left + x * sx + dx
                    py = top + y * sy + dy
                    if 0 <= px < w and 0 <= py < h:
                        offset = (py * w + px) * 4
                        raw[offset : offset + 4] = bytes([*rgb, 255])
    return (w, h), bytes(raw)


def source_paths(c: dict) -> list[Path]:
    paths = [
        ROOT / c["folder"] / "patterns/assembly/rendering/tile-region/demo.asm",
        SHARED / "build.py",
        SHARED / "systems.json",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-tilemaps.py",
    ]
    if c["cpu"] == "6502":
        paths += [SHARED.parent / "bitmap-regions/6502.inc"]
    else:
        paths += [SHARED / (c["cpu"] + ".inc")]
    if c["cpu"] == "m68000":
        paths += [SHARED / "blit-plane.inc"]
    return paths


def variants(c: dict) -> list[str]:
    ordinary = (
        ["positive"]
        + [f"reject-{i}" for i in range(3, 18)]
        + ["wrong-layout", "unsafe-destination"]
    )
    return ordinary + (
        ["blitter"]
        + [f"blitter-reject-{i}" for i in range(3, 18)]
        + ["blitter-wrong-layout", "blitter-unsafe-destination", "blitter-short"]
        if c["cpu"] == "m68000"
        else []
    )


def run(c: dict, args: argparse.Namespace, variant: str, out: Path) -> dict:
    _, image = B.build(c["machine_id"], args.assembler, variant)
    cmd = [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    if c["machine_id"] == "atari-800xl":
        cmd += ["--basic", str(image.parent / "basic.rom"), "--no-basic"]
    if c["cpu"] == "m68000":
        cmd += ["--model", "a500"]
    machine = T.Machine(cmd)
    try:
        machine.call("run_frames", frames=120)
        flags = machine.call("memory_read", addr=c["result"], len=len(c["flags"]) + 1)[
            "bytes"
        ]
        T.require(
            flags[0] == 239,
            f"{c['machine_id']} {variant}: unfinished diagnostic {flags}",
        )
        data = bytearray(machine.call("memory_read", addr=c["guard"], len=16)["bytes"])
        for offset in range(0, c["length"], 128):
            data.extend(
                machine.call(
                    "memory_read",
                    addr=c["base"] + offset,
                    len=min(128, c["length"] - offset),
                )["bytes"]
            )
        data.extend(machine.call("memory_read", addr=c["after_guard"], len=16)["bytes"])
        (out / (variant + ".bin")).write_bytes(data)
        context = machine.call("memory_read", addr=c["context"], len=32)["bytes"]
        record = {
            "flags": flags,
            "context": context,
            "memory_sha256": hashlib.sha256(data).hexdigest(),
            "fixture_sha256": T.sha(image),
        }
        if "reject-" not in variant:
            capture = out / (variant + ".png")
            machine.call("save_screenshot", path=str(capture))
            record["capture_sha256"] = T.sha(capture)
        (out / (variant + ".json")).write_text(json.dumps(record, indent=2) + "\n")
        return record
    finally:
        machine.close()


def expected_flags(c: dict, variant: str) -> list[int]:
    if "reject-" not in variant:
        return [239] + c["flags"]
    case = int(variant.split("reject-")[1])
    flags = [239] + [129] * 3 + [0] * 15 + c["flags"][18:]
    flags[case + 1] = 128
    return flags


def verify(c: dict, args: argparse.Namespace) -> None:
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/tile-region/build/verification"
    )
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    memory = expected_memory(c)
    pixels = expected_pixels(c)
    for variant in variants(c):
        r = run(c, args, variant, out)
        raw = (out / (variant + ".bin")).read_bytes()
        negative = any(
            v in variant for v in ["wrong-layout", "unsafe-destination", "short"]
        )
        if negative:
            T.require(
                raw != memory,
                f"{variant}: completed broken variant passed memory oracle",
            )
            if "wrong-layout" in variant or "short" in variant:
                T.require(
                    PNG.raster(out / (variant + ".png")) != pixels,
                    "Broken layout/blit passed pixel oracle",
                )
        else:
            T.require(
                r["flags"] == expected_flags(c, variant),
                f"{variant}: call acceptance differs {r['flags']}",
            )
            T.require(
                raw == memory,
                f"{c['machine_id']} {variant}: complete memory/guards differ",
            )
            if "reject-" not in variant:
                T.require(
                    PNG.raster(out / (variant + ".png")) == pixels,
                    f"{c['machine_id']}: independent full pixels differ",
                )
    if c["cpu"] == "m68000":
        T.require(
            (out / "positive.bin").read_bytes() == (out / "blitter.bin").read_bytes(),
            "CPU/blitter memory differs",
        )
    record = {
        "status": "passed",
        "machine_id": c["machine_id"],
        "configuration": c["mode"] + "; original reset fixture; Emu198x 0.39.0",
        "calls_per_pass": len(c["flags"]),
        "backends": ["cpu", "blitter"] if c["cpu"] == "m68000" else ["native"],
        "isolated_rejections": 30 if c["cpu"] == "m68000" else 15,
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in source_paths(c)},
        "assembler_sha256": T.sha(Path(args.assembler)),
        "emulator_sha256": T.sha(args.native / c["binary"]),
        "files": {p.name: T.sha(p) for p in out.iterdir() if p.is_file()},
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    a = p.parse_args()
    a.native = a.native.resolve()
    for c in json.loads((SHARED / "systems.json").read_text()):
        if not a.system or a.system == c["machine_id"]:
            print("VERIFY", c["machine_id"], flush=True)
            verify(c, a)
            print("PASS", c["machine_id"], flush=True)
