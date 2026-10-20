"""Execute six original reset callers and qualify their actual VRAM and native frames."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import zlib
from pathlib import Path
from types import ModuleType
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/tms-glyphs"


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ValueError(path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


T = load("tms_transport", ROOT / "scripts/verify-game-loops.py")
PNG = load("tms_png", ROOT / "scripts/verify-tilemaps.py")
B = load("tms_builder", S / "build.py")
M = load("tms_oracle", S / "model.py")
require = T.require


def configs() -> list[dict[str, Any]]:
    return json.loads((S / "systems.json").read_text())


def paths(c: dict[str, Any]) -> list[Path]:
    return (
        [S / n for n in ["systems.json", "toolchain.json", "build.py", "model.py"]]
        + [
            ROOT / c["folder"] / "patterns/assembly/rendering/custom-glyphs/demo.asm",
            B.KERNEL,
        ]
        + [
            ROOT / "scripts" / n
            for n in [
                "verify-tms-glyphs.py",
                "check-tms-glyphs.py",
                "verify-game-loops.py",
                "verify-tilemaps.py",
            ]
        ]
    )


def read(machine: Any, address: int, size: int) -> bytes:
    return bytes(
        v
        for offset in range(0, size, 128)
        for v in machine.call(
            "memory_read", addr=address + offset, len=min(128, size - offset)
        )["bytes"]
    )


def write(machine: Any, address: int, data: bytes) -> None:
    for i, value in enumerate(data):
        machine.call("poke_byte", addr=address + i, value=value)


def command(machine: Any, c: dict[str, Any], value: int) -> None:
    machine.call("poke_byte", addr=c["command"], value=value)
    for _ in range(12):
        machine.call("run_frames", frames=1)
        if read(machine, c["command"], 1) == b"\0":
            return
    raise AssertionError(f"{c['machine_id']}: command {value} did not finish")


def snapshot(machine: Any, c: dict[str, Any]) -> bytes:
    data = bytearray()
    # A 256-byte CPU buffer fits even the 1 KiB Coleco/SG RAM allocations.
    for address in range(0, 16384, 256):
        write(machine, c["dump_address"], address.to_bytes(2, "little"))
        command(machine, c, 5)
        data.extend(read(machine, c["buffer"], 256))
    require(len(data) == 16384, "Incomplete VRAM snapshot")
    return bytes(data)


def arguments(call: dict[str, Any], source: int, bulk: int) -> bytes:
    return (
        (bulk if call["kind"] == "bulk" else source).to_bytes(2, "little")
        + bytes([call["first"], call["count"], call["code"]])
        + call["cell"].to_bytes(2, "little")
    )


def execute(
    c: dict[str, Any], native: Path, assembler: str, variant: str
) -> dict[str, Any]:
    _, image = B.build(c["machine_id"], assembler, variant)
    symbols = T.symbols(image.parent / "selected.sym")
    bulk = symbols["bulk_glyphs"]
    source = c["ram"] + 640
    out = image.parent / "verification"
    out.mkdir(exist_ok=True)
    machine = T.Machine(
        [str(native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    try:
        machine.call("run_frames", frames=120)
        require(
            read(machine, c["command"], 2) == bytes([0, 239]),
            f"{c['machine_id']}: caller not ready",
        )
        write(machine, source, M.SOURCE)
        guards = [
            (c["context"] - 8, bytes([165]) * 8),
            (c["context"] + 24, bytes([90]) * 8),
        ]
        for addr, data in guards:
            write(machine, addr, data)
        require(read(machine, bulk, 2040) == M.BULK, "Original ROM bulk source differs")
        memory = M.initial()
        initial = snapshot(machine, c)
        (out / f"{variant}-initial.dat.z").write_bytes(zlib.compress(initial))
        if variant == "positive":
            require(initial == memory, "Initial glyph/name/guard setup differs")
        records = []
        mismatches = 0
        pixel_faults = 0
        for index, call in enumerate(M.cases()):
            args = arguments(call, source, bulk)
            write(machine, c["context"], args)
            command(
                machine,
                c,
                {"init": 1, "install": 2, "bulk": 2, "replace": 3, "select": 4}[
                    call["kind"]
                ],
            )
            context = read(machine, c["context"], 24)
            accepted, writes = M.apply(memory, call)
            require(context[:7] == args, f"{index}: changed public input")
            require(context[7] == int(accepted), f"{index}: acceptance differs")
            require(
                int.from_bytes(context[8:10], "little") == writes,
                f"{index}: write count differs",
            )
            require(
                context[10:12] == bytes([c["data_port"], c["control_port"]]),
                f"{index}: changed port contract",
            )
            observed_guards = [read(machine, addr, len(data)) for addr, data in guards]
            require(
                observed_guards == [data for _, data in guards],
                f"{index}: CPU guard changed",
            )
            source_ram = read(machine, source, 24)
            source_rom = read(machine, bulk, 2040)
            require(source_ram == M.SOURCE, f"{index}: source RAM changed")
            require(source_rom == M.BULK, f"{index}: source ROM differs")
            observed = snapshot(machine, c)
            mismatch = observed != memory
            if variant == "positive" and mismatch:
                bad = next(
                    i for i, (a, b) in enumerate(zip(observed, memory)) if a != b
                )
                raise AssertionError(
                    f"{c['machine_id']} {index}: VRAM ${bad:04x} differs"
                )
            mismatches += int(mismatch)
            name = f"{variant}-{index}.dat.z"
            (out / name).write_bytes(zlib.compress(observed))
            record = {
                "call": call,
                "context": context.hex(),
                "source_ram": source_ram.hex(),
                "source_rom_sha256": hashlib.sha256(source_rom).hexdigest(),
                "cpu_guards": [data.hex() for data in observed_guards],
                "memory": name,
                "mismatch": mismatch,
            }
            if index in [0, 1, 5, 16, 19, 23]:
                machine.call("run_frames", frames=2)
                png = out / f"{variant}-{index}.png"
                machine.call("save_screenshot", path=str(png))
                pixels_differ = PNG.raster(png) != M.pixels(c, memory)
                require(
                    variant != "positive" or not pixels_differ,
                    f"{c['machine_id']} {index}: native pixels differ",
                )
                pixel_faults += int(pixels_differ)
                record["capture"] = png.name
            records.append(record)
        require(
            variant == "positive" or (mismatches > 0 and pixel_faults > 0),
            "Completed faulty code escaped memory/pixel oracle",
        )
        return {
            "fixture_sha256": T.sha(image),
            "emulator_sha256": T.sha(native / c["binary"]),
            "assembler_sha256": T.sha(Path(assembler)),
            "source_address": source,
            "bulk_address": bulk,
            "kernel_bytes": symbols["kernel_end"] - symbols["kernel_start"],
            "cases": records,
            "memory_faults": mismatches,
            "pixel_faults": pixel_faults,
        }
    finally:
        machine.close()


def verify(c: dict[str, Any], native: Path, assembler: str) -> None:
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    for tool, path in [
        (c["binary"], native / c["binary"]),
        ("asm198x", Path(assembler)),
    ]:
        require(
            T.sha(path) == tools[tool]["binary_sha256"], "Unqualified tool: " + tool
        )
    bindings = {str(p.relative_to(ROOT)): T.sha(p) for p in paths(c)}
    results = {v: execute(c, native, assembler, v) for v in M.VARIANTS}
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/custom-glyphs/build/verification"
    )
    require(
        all(T.sha(ROOT / name) == digest for name, digest in bindings.items()),
        "Source changed during execution",
    )
    result = {
        "machine_id": c["machine_id"],
        "variants": results,
        "sources": bindings,
        "artifacts": {
            p.name: T.sha(p) for p in out.iterdir() if p.suffix in [".z", ".png"]
        },
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(
        c["machine_id"],
        "PASS",
        len(M.cases()),
        "calls, full 16 KiB snapshots; two completed faults caught",
        flush=True,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument("--assembler", required=True)
    parser.add_argument("--system")
    args = parser.parse_args()
    selected = [
        c for c in configs() if args.system is None or c["machine_id"] == args.system
    ]
    require(bool(selected), "No matching system; nothing executed")
    for cfg in selected:
        verify(cfg, args.native.resolve(), str(Path(args.assembler).resolve()))
