"""Execute six grid callers against logical tiles, complete names and native frames."""

from __future__ import annotations

import argparse
import concurrent.futures
import importlib.util
import json
import zlib
from pathlib import Path
from types import ModuleType
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/character-quads"


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ValueError(path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


V = load("quad_transport", ROOT / "scripts/verify-tms-glyphs.py")
B = load("quad_build", S / "build.py")
M = load("quad_model", S / "model.py")
require = V.require


def configs() -> list[dict[str, Any]]:
    return json.loads((S / "systems.json").read_text())


def paths(c: dict[str, Any]) -> list[Path]:
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/character-quads"
    return (
        [
            S / n
            for n in [
                "systems.json",
                "toolchain.json",
                "build.py",
                "model.py",
                "prepare.py",
                "z80.inc",
                "mistakes/stride.inc",
                "f.bin",
                "arrow.bin",
            ]
        ]
        + [
            folder / n
            for n in [
                "demo.asm",
                "customise.asm",
                "caller.inc",
                "prepare.inc",
                "assets.inc",
            ]
        ]
        + [ROOT / "msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc"]
        + [
            ROOT / "scripts" / n
            for n in [
                "verify-character-quads.py",
                "check-character-quads.py",
                "verify-tms-glyphs.py",
                "verify-game-loops.py",
                "verify-tilemaps.py",
            ]
        ]
        + [
            ROOT / "cross-platform/patterns/rendering/tms-glyphs" / n
            for n in ["build.py", "model.py"]
        ]
    )


def cases(variant: str) -> list[tuple[int, int]]:
    return (
        M.cases()
        if variant == "positive"
        else [(8, 330), (8, 734), (252, 0), (253, 0), (8, 31), (8, 736), (7, 66)]
    )


def names(machine: Any, c: dict[str, Any]) -> bytes:
    result = bytearray()
    for address in range(0x1800, 0x1B00, 256):
        V.write(machine, c["dump_address"], address.to_bytes(2, "little"))
        V.command(machine, c, 5)
        result.extend(V.read(machine, c["buffer"], 256))
    return bytes(result)


def inspect(
    c: dict[str, Any], variant: str, records: dict[str, Any], out: Path
) -> None:
    """Shared fresh/retained oracle; no recorded pass flag is trusted."""
    expected = M.initial(variant)
    startup = records["startup"]
    actual = bytes.fromhex(startup["vram"])
    require(len(actual) == 16384, "Incomplete startup VRAM")
    good = variant != "stride-fault"
    require((actual == expected) == good, "Startup VRAM disagrees with the control")
    require(
        (V.PNG.raster(out / startup["capture"]) == V.M.pixels(c, expected)) == good,
        "Startup native pixels disagree",
    )
    custom = variant == "customise"
    first = 16 if custom else 8
    source = M.CUSTOM if custom else M.NORMAL
    require(
        bytes.fromhex(records["asset"]) == M.tiles(source),
        "Prepared asset differs from independent pixels",
    )
    memory_faults = pixel_faults = 0
    require(len(records["cases"]) == len(cases(variant)), "Missing completed call")
    for index, (record, (slot, cell)) in enumerate(
        zip(records["cases"], cases(variant), strict=True)
    ):
        require(record["input"] == [slot, cell], "Calls changed/reordered")
        if slot != first and slot <= 252:
            expected[slot * 8 : slot * 8 + 32] = M.tiles(source)
        first = slot
        accepted = M.apply(expected, slot, cell)
        q = bytes.fromhex(record["context"])
        require(
            len(q) == 8 and q[:3] == bytes([slot]) + cell.to_bytes(2, "little"),
            "Public input changed",
        )
        require(
            q[3:5] == bytes([int(accepted), 4 if accepted else 0]),
            "Status/data count differs",
        )
        require(record["guards"] == ["a5" * 8, "5a" * 8], "CPU guard changed")
        require(
            record["g_before"] == record["g_after"]
            and len(bytes.fromhex(record["g_after"])) == 24,
            "Upload context changed",
        )
        observed = bytes.fromhex(record["names"])
        require(len(observed) == 768, "Incomplete name-table observation")
        different = observed != expected[0x1800:0x1B00]
        if good:
            require(not different, "Name table differs from geometry oracle")
        memory_faults += int(different)
        if "vram" in record:
            actual = bytes.fromhex(record["vram"])
            require(len(actual) == 16384, "Incomplete VRAM observation")
            if good:
                require(actual == expected, "Complete VRAM differs")
        if "capture" in record:
            different = V.PNG.raster(out / record["capture"]) != V.M.pixels(c, expected)
            if good:
                require(not different, "Native pixels differ")
            pixel_faults += int(different)
    require(
        good or (memory_faults > 0 and pixel_faults > 0),
        "Completed fault escaped independent checks",
    )


def execute(
    c: dict[str, Any], native: Path, assembler: str, variant: str
) -> dict[str, Any]:
    _, image = B.build(c["machine_id"], assembler, variant)
    syms = V.T.symbols(image.parent / "selected.sym")
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/character-quads/build/verification"
    )
    out.mkdir(parents=True, exist_ok=True)
    machine = V.T.Machine(
        [str(native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    q = c["context"] + 32
    try:
        machine.call("run_frames", frames=120)
        require(
            V.read(machine, c["command"], 2) == bytes([0, 239]),
            "Caller did not finish startup",
        )
        png = out / (variant + "-startup.png")
        machine.call("save_screenshot", path=str(png))
        startup = {"vram": V.snapshot(machine, c).hex(), "capture": png.name}
        guards = [(q - 8, bytes([165]) * 8), (q + 16, bytes([90]) * 8)]
        for at, data in guards:
            V.write(machine, at, data)
        asset = syms["large_arrow" if variant == "customise" else "large_f"]
        first = 16 if variant == "customise" else 8
        result = []
        for index, (slot, cell) in enumerate(cases(variant)):
            if slot != first and slot <= 252:
                V.write(
                    machine,
                    c["context"],
                    asset.to_bytes(2, "little") + bytes([slot, 4]),
                )
                V.command(machine, c, 2)
            first = slot
            V.write(machine, q, bytes([slot]) + cell.to_bytes(2, "little"))
            before = V.read(machine, c["context"], 24)
            V.command(machine, c, 6)
            r = {
                "input": [slot, cell],
                "context": V.read(machine, q, 8).hex(),
                "g_before": before.hex(),
                "g_after": V.read(machine, c["context"], 24).hex(),
                "guards": [V.read(machine, at, 8).hex() for at, _ in guards],
                "names": names(machine, c).hex(),
            }
            if index in [0, 734, len(cases(variant)) - 1]:
                r["vram"] = V.snapshot(machine, c).hex()
                machine.call("run_frames", frames=2)
                png = out / f"{variant}-{index}.png"
                machine.call("save_screenshot", path=str(png))
                r["capture"] = png.name
            result.append(r)
        record = {
            "startup": startup,
            "cases": result,
            "asset": V.read(machine, asset, 32).hex(),
        }
        inspect(c, variant, record, out)
        path = out / (variant + ".json.z")
        path.write_bytes(zlib.compress(json.dumps(record).encode()))
        return {
            "observations": path.name,
            "fixture_sha256": V.T.sha(image),
            "emulator_sha256": V.T.sha(native / c["binary"]),
            "assembler_sha256": V.T.sha(Path(assembler)),
            "quad_bytes": syms["quad_end"] - syms["quad_start"],
            "glyph_bytes": syms["kernel_end"] - syms["kernel_start"],
        }
    finally:
        machine.close()


def verify(c: dict[str, Any], native: Path, assembler: str) -> None:
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    for name, path in [
        (c["binary"], native / c["binary"]),
        ("asm198x", Path(assembler)),
    ]:
        require(
            V.T.sha(path) == tools[name]["binary_sha256"], "Unqualified tool " + name
        )
    bindings = {str(p.relative_to(ROOT)): V.T.sha(p) for p in paths(c)}
    variants = {v: execute(c, native, assembler, v) for v in M.VARIANTS}
    require(
        variants["positive"]["fixture_sha256"]
        == variants["stride-fixed"]["fixture_sha256"],
        "Repair did not restore original executable",
    )
    require(
        all(V.T.sha(ROOT / n) == d for n, d in bindings.items()),
        "Source changed during run",
    )
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/character-quads/build/verification"
    )
    record = {
        "machine_id": c["machine_id"],
        "sources": bindings,
        "variants": variants,
        "artifacts": {
            p.name: V.T.sha(p) for p in out.iterdir() if p.suffix in [".z", ".png"]
        },
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print(
        c["machine_id"],
        "PASS",
        sum(len(cases(v)) + 1 for v in M.VARIANTS),
        "native completed observations",
        flush=True,
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    args = p.parse_args()
    selected = [
        c for c in configs() if args.system is None or c["machine_id"] == args.system
    ]
    require(bool(selected), "No matching system; nothing executed")
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        list(
            pool.map(
                lambda c: verify(
                    c, args.native.resolve(), str(Path(args.assembler).resolve())
                ),
                selected,
            )
        )
