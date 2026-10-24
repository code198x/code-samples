"""Qualify bounded slot ownership on independent C64 and NES startup paths."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import subprocess
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


R = module("random_transport", ROOT / "scripts/verify-seeded-random.py")
T = R.T
D = ROOT / "cross-platform/patterns/framework/object-pool"
O = module("pool_oracle", D / "oracle.py")
SYSTEMS = ("commodore-64", "nintendo-entertainment-system")
VARIANTS = ("demo", "custom", "wrong", "repaired")


def folder(system):
    return ROOT / system / "patterns/assembly/framework/object-pool"


def source_paths(system):
    f = folder(system)
    return (
        [
            f / name
            for name in (
                "demo.asm",
                "custom.asm",
                "wrong.asm",
                "repaired.asm",
                "caller.inc",
                "exercise.inc",
                "Makefile",
            )
        ]
        + [D / name for name in ("6502.inc", "age6502.inc", "oracle.py")]
        + [
            Path(__file__),
            ROOT / "scripts/verify-seeded-random.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-amiga-rectangle-overlap.py",
            ROOT / "scripts/verify-c64-rectangle-overlap.py",
            ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py",
            ROOT
            / "nintendo-entertainment-system/patterns/assembly/input/controller-reading/edges-font.inc",
        ]
    )


def run(args, name):
    system = args.system
    f = folder(system)
    b, v = f / "build", f / "verification"
    c64 = system == SYSTEMS[0]
    program = b / (name + (".prg" if c64 else ".nes"))
    binary = program.read_bytes()
    sym = T.symbols(b / (name + ".sym"))
    if c64:
        snap = b / (name + ".vsf")
        script = b / (name + "-import.json")
        script.write_text(json.dumps([{"action": "save_snapshot", "path": str(snap)}]))
        subprocess.run(
            [
                str(args.emulator),
                "--model",
                "pal",
                "--rom-dir",
                str(args.firmware),
                "--load",
                str(program),
                "--script",
                str(script),
            ],
            check=True,
            capture_output=True,
            timeout=60,
        )
        cmd = [
            str(args.emulator),
            "--mcp",
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware),
        ]
    else:
        cmd = [str(args.emulator), "--mcp", "--region", "ntsc", "--rom", str(program)]
    m = T.Machine(cmd)

    def read(addr, length):
        return [
            x
            for i in range(0, length, 128)
            for x in m.call("memory_read", addr=addr + i, len=min(128, length - i))[
                "bytes"
            ]
        ]

    def advance(frames):
        result = m.call("run_frames", frames=frames)
        T.require(
            result["frames"] == frames and result["stop_reason"] == "ReachedTarget",
            "Incomplete frame execution",
        )

    try:
        if c64:
            m.call("load_snapshot", path=str(snap))
            loaded = read(2049, len(binary) - 2)
            T.require(loaded == list(binary[2:]), "Imported PRG differs before RUN")
            m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
        else:
            loaded = read(32768, 32768)
            T.require(loaded == list(binary[16:32784]), "Native NROM PRG differs")
        advance(60)
        T.require(read(sym["ready"], 1) == [165], "Caller did not complete")
        capacity = 4 if name == "custom" else 8
        packet = read(sym["OUTPUT"], len(O.packet(capacity)))
        preview = read(sym["preview"], 8)
        T.require(
            packet == O.packet(capacity), "Exhaustive ownership/guard packet differs"
        )
        T.require(
            preview == O.preview(capacity, name == "wrong"),
            "Reuse/ageing preview differs",
        )
        advance(3)
        image = v / (name + ".png")
        m.call("save_screenshot", path=str(image))
        offset = sym["pool_init"] - (2049 if c64 else 32768)
        size = sym["pool_code_end"] - sym["pool_init"]
        age_offset = sym["pool_age"] - (2049 if c64 else 32768)
        age_size = sym["pool_age_code_end"] - sym["pool_age"]
        result = {
            "packet": packet,
            "preview": preview,
            "ready": [165],
            "capacity": capacity,
            "server": m.server["serverInfo"],
            "image": image.name,
            "image_sha256": T.sha(image),
            "program_sha256": T.sha(program),
            "program_bytes": len(binary),
            "program_zlib": zlib.compress(binary).hex(),
            "loaded_bytes": loaded,
            "loaded_sha256": hashlib.sha256(bytes(loaded)).hexdigest(),
            "helper_offset": offset,
            "helper_code_bytes": size,
            "helper_bytes": loaded[offset : offset + size],
            "state_bytes": capacity,
            "age_offset": age_offset,
            "age_code_bytes": age_size,
            "age_bytes": loaded[age_offset : age_offset + age_size],
            "age_state_bytes": capacity,
        }
        if c64:
            result["screen"] = read(1024, 1000)
        return result
    except Exception:
        m.call("save_screenshot", path=str(v / (name + "-diagnostic.png")))
        raise
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system", choices=SYSTEMS, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--emulator", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    a = p.parse_args()
    f = folder(a.system)
    v = f / "verification"
    v.mkdir(exist_ok=True)
    subprocess.run(
        ["make"],
        cwd=f,
        env=os.environ | {"ASM198X": str(a.assembler)},
        check=True,
        timeout=60,
    )
    cfg = {
        "model": "PAL stock-ROM PRG"
        if a.system == SYSTEMS[0]
        else "NTSC NROM background, NMI/DMC disabled",
        "assembler_sha256": T.sha(a.assembler),
        "emulator_sha256": T.sha(a.emulator),
        "firmware_sha256": {
            n: T.sha(a.firmware / n) for n in ("basic.rom", "kernal.rom", "chargen.rom")
        }
        if a.system == SYSTEMS[0]
        else {},
    }
    (v / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    record = {
        "system": a.system,
        "language": "assembly",
        "configuration": cfg,
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in source_paths(a.system)},
        "cases": {},
    }
    for name in VARIANTS:
        record["cases"][name] = run(a, name)
        (v / "results.json").write_text(json.dumps(record, indent=2) + "\n")
        print(a.system, name, "passed", flush=True)


if __name__ == "__main__":
    main()
