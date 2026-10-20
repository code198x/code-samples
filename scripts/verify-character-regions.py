"""Execute native character/colour and Electron bitmap regions against independent models."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/character-regions"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


T = load("transport", ROOT / "scripts/verify-game-loops.py")
PNG = load("png", ROOT / "scripts/verify-tilemaps.py")
B = load("builder", SHARED / "build.py")


def grid(c: dict) -> list[list[int]]:
    data = [[0] * c["cols"] for _ in range(c["rows"])]
    for y, line in enumerate([[0, 1, 2, 3, 0], [2, 3, 0, 1, 2], [0, 1, 2, 3, 0]]):
        data[y + 3][4:9] = line
    data[4][6] = 0
    data[-1][-1] = 1
    return data


def ink(code: int, x: int, y: int) -> bool:
    if code == 1:
        return (x + y) % 2 == 0
    if code == 2:
        return x in (0, 7) or y in (0, 7)
    if code == 3:
        return x == y or x == 7 - y
    return False


def memory(c: dict) -> bytes:
    parts = []
    electron = c["machine_id"] == "acorn-electron"
    for plane, (_, length, initial, _) in enumerate(c["spans"]):
        raw = bytearray([initial] * length)
        for ty, row in enumerate(grid(c)):
            for tx, tile in enumerate(row):
                if electron:
                    for py in range(8):
                        raw[ty * 320 + tx * 8 + py] = sum(
                            ink(tile, x, py) << (7 - x) for x in range(8)
                        )
                else:
                    values = (
                        [0, 3, 1, 2]
                        if plane == 0
                        else (
                            [0xF0, 0xF0, 0x10, 0x80]
                            if c["cpu"] == "z80"
                            else [1, 1, 2, 5]
                        )
                    )
                    raw[ty * c["cols"] + tx] = values[tile]
        parts.append(raw)
    parts.extend(
        bytes([value & mask] * length) for _, length, value, mask in c["guards"]
    )
    return b"".join(parts)


def pixels(c: dict) -> tuple[tuple[int, int], bytes]:
    id = c["machine_id"]
    w, h, left, top, sx = {
        "acorn-electron": (640, 256, 0, 0, 2),
        "commodore-pet": (384, 248, 32, 24, 1),
        "commodore-vic-20": (230, 288, 28, 52, 1),
        "mattel-aquarius": (352, 232, 16, 16, 1),
    }[id]
    raw = bytearray(bytes([0, 0, 0, 255]) * (w * h))
    palette = [(255, 255, 255)] * 4
    if id == "commodore-pet":
        palette = [(0, 255, 0)] * 4
    elif id == "commodore-vic-20":
        palette = [(255, 255, 255), (255, 255, 255), (120, 41, 34), (85, 160, 73)]
    elif id == "mattel-aquarius":
        palette = [(255, 255, 255), (255, 255, 255), (255, 0, 0), (0, 255, 0)]
    for y, row in enumerate(grid(c)):
        for x, tile in enumerate(row):
            code = tile if id == "acorn-electron" else [0, 3, 1, 2][tile]
            for py in range(8):
                for px in range(8):
                    rgb = palette[tile] if ink(code, px, py) else (0, 0, 0)
                    for dx in range(sx):
                        at = (
                            (top + y * 8 + py) * w + left + (x * 8 + px) * sx + dx
                        ) * 4
                        raw[at : at + 4] = bytes([*rgb, 255])
    return (w, h), bytes(raw)


def sources(c: dict) -> list[Path]:
    kernel = (
        SHARED.parent / "bitmap-regions/6502.inc"
        if c["machine_id"] == "acorn-electron"
        else SHARED / (c["cpu"] + ".inc")
    )
    return [
        ROOT / c["folder"] / "patterns/assembly/rendering/tile-region/demo.asm",
        SHARED / "build.py",
        SHARED / "systems.json",
        kernel,
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-tilemaps.py",
    ]


def command(c: dict, image: Path, native: Path) -> list[str]:
    cmd = [str(native / c["binary"]), "--mcp"]
    p = image.parent
    if c["machine_id"] == "acorn-electron":
        return cmd + ["--os", str(image), "--basic", str(p / "basic.rom")]
    if c["cpu"] == "z80":
        return cmd + [
            "--bios",
            str(image),
            "--char",
            str(p / "char.rom"),
            "--expansion-kb",
            "0",
        ]
    cmd += [
        "--kernal",
        str(image),
        "--basic",
        str(p / "basic.rom"),
        "--char",
        str(p / "char.rom"),
    ]
    if c["machine_id"] == "commodore-pet":
        return cmd + ["--editor", str(p / "editor.rom"), "--columns", "40"]
    return cmd + ["--region", "pal", "--ram-expansion", "none"]


def variants() -> list[str]:
    return (
        ["positive"]
        + [f"reject-{i}" for i in range(3, 18)]
        + ["wrong-layout", "unsafe-destination"]
    )


def flags(variant: str) -> list[int]:
    result = [239] + [129] * 3 + [128] * 15
    if variant.startswith("reject-"):
        result = [239] + [129] * 3 + [0] * 15
        result[int(variant.split("-")[1]) + 1] = 128
    elif variant == "unsafe-destination":
        result[12] = 129
    return result


def execute(c: dict, args: argparse.Namespace, variant: str, out: Path) -> None:
    _, image = B.build(c["machine_id"], args.assembler, variant)
    machine = T.Machine(command(c, image, args.native))
    try:
        machine.call("run_frames", frames=120)
        result = machine.call("memory_read", addr=c["result"], len=19)["bytes"]
        T.require(result[0] == 239, "Unfinished diagnostic: " + str(result))
        raw = bytearray()
        for addr, length, _, mask in c["spans"] + c["guards"]:
            for offset in range(0, length, 128):
                values = machine.call(
                    "memory_read", addr=addr + offset, len=min(128, length - offset)
                )["bytes"]
                raw.extend(v & mask for v in values)
        (out / (variant + ".bin")).write_bytes(raw)
        context = machine.call("memory_read", addr=c["context"], len=32)["bytes"]
        record = {
            "flags": result,
            "context": context,
            "memory_sha256": hashlib.sha256(raw).hexdigest(),
            "fixture_sha256": T.sha(image),
            "font_sha256": T.sha(image.parent / "char.rom"),
        }
        if not variant.startswith("reject-"):
            machine.call("save_screenshot", path=str(out / (variant + ".png")))
            record["capture_sha256"] = T.sha(out / (variant + ".png"))
        (out / (variant + ".json")).write_text(json.dumps(record, indent=2) + "\n")
    finally:
        machine.close()


def validate(c: dict, out: Path) -> None:
    expected = memory(c)
    for v in variants():
        r = json.loads((out / (v + ".json")).read_text())
        T.require(
            r["flags"] == flags(v), "Wrong call acceptance: " + v + str(r["flags"])
        )
        request = [0, 1, 0, 0, 2, 1]
        if v.startswith("reject-") and int(v.split("-")[1]) < 17:
            request = c["cases"][int(v.split("-")[1])]
        T.require(r["context"][:6] == request, "Changed request")
        raw = (out / (v + ".bin")).read_bytes()
        T.require(
            hashlib.sha256(raw).hexdigest() == r["memory_sha256"], "Memory hash differs"
        )
        negative = v in ["wrong-layout", "unsafe-destination"]
        T.require(
            (raw != expected) if negative else (raw == expected),
            "Whole destination/guards differ: " + v,
        )
        if not v.startswith("reject-"):
            T.require(
                T.sha(out / (v + ".png")) == r["capture_sha256"], "Capture hash differs"
            )
            if v != "unsafe-destination":
                T.require(
                    (PNG.raster(out / (v + ".png")) != pixels(c))
                    if negative
                    else (PNG.raster(out / (v + ".png")) == pixels(c)),
                    "Native pixels differ: " + v,
                )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    args = p.parse_args()
    for c in json.loads((SHARED / "systems.json").read_text()):
        if args.system and args.system != c["machine_id"]:
            continue
        out = (
            ROOT
            / c["folder"]
            / "patterns/assembly/rendering/tile-region/build/verification"
        )
        out.mkdir(parents=True, exist_ok=True)
        (out / "results.json").unlink(missing_ok=True)
        for v in variants():
            execute(c, args, v, out)
        validate(c, out)
        record = {
            "status": "passed",
            "machine_id": c["machine_id"],
            "calls": 18,
            "isolated_rejections": 15,
            "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in sources(c)},
            "assembler_sha256": T.sha(Path(args.assembler)),
            "emulator_sha256": T.sha(args.native / c["binary"]),
            "files": {p.name: T.sha(p) for p in out.iterdir() if p.is_file()},
        }
        (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
        print("PASS", c["machine_id"], flush=True)
