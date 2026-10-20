"""Execute native region drawing and compare VDP readback and rendered pixels."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/tile-region"


def load(name: str, path: Path):
    s = importlib.util.spec_from_file_location(name, path)
    assert s and s.loader
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


T = load("region_transport", ROOT / "scripts/verify-game-loops.py")
B = load("region_builder", SHARED / "build.py")
PNG = load("region_png", ROOT / "scripts/verify-tilemaps.py")


def expected_tiles() -> list[list[int]]:
    cells = [[0 for _ in range(32)] for _ in range(24)]
    selected = [
        [0, 1, 2, 3, 0, 1, 2],
        [2, 3, 0, 1, 2, 3, 0],
        [0, 1, 2, 3, 0, 1, 2],
        [2, 3, 0, 1, 2, 3, 0],
        [0, 1, 2, 3, 0, 1, 2],
    ]
    for row, line in enumerate(selected):
        for column, tile in enumerate(line):
            cells[5 + row][8 + column] = tile
    cells[7][10] = 3
    cells[12][22] = 1
    cells[23][31] = 1
    cells[20][25] = 3
    return cells


def expected_vram(cfg: dict) -> list[int]:
    data = []
    for row in expected_tiles():
        for tile in row:
            if cfg["cell_bytes"] == 1:
                data.append([0, 8, 16, 24][tile])
            else:
                data.extend([tile, 2 if tile == 3 else 0])
    # TMS sprite attributes follow the name table; preserve their terminator.
    return data + ([208] + [0] * 31 if cfg["cell_bytes"] == 1 else [0] * 32)


def expected_flags() -> list[int]:
    return [239, 129] + [128] * 17 + [129] * 4


def expected_pixels(cfg: dict) -> tuple[tuple[int, int], bytes]:
    """Independent fixture compositor, not the emulator's VDP implementation.

    Dimensions/offsets are the released emulator's raw frame windows, not a
    claim that all PAL/NTSC displays crop at these exact pixels. RGB is the
    release's documented TI palette conversion or saturated Sega CRAM values.
    """
    pal = cfg["machine_id"] in ["memotech-mtx", "tatung-einstein"]
    gg = cfg["mode"] == "gg"
    w, h = (160, 144) if gg else ((278, 288) if pal else (280, 240))
    ox, oy = (-48, -24) if gg else ((w - 256) // 2, 51 if pal else 25)
    image = bytearray(bytes([0, 0, 0, 255]) * (w * h))
    glyphs = [
        [0] * 8,
        [0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55],
        [0x81, 0x42, 0x24, 0x18, 0x18, 0x24, 0x42, 0x81],
        [0x08, 0x0C, 0xFE, 0xFF, 0xFE, 0x0C, 0x08, 0],
    ]
    colours = (
        [(0, 0, 0), (94, 220, 120), (252, 85, 84), (230, 206, 128)]
        if cfg["mode"] == "tms"
        else [(0, 0, 0), (0, 255, 0), (255, 0, 0), (255, 255, 0)]
    )
    for row, tiles in enumerate(expected_tiles()):
        for column, tile in enumerate(tiles):
            for y, bits in enumerate(glyphs[tile]):
                for x in range(8):
                    px, py = ox + column * 8 + x, oy + row * 8 + y
                    if not (0 <= px < w and 0 <= py < h):
                        continue
                    bit = x if cfg["cell_bytes"] == 2 and tile == 3 else 7 - x
                    rgb = colours[tile] if bits & (1 << bit) else (0, 0, 0)
                    offset = (py * w + px) * 4
                    image[offset : offset + 4] = bytes([*rgb, 255])
    return (w, h), bytes(image)


def execute(
    cfg: dict, native: Path, assembler: str, variant: str, output: Path
) -> dict:
    _, image = B.build(cfg["machine_id"], assembler, variant)
    executable = native / cfg["binary"]
    command = [str(executable), "--mcp", "--" + cfg["kind"], str(image)]
    machine = T.Machine(command)
    try:
        machine.call("run_frames", frames=120)
        flags = machine.call("memory_read", addr=cfg["results"], len=23)["bytes"]
        T.require(
            flags[0] == 239,
            f"{cfg['machine_id']} {variant}: diagnostic did not complete: {flags}",
        )
        data = []
        for offset in range(0, cfg["dump_length"], 128):
            data += machine.call(
                "memory_read",
                addr=cfg["ram"] + offset,
                len=min(128, cfg["dump_length"] - offset),
            )["bytes"]
        png = output / (variant + ".png")
        machine.call("save_screenshot", path=str(png))
        result = {
            "flags": flags,
            "vram": data,
            "fixture_sha256": T.sha(image),
            "capture_sha256": T.sha(png),
        }
        (output / (variant + ".json")).write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        machine.close()


def verify(cfg: dict, native: Path, assembler: str) -> dict:
    folder = ROOT / cfg["folder"] / "patterns/assembly/rendering/tile-region"
    output = folder / "build/verification"
    output.mkdir(parents=True, exist_ok=True)
    (output / "results.json").unlink(missing_ok=True)
    sources = [
        folder / "demo.asm",
        SHARED / "region.inc",
        SHARED / "systems.json",
        SHARED / "build.py",
        SHARED.parent / "tile-map/z80.inc",
        Path(__file__),
        ROOT / "scripts/verify-tilemaps.py",
        ROOT / "scripts/verify-game-loops.py",
    ]
    identities = {str(p.relative_to(ROOT)): T.sha(p) for p in sources}
    actual = execute(cfg, native, assembler, "positive", output)
    T.require(
        actual["flags"] == expected_flags(),
        f"{cfg['machine_id']}: acceptance/rejection flags differ",
    )
    T.require(
        actual["vram"] == expected_vram(cfg),
        f"{cfg['machine_id']}: full name table/guard differs",
    )
    T.require(
        PNG.raster(output / "positive.png") == expected_pixels(cfg),
        f"{cfg['machine_id']}: rendered pixels differ",
    )
    for variant in ["wrong-stride", "unsafe-destination"]:
        wrong = execute(cfg, native, assembler, variant, output)
        T.require(
            wrong["vram"] != expected_vram(cfg),
            f"{cfg['machine_id']}: {variant} did not fail VDP readback",
        )
        if variant == "wrong-stride":
            T.require(
                PNG.raster(output / (variant + ".png")) != expected_pixels(cfg),
                f"{cfg['machine_id']}: {variant} did not fail pixels",
            )
    for path, digest in identities.items():
        T.require(
            T.sha(ROOT / path) == digest, "Source changed during verification: " + path
        )
    result = {
        "status": "passed",
        "machine_id": cfg["machine_id"],
        "configuration": "Original reset diagnostic; VDP registers, VRAM, pattern/colour tables and foreground CPU owned by caller; display blanked during drawing",
        "mode": cfg["mode"],
        "sources": identities,
        "emulator_sha256": T.sha(native / cfg["binary"]),
        "assembler_sha256": T.sha(Path(assembler)),
        "case_count": 22,
        "readback_bytes": cfg["dump_length"],
        "pixel_comparison": "Whole decoded raw native framebuffer, including borders or Game Gear window",
        "completed_negative_controls": ["wrong-stride", "unsafe-destination"],
        "limits": "Emu198x 0.39.0 selected machine/default video model only. No original hardware, stock-OS loader, IRQ coexistence, VBlank throughput or concurrent-map modification qualification.",
    }
    (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("PASS", cfg["machine_id"], flush=True)
    return result


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--only")
    a = p.parse_args()
    configs = json.loads((SHARED / "systems.json").read_text())
    if a.only:
        configs = [c for c in configs if c["machine_id"] == a.only]
    T.require(bool(configs), "No matching machines")
    for cfg in configs:
        verify(cfg, a.native.resolve(), str(Path(a.assembler).resolve()))


if __name__ == "__main__":
    main()
