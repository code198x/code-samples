"""Compare pixel-positioned masked sprites with an independent pixel oracle.

48K PAL ROM/tape, Model B MOS1.20/BASICII MODE4 and A500 OCS PAL/KS1.3.
Static phase galleries with frame servicing; no motion cadence, original-hardware
or whole-game frame-budget claim. Firmware and injected snapshots stay local.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "clip", ROOT / "scripts/verify-sprite-clipping.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
R, Z, T, L = C.R, C.Z, C.T, C.L
SYSTEMS = C.SYSTEMS
HOST = ROOT / "cross-platform/patterns/rendering/pre-shifted-sprites"


def folder(system: str) -> Path:
    return ROOT / SYSTEMS[system] / "patterns/assembly/rendering/pre-shifted-sprites"


def positions(system: str) -> list[tuple[int, int]]:
    n = 16 if system == "amiga" else 8
    w = 320 if system != "spectrum" else 256
    h = 192 if system == "spectrum" else 256
    xs = [16 + (p % 8) * 32 + p if system == "amiga" else 8 + 25 * p for p in range(n)]
    return (
        [(xs[p], 40 + (p // 8) * 32) for p in range(n)]
        + [(xs[p], -8) for p in range(n)]
        + [(xs[p], h - 8) for p in range(n)]
        + [(-n + p, 80 + p * 10) for p in range(n)]
        + [(w - n + p, 80 + p * 10) for p in range(n)]
    )


def pixel_address(system: str, x: int, y: int) -> tuple[int, int]:
    if system == "spectrum":
        return Z.screen_address(y, x // 8) - 0x4000, 128 >> (x % 8)
    if system == "bbc":
        return (y // 8) * 320 + (x // 8) * 8 + y % 8, 128 >> (x % 8)
    return y * 40 + x // 8, 128 >> (x % 8)


def expected(system: str) -> bytes:
    width, height = (256, 192) if system == "spectrum" else (320, 256)
    image = bytearray(6144 if system == "spectrum" else 10240)
    for y in range(0, height, 8):
        for x in range(width):
            if x % 8 in [3, 7]:
                a, b = pixel_address(system, x, y)
                image[a] |= b
    rows = json.loads((HOST / "sprite.json").read_text())
    for x, y in positions(system):
        for sy, row in enumerate(rows):
            for sx, value in enumerate(row):
                if value != "." and 0 <= x + sx < width and 0 <= y + sy < height:
                    a, b = pixel_address(system, x + sx, y + sy)
                    if value == "1":
                        image[a] |= b
                    else:
                        image[a] &= 255 ^ b
    return bytes(image)


def prepared_bytes(system: str, phase: int) -> tuple[bytes, bytes]:
    # Reconstruct one output sample at a time. No generator shifts or packing logic.
    rows = json.loads((HOST / "sprite.json").read_text())
    width = 32 if system == "amiga" else 24
    mask = bytearray()
    ink = bytearray()
    for y in range(16):
        for byte in range(width // 8):
            m = v = 0
            for bit in range(8):
                x = byte * 8 + bit - phase
                value = rows[y][x] if 0 <= x < 16 else "."
                if (value != ".") if system == "amiga" else (value == "."):
                    m |= 128 >> bit
                if value == "1":
                    v |= 128 >> bit
            mask.append(m)
            ink.append(v)
    return bytes(mask), bytes(ink)


def asset_bytes(system: str, symbols: dict[str, int], base: int = 0) -> bytes:
    n = 16 if system == "amiga" else 8
    if system == "amiga":
        pointers = b"".join(
            (base + symbols[f"sprite_phase_{p}_{kind}"]).to_bytes(4, "big")
            for p in range(n)
            for kind in ["mask", "image"]
        )
        data = b"".join(
            mask + image
            for mask, image in (prepared_bytes(system, p) for p in range(n))
        )
    else:
        pointers = b"".join(
            symbols[f"sprite_phase_{p}"].to_bytes(2, "little") for p in range(n)
        )
        data = b"".join(
            bytes(v for pair in zip(mask, image, strict=True) for v in pair)
            for mask, image in (prepared_bytes(system, p) for p in range(n))
        )
    return pointers + data


def variant(source: str, system: str, broken: str) -> str:
    if not broken:
        return source
    if broken == "phase":
        old, new = {
            "spectrum": ("    and 7", "    xor a"),
            "bbc": (
                "    and #7\n    asl\n    sta phase_mask_byte",
                "    and #0\n    asl\n    sta phase_mask_byte",
            ),
            "amiga": ("    and.w #15,d3", "    moveq #0,d3"),
        }[system]
    elif broken == "stride":
        old, new = {
            "spectrum": ("    ld bc,6", "    ld bc,4"),
            "bbc": ("    adc #6", "    adc #4"),
            "amiga": ("    moveq #4,d3", "    moveq #2,d3"),
        }[system]
    else:
        old, new = {
            "spectrum": ("    sra h", "    srl h"),
            "bbc": ("    cmp #$80\n    ror", "    clc\n    ror"),
            "amiga": ("    asr.w #4,d0", "    lsr.w #4,d0"),
        }[system]
    C.require(old in source, "Missing deliberate mutation target")
    return source.replace(old, new)


def bbc_load(args: argparse.Namespace, out: Path, data: bytes, injected: bool) -> Any:
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
        if injected:
            m.call("type_string", text="MODE 4\n", hold_frames=2, settle_frames=10)
            for i in range(0, len(data) - 1, 2):
                m.call(
                    "poke_word",
                    addr=0x4000 + i,
                    value=int.from_bytes(data[i : i + 2], "little"),
                )
            if len(data) % 2:
                m.call("poke_byte", addr=0x4000 + len(data) - 1, value=data[-1])
            C.require(
                R.read(m, 0x4000, len(data)) == data,
                "BBC injected fixture differs from assembled bytes",
            )
            m.call("type_string", text="CALL &4000\n", hold_frames=2, settle_frames=10)
        else:
            loader = R.module("loader", folder("bbc") / "loader.py")
            lines = loader.lines(data)
            (out / "loader.bas").write_text("\n".join(lines) + "\n")
            for line in lines:
                m.call("type_string", text=line + "\n", hold_frames=2, settle_frames=2)
            m.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
        return m
    except BaseException:
        m.close()
        raise


def observe(args: argparse.Namespace, out: Path, system: str, broken: str = "") -> None:
    out.mkdir(parents=True, exist_ok=True)
    source = variant(C.flatten(folder(system) / "demo.asm"), system, broken)
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
        base = 0
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
            C.require(
                R.read(m, symbols["ready"], 2) == b"\xfe\xca",
                "Spectrum phase tape did not start",
            )
            picture = R.read(m, 0x4000, 6144)
            C.require(
                R.read(m, 0x5800, 768) == bytes([71]) * 768,
                "Spectrum attributes changed",
            )
            assets = R.read(
                m,
                symbols["sprite_assets_begin"],
                symbols["sprite_assets_end"] - symbols["sprite_assets_begin"],
            )
            C._scene_tail(m, symbols, 0, 2, out, "spectrum.png", bool(broken))
        finally:
            m.close()
    elif system == "bbc":
        data, symbols = C.compile_bbc(args, out, source)
        base = 0
        C.require(0x4000 + len(data) <= 0x5800, "BBC caller overlaps screen")
        m = bbc_load(args, out, data, bool(broken))
        try:
            for _ in range(120):
                if R.read(m, symbols["ready"], 1) == b"\xca":
                    break
                m.call("run_frames", frames=20)
            C.require(
                R.read(m, symbols["ready"], 1) == b"\xca",
                "BBC phase loader did not finish",
            )
            picture = R.read(m, 0x5800, 10240)
            assets = R.read(
                m,
                symbols["sprite_assets_begin"],
                symbols["sprite_assets_end"] - symbols["sprite_assets_begin"],
            )
            C._scene_tail(m, symbols, 0, 1, out, "bbc.png", bool(broken))
        finally:
            m.close()
    else:
        m, symbols, base = C.amiga_machine(args, out, source)
        try:
            picture = R.read(m, base + symbols["plane"], 10240)
            assets = R.read(
                m,
                base + symbols["sprite_assets_begin"],
                symbols["sprite_assets_end"] - symbols["sprite_assets_begin"],
            )
            C.require(
                R.read(m, base + symbols["before_plane"], 16) == b"\xa7" * 16
                and R.read(m, base + symbols["after_plane"], 16) == b"\xa7" * 16,
                "Amiga phase guards changed",
            )
            C._scene_tail(m, symbols, base, 2, out, "amiga.png", bool(broken))
        finally:
            m.close()
    (out / "observations.json").write_text(
        json.dumps({"picture": list(picture), "assets": list(assets)}) + "\n"
    )
    C.require(picture == expected(system), system + " phase bitmap mismatch")
    C.require(
        assets == asset_bytes(system, symbols, base), system + " phase source mismatch"
    )


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
    host = R.module("host", HOST / "verification/verify.py").verify()
    counts = {}
    controls = {}
    for system in SYSTEMS:
        print("Checking " + system, flush=True)
        R.run(
            [
                "python3",
                str(HOST / "prepare.py"),
                str(HOST / "sprite.json"),
                "--system",
                system,
                "--output",
                str(folder(system) / "phases.inc"),
                "--check",
            ],
            ROOT,
        )
        observe(args, out / system, system)
        n = 16 if system == "amiga" else 8
        counts[system] = {
            "phases": n,
            "draws": len(positions(system)),
            "asset_bytes": 2176 if system == "amiga" else 784,
        }
        for broken in ["phase", "stride", "floor"]:
            try:
                observe(args, out / ("broken-" + system + "-" + broken), system, broken)
            except ValueError as error:
                C.require(
                    str(error) == system + " phase bitmap mismatch",
                    "Control failed before bitmap oracle: " + str(error),
                )
                controls[system + "-" + broken] = str(error)
            else:
                raise ValueError(
                    "Broken " + system + " " + broken + " escaped bitmap oracle"
                )
    files = []
    for system in SYSTEMS:
        files.extend(
            p
            for p in folder(system).iterdir()
            if p.suffix in [".asm", ".inc", ".py"] or p.name == "Makefile"
        )
    files.extend(
        [HOST / "prepare.py", HOST / "sprite.json", HOST / "verification/verify.py"]
    )
    files.extend(
        ROOT / p
        for p in [
            "scripts/verify-sprite-clipping.py",
            "scripts/verify-sprite-lifecycle.py",
            "scripts/verify-rendering-families.py",
            "scripts/verify-game-loops.py",
            "scripts/verify-z80-library-routines.py",
            "sinclair-zx-spectrum/patterns/assembly/rendering/clipped-sprites/clip.inc",
            "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc",
            "bbc-micro/patterns/assembly/rendering/clipped-sprites/clip.inc",
            "commodore-amiga/patterns/assembly/rendering/clipped-sprites/clip.inc",
            "commodore-amiga/patterns/assembly/rendering/clipped-sprites/draw.inc",
            "commodore-amiga/patterns/assembly/framework/game-loop/frame.inc",
        ]
    )
    result = {
        "status": "passed",
        "cases": counts,
        "host": host,
        "rejected_controls": controls,
        "sources": {str(p.relative_to(ROOT)): R.sha(p) for p in sorted(files)},
        "observer_sha256": R.sha(Path(__file__)),
        "tools": {
            n: R.sha(Path(getattr(args, n)))
            for n in ["assembler", "build198x", "spectrum", "bbc", "amiga"]
        },
        "firmware": {
            n: R.sha(getattr(args, n)) for n in ["rom", "mos", "basic", "kickstart"]
        },
        "captures": {s + ".png": R.sha(out / s / (s + ".png")) for s in SYSTEMS},
        "limits": __doc__,
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("All phase, pixel, preservation and failure controls passed", flush=True)


if __name__ == "__main__":
    main()
