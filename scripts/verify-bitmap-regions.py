"""Execute CPU bitmap regions; compare full memory and independently composed pixels."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/bitmap-regions"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


T = load("bitmap_transport", ROOT / "scripts/verify-game-loops.py")
B = load("bitmap_build", SHARED / "build.py")
PNG = load("bitmap_png", ROOT / "scripts/verify-tilemaps.py")


def cells(cfg: dict) -> list[list[int]]:
    result = [[0] * cfg["cols"] for _ in range(cfg["rows"])]
    # A non-square 5x3 selection from (2,1) of a 12x8 world.
    for row, line in enumerate([[0, 1, 2, 3, 0], [2, 3, 0, 1, 2], [0, 1, 2, 3, 0]]):
        result[row + 3][4:9] = line
    result[4][6] = 0
    result[-1][-1] = 1
    return result


def pen(tile: int, x: int, y: int) -> int:
    if tile == 1:
        return 1 if (x + y) % 2 == 0 else 0
    if tile == 2:
        return 2 if x in (0, 7) or y in (0, 7) else 0
    if tile == 3:
        return 3 if x == y or x == 7 - y else 0
    return 0


def expected_memory(cfg: dict) -> bytes:
    data = bytearray(cfg["length"])
    grid = cells(cfg)
    for ty, line in enumerate(grid):
        for tx, tile in enumerate(line):
            for py in range(8):
                y = ty * 8 + py
                if cfg["machine_id"] == "acorn-bbc-micro":
                    offset = ty * 320 + tx * 8 + py
                elif cfg["machine_id"] == "amstrad-cpc":
                    offset = py * 2048 + ty * 80 + tx * 2
                else:
                    offset = y * 32 + tx
                if cfg["bpc"] == 1:
                    data[offset] = sum(
                        bool(pen(tile, x, py)) << (7 - x) for x in range(8)
                    )
                else:
                    for group in range(2):
                        data[offset + group] = sum(
                            ((pen(tile, group * 4 + x, py) & 1) << (7 - x))
                            | (((pen(tile, group * 4 + x, py) >> 1) & 1) << (3 - x))
                            for x in range(4)
                        )
    return bytes([165] * 16) + bytes(data)


def expected_pixels(cfg: dict) -> tuple[tuple[int, int], bytes]:
    ident = cfg["machine_id"]
    geometry = {
        "acorn-bbc-micro": (640, 512, 0, 0, 2, 2),
        "acorn-atom": (372, 288, 60, 48, 1, 1),
        "dragon": (744, 312, 120, 63, 2, 1),
        "amstrad-cpc": (832, 288, 96, 48, 2, 1),
    }
    w, h, left, top, sx, sy = geometry[ident]
    border = {"acorn-atom": (0, 64, 0), "dragon": (5, 5, 5)}.get(ident, (0, 0, 0))
    bg = {"acorn-atom": (0, 32, 0), "dragon": (0, 16, 0)}.get(ident, (0, 0, 0))
    image = bytearray(bytes([*border, 255]) * (w * h))
    grid = cells(cfg)
    for y in range(cfg["rows"] * 8):
        for x in range(cfg["cols"] * 8):
            p = pen(grid[y // 8][x // 8], x % 8, y % 8)
            rgb = bg
            if p:
                rgb = (
                    [(0, 0, 0), (255, 255, 255), (0, 255, 0), (0, 0, 255)][p]
                    if ident == "amstrad-cpc"
                    else (29, 170, 29)
                    if ident in ("acorn-atom", "dragon")
                    else (255, 255, 255)
                )
            for dy in range(sy):
                for dx in range(sx):
                    at = ((top + y * sy + dy) * w + left + x * sx + dx) * 4
                    image[at : at + 4] = bytes([*rgb, 255])
    return (w, h), bytes(image)


def execute(cfg: dict, args: argparse.Namespace, variant: str, out: Path) -> dict:
    _, image = B.build(cfg["machine_id"], args.assembler, variant)
    m = T.Machine(
        [str(args.native / cfg["binary"]), "--mcp", "--" + cfg["kind"], str(image)]
    )
    try:
        m.call("run_frames", frames=150)
        flags = m.call("memory_read", addr=cfg["result"], len=19)["bytes"]
        T.require(
            flags[0] == 239,
            f"{cfg['machine_id']} {variant}: no completion marker {flags}",
        )
        data = bytearray(m.call("memory_read", addr=cfg["guard"], len=16)["bytes"])
        for offset in range(0, cfg["length"], 128):
            data.extend(
                m.call(
                    "memory_read",
                    addr=cfg["base"] + offset,
                    len=min(128, cfg["length"] - offset),
                )["bytes"]
            )
        (out / (variant + ".bin")).write_bytes(data)
        result = {
            "flags": flags,
            "memory_sha256": hashlib.sha256(data).hexdigest(),
            "fixture_sha256": T.sha(image),
        }
        if not variant.startswith("reject-"):
            path = out / (variant + ".png")
            m.call("save_screenshot", path=str(path))
            result["capture_sha256"] = T.sha(path)
        (out / (variant + ".json")).write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        m.close()


def sources(cfg: dict) -> list[Path]:
    return [
        ROOT / cfg["folder"] / "patterns/assembly/rendering/tile-region/demo.asm",
        SHARED / (cfg["cpu"] + ".inc"),
        SHARED / "systems.json",
        SHARED / "build.py",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-tilemaps.py",
    ]


def verify(cfg: dict, args: argparse.Namespace) -> dict:
    out = (
        ROOT
        / cfg["folder"]
        / "patterns/assembly/rendering/tile-region/build/verification"
    )
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    expected = expected_memory(cfg)
    r = execute(cfg, args, "positive", out)
    T.require(r["flags"] == [239] + cfg["flags"], "Acceptance/rejection markers differ")
    T.require(
        (out / "positive.bin").read_bytes() == expected,
        "Complete bitmap/guard mismatch",
    )
    T.require(
        PNG.raster(out / "positive.png") == expected_pixels(cfg),
        "Independent native pixel composition differs",
    )
    for case in range(3, 18):
        label = f"reject-{case}"
        r = execute(cfg, args, label, out)
        flags = [239] + [129] * 3 + [0] * 15
        flags[case + 1] = 128
        T.require(r["flags"] == flags, f"{label}: isolated rejection did not execute")
        T.require(
            (out / (label + ".bin")).read_bytes() == expected,
            f"{label}: rejected call changed bitmap/guard",
        )
    for variant in ["wrong-layout", "unsafe-destination"]:
        execute(cfg, args, variant, out)
        T.require(
            (out / (variant + ".bin")).read_bytes() != expected,
            f"{variant}: broken variant passed memory oracle",
        )
        if variant == "wrong-layout":
            T.require(
                PNG.raster(out / (variant + ".png")) != expected_pixels(cfg),
                "Wrong layout passed pixels",
            )
    record = {
        "status": "passed",
        "machine_id": cfg["machine_id"],
        "configuration": f"Original reset diagnostic; {cfg['mode']}; released Emu198x 0.39.0",
        "calls": 18,
        "isolated_rejections": 15,
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in sources(cfg)},
        "assembler_sha256": T.sha(Path(args.assembler)),
        "emulator_sha256": T.sha(args.native / cfg["binary"]),
        "files": {p.name: T.sha(p) for p in out.iterdir() if p.is_file()},
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    return record


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    a = p.parse_args()
    a.native = a.native.resolve()
    for cfg in json.loads((SHARED / "systems.json").read_text()):
        if not a.system or cfg["machine_id"] == a.system:
            print("VERIFY", cfg["machine_id"], flush=True)
            verify(cfg, a)
            print("PASS", cfg["machine_id"], flush=True)
