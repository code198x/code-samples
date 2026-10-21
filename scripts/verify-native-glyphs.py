"""Execute four native character components; retain full memory and native frames."""

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
S = ROOT / "cross-platform/patterns/rendering/native-glyphs"


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ValueError(path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


T = load("native_transport", ROOT / "scripts/verify-game-loops.py")
PNG = load("native_png", ROOT / "scripts/verify-tilemaps.py")
B = load("native_builder", S / "build.py")
M = load("native_oracle", S / "model.py")
require = T.require


def configs() -> list[dict[str, Any]]:
    return json.loads((S / "systems.json").read_text())


def paths(c: dict[str, Any]) -> list[Path]:
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/custom-glyphs"
    return (
        [S / n for n in ["systems.json", "toolchain.json", "build.py", "model.py"]]
        + [folder / "demo.asm", folder / "glyphs.inc"]
        + ([S / "mode4.inc"] if c["cpu"] == "z80" else [])
        + [
            ROOT / "scripts" / n
            for n in [
                "verify-native-glyphs.py",
                "check-native-glyphs.py",
                "verify-game-loops.py",
                "verify-tilemaps.py",
            ]
        ]
    )


def read(machine: Any, address: int, size: int) -> bytes:
    return bytes(
        value
        for offset in range(0, size, 128)
        for value in machine.call(
            "memory_read", addr=address + offset, len=min(128, size - offset)
        )["bytes"]
    )


def write(machine: Any, address: int, data: bytes) -> None:
    for index, value in enumerate(data):
        machine.call("poke_byte", addr=address + index, value=value)


def command(machine: Any, c: dict[str, Any], value: int) -> None:
    machine.call("poke_byte", addr=c["command"], value=value)
    for _ in range(64):
        machine.call("run_frames", frames=1)
        if read(machine, c["command"], 1) == b"\0":
            return
    raise AssertionError(f"{c['machine_id']} command {value} did not finish")


def snapshot(machine: Any, c: dict[str, Any]) -> bytes:
    if c["machine_id"] == "c64":
        command(machine, c, 5)
        return (
            read(machine, 0x2000, 2048)
            + read(machine, 0x400, 1024)
            + read(machine, c["buffer"], 1024)
            + read(machine, 0x1FF0, 16)
            + read(machine, 0x2800, 16)
        )
    output = bytearray()
    for address in range(0, 16384, 256):
        # Buffered reads cannot recover $3EFF through the next $3F00 read:
        # palette reads bypass the buffer. Read that page through its physical
        # $2E00 nametable alias; other mirror pages are observed directly.
        read_address = (
            0x2E00 if c["machine_id"] == "nes" and address == 0x3E00 else address
        )
        write(machine, c["command"] + 4, read_address.to_bytes(2, "little"))
        command(machine, c, 5)
        output.extend(read(machine, c["buffer"], 256))
    require(len(output) == 16384, "Incomplete video-memory snapshot")
    return bytes(output)


def arguments(c: dict[str, Any], call: dict[str, Any], bulk: int) -> bytes:
    source = bulk if call["kind"] == "bulk" else c["source"]
    word = lambda n: n.to_bytes(2, "little")
    if c["cpu"] == "z80":
        return (
            word(source)
            + word(call["first"])
            + word(call["count"])
            + word(call["code"])
            + word(call["cell"])
            + bytes([call["attrs"]])
        )
    return (
        word(source)
        + bytes([call["first"], call["count"], call["code"]])
        + word(call["cell"])
    )


def captures(c: dict[str, Any]) -> set[int]:
    calls = M.cases(c)
    return {
        i
        for i, x in enumerate(calls)
        if i in [0, 1, 5, 6, len(calls) - 1]
        or x["kind"] in ["bulk", "init"]
        or (c["cpu"] == "z80" and x["kind"] == "select" and x["code"] == 447)
    }


def execute(
    c: dict[str, Any], native: Path, assembler: str, variant: str
) -> dict[str, Any]:
    _, image = B.build(c["machine_id"], assembler, variant)
    symbols = T.symbols(image.parent / "selected.sym")
    bulk = symbols["bulk_patterns"]
    out = image.parent / "verification"
    out.mkdir(exist_ok=True)
    cmd = [str(native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    if c["machine_id"] == "c64":
        cmd += [
            "--basic",
            str(image.parent / "basic.rom"),
            "--chargen",
            str(image.parent / "chargen.rom"),
        ]
    if c["machine_id"] == "nes":
        cmd += ["--region", "ntsc"]
    machine = T.Machine(cmd)
    try:
        machine.call("run_frames", frames=120)
        require(
            read(machine, c["command"], 2) == bytes([0, 239]),
            f"{c['machine_id']}: caller not ready",
        )
        source = M.source(c)
        bulk_data = M.bulk(c)
        write(machine, c["source"], source)
        context_size = 32 if c["cpu"] == "z80" else 24
        guards = [
            (c["context"] - 8, bytes([165]) * 8),
            (c["context"] + context_size, bytes([90]) * 8),
            (c["source"] - 8, bytes([166]) * 8),
            (c["source"] + len(source), bytes([91]) * 8),
        ]
        for addr, data in guards:
            write(machine, addr, data)
        require(
            read(machine, bulk, len(bulk_data)) == bulk_data,
            "Original ROM data differs",
        )
        expected = M.initial(c)
        initial = snapshot(machine, c)
        (out / f"{variant}-initial.dat.z").write_bytes(zlib.compress(initial))
        require(
            variant != "positive" or initial == expected,
            f"{c['machine_id']}: initial memory differs",
        )
        records = []
        memory_faults = pixel_faults = 0
        for index, call in enumerate(M.cases(c)):
            args = arguments(c, call, bulk)
            write(machine, c["context"], args)
            command(
                machine,
                c,
                {"init": 1, "install": 2, "bulk": 2, "replace": 3, "select": 4}[
                    call["kind"]
                ],
            )
            context = read(machine, c["context"], context_size)
            accepted, writes = M.apply(c, expected, call)
            status_offset = 11 if c["cpu"] == "z80" else 7
            cost_offset = status_offset + 1
            require(context[: len(args)] == args, f"{index}: public inputs changed")
            require(
                context[status_offset] == int(accepted), f"{index}: acceptance differs"
            )
            require(
                int.from_bytes(context[cost_offset : cost_offset + 2], "little")
                == writes,
                f"{index}: data-write cost differs",
            )
            if c["cpu"] == "z80":
                require(context[14:16] == bytes([190, 191]), f"{index}: ports changed")
            actual_guards = [read(machine, addr, len(data)) for addr, data in guards]
            require(
                actual_guards == [data for _, data in guards],
                f"{index}: CPU/source guards changed",
            )
            actual_source = read(machine, c["source"], len(source))
            actual_bulk = read(machine, bulk, len(bulk_data))
            require(
                actual_source == source and actual_bulk == bulk_data,
                f"{index}: input assets changed",
            )
            observed = snapshot(machine, c)
            mismatch = observed != expected
            if variant == "positive" and mismatch:
                bad = next(
                    i for i, (a, b) in enumerate(zip(observed, expected)) if a != b
                )
                raise AssertionError(
                    f"{c['machine_id']} {index} {call}: memory offset {bad:x}: {observed[bad]:02x} != {expected[bad]:02x}"
                )
            memory_faults += int(mismatch)
            name = f"{variant}-{index}.dat.z"
            (out / name).write_bytes(zlib.compress(observed))
            record = {
                "call": call,
                "context": context.hex(),
                "source_ram": actual_source.hex(),
                "source_rom_sha256": hashlib.sha256(actual_bulk).hexdigest(),
                "cpu_guards": [g.hex() for g in actual_guards],
                "memory": name,
                "mismatch": mismatch,
            }
            if index in captures(c):
                machine.call("run_frames", frames=2)
                png = out / f"{variant}-{index}.png"
                machine.call("save_screenshot", path=str(png))
                differ = PNG.raster(png) != M.rgba(c, expected)
                if variant == "positive" and differ:
                    actual = PNG.raster(png)
                    wanted = M.rgba(c, expected)
                    raise AssertionError(
                        f"{c['machine_id']} {index}: native pixels differ; dimensions {actual[0]} expected {wanted[0]}"
                    )
                pixel_faults += int(differ)
                record["capture"] = png.name
            records.append(record)
        require(
            variant == "positive" or (memory_faults > 0 and pixel_faults > 0),
            "Completed faulty code escaped memory/native-image comparisons",
        )
        return {
            "fixture_sha256": T.sha(image),
            "emulator_sha256": T.sha(native / c["binary"]),
            "assembler_sha256": T.sha(Path(assembler)),
            "bulk_address": bulk,
            "kernel_bytes": symbols["kernel_end"] - symbols["kernel_start"],
            "cases": records,
            "memory_faults": memory_faults,
            "pixel_faults": pixel_faults,
        }
    finally:
        machine.close()


def verify(c: dict[str, Any], native: Path, assembler: str) -> None:
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    require(
        T.sha(native / c["binary"]) == tools[c["binary"]]["binary_sha256"],
        "Unqualified emulator",
    )
    require(
        T.sha(Path(assembler)) == tools["asm198x"]["binary_sha256"],
        "Unqualified assembler",
    )
    binding = {str(p.relative_to(ROOT)): T.sha(p) for p in paths(c)}
    results = {v: execute(c, native, assembler, v) for v in M.VARIANTS}
    require(
        all(T.sha(ROOT / name) == digest for name, digest in binding.items()),
        "Sources changed during verification",
    )
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/custom-glyphs/build/verification"
    )
    record = {
        "machine_id": c["machine_id"],
        "variants": results,
        "sources": binding,
        "artifacts": {
            p.name: T.sha(p) for p in out.iterdir() if p.suffix in [".z", ".png"]
        },
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print(
        c["machine_id"],
        "PASS",
        len(M.cases(c)),
        "calls; two completed faults caught in memory and native frames",
        flush=True,
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    a = p.parse_args()
    selected = [c for c in configs() if a.system is None or c["machine_id"] == a.system]
    require(bool(selected), "No matching system; nothing executed")
    for c in selected:
        verify(c, a.native.resolve(), str(Path(a.assembler).resolve()))
