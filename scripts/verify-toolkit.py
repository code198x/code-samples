"""Execute reusable gameplay callers through independently checked native startup paths."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, path):
    s = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


T = module("transport", ROOT / "scripts/verify-game-loops.py")
H = module("hunk", ROOT / "scripts/verify-amiga-rectangle-overlap.py")
TOPIC = "fractional-position"
TOPICS = tuple(json.loads((ROOT / "scripts/toolkit-topics.json").read_text()))
SYSTEMS = (
    "commodore-64",
    "nintendo-entertainment-system",
    "sinclair-zx-spectrum",
    "commodore-amiga",
)
VARIANTS = ("demo", "custom", "wrong", "repaired")


def oracle():
    return module(
        "case_oracle",
        ROOT
        / "cross-platform/patterns"
        / json.loads((ROOT / "scripts/toolkit-topics.json").read_text())[TOPIC][
            "category"
        ]
        / TOPIC
        / "oracle.py",
    )


def expected_packet(name):
    return oracle().packet(name == "custom", name == "wrong")


def expected_preview(name):
    return oracle().preview(name == "custom", name == "wrong")


def folder(system):
    return (
        ROOT
        / system
        / "patterns/assembly"
        / json.loads((ROOT / "scripts/toolkit-topics.json").read_text())[TOPIC][
            "category"
        ]
        / TOPIC
    )


def source_paths(system):
    f = folder(system)
    paths = [
        f / n
        for n in (
            "demo.asm",
            "custom.asm",
            "wrong.asm",
            "repaired.asm",
            "caller.inc",
            "component.inc",
            "exercise.inc",
            "cases.inc",
            "Makefile",
            "data.inc",
        )
    ]
    if system in SYSTEMS[:2]:
        paths += [
            ROOT
            / "cross-platform/patterns"
            / json.loads((ROOT / "scripts/toolkit-topics.json").read_text())[TOPIC][
                "category"
            ]
            / TOPIC
            / "6502.inc"
        ]
    paths += [
        ROOT
        / "cross-platform/patterns"
        / json.loads((ROOT / "scripts/toolkit-topics.json").read_text())[TOPIC][
            "category"
        ]
        / TOPIC
        / "oracle.py",
        ROOT / "cross-platform/patterns/framework/toolkit-models/cases.py",
        ROOT / "scripts/toolkit-topics.json",
        Path(__file__),
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/verify-amiga-rectangle-overlap.py",
        ROOT / "scripts/verify-c64-rectangle-overlap.py",
        ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py",
    ]
    if system != "sinclair-zx-spectrum":
        paths += [
            ROOT
            / "nintendo-entertainment-system/patterns/assembly/input/controller-reading/edges-font.inc"
        ]
    if system == "sinclair-zx-spectrum":
        paths += [f / "../../physics/rectangle-overlap/display.inc"]
    if system == "commodore-amiga":
        paths += [f / "../../framework/turn-deadline/font.inc", f / "display.inc"]
    return paths


def font():
    s = (
        ROOT
        / "nintendo-entertainment-system/patterns/assembly/input/controller-reading/edges-font.inc"
    ).read_text()
    full = [
        int(v.strip())
        for line in s.splitlines()
        if ".byte " in line
        for v in line.split(".byte ")[1].split(",")
    ]
    return [v for i in range(17) for v in full[i * 16 : i * 16 + 8]]


def blocks(data):
    out = []
    i = 0
    while i < len(data):
        n = int.from_bytes(data[i : i + 2], "little")
        part = data[i + 2 : i + 2 + n]
        T.require(n >= 2 and len(part) == n, "Truncated tape block")
        checksum = 0
        for v in part:
            checksum ^= v
        T.require(checksum == 0, "Tape checksum differs")
        out.append(part)
        i += 2 + n
    return out


def run(args, system, name):
    f = folder(system)
    b = f / "build"
    v = f / "verification"
    v.mkdir(exist_ok=True)
    ext = {
        "commodore-64": "prg",
        "nintendo-entertainment-system": "nes",
        "sinclair-zx-spectrum": "tap",
        "commodore-amiga": "adf",
    }[system]
    program = b / (name + "." + ext)
    sym = T.symbols(b / (name + ".sym"))
    binary = program.read_bytes()
    c64 = system == "commodore-64"
    nes = system == "nintendo-entertainment-system"
    spec = system == "sinclair-zx-spectrum"
    amiga = system == "commodore-amiga"
    if c64:
        T.require(sym["code_end"] <= 0x2000, "Program overlaps the diagnostic font RAM")
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
        command = [
            str(args.emulator),
            "--mcp",
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware),
        ]
    elif nes:
        command = [
            str(args.emulator),
            "--mcp",
            "--region",
            "ntsc",
            "--rom",
            str(program),
        ]
    elif spec:
        command = [str(args.emulator), "--mcp", "--rom", str(args.firmware)]
    else:
        command = [
            str(args.emulator),
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.firmware),
            "--disk",
            str(program),
        ]
    m = T.Machine(command)

    def read(a, n):
        T.require(0 <= n <= 65536, "Read bound")
        return [
            v
            for i in range(0, n, 128)
            for v in m.call("memory_read", addr=a + i, len=min(128, n - i))["bytes"]
        ]

    def advance(n):
        for i in range(0, n, 100):
            count = min(100, n - i)
            result = m.call("run_frames", frames=count)
            T.require(
                result["frames"] == count and result["stop_reason"] == "ReachedTarget",
                "Incomplete frames",
            )

    base = 0
    try:
        if c64:
            m.call("load_snapshot", path=str(snap))
            payload = binary[2:]
            loaded = read(int.from_bytes(binary[:2], "little"), len(payload))
            T.require(loaded == list(payload), "Imported PRG differs before RUN")
            m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
            advance(20)
        elif nes:
            payload = binary[16:32784]
            loaded = read(0x8000, 32768)
            T.require(loaded == list(payload), "Native PRG differs")
            advance(20)
        elif spec:
            tape = blocks(binary)
            T.require(len(tape) == 4 and tape[2][1] == 3, "Wrong CODE tape")
            payload = tape[3][1:-1]
            m.call("load_media", slot="tape-1", kind="tape", path=str(program))
            m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
            # Reuse the maintained ROM-loading budget: loading is guest execution,
            # not host injection. One debugger span need not finish a tape load.
            startup = []
            startup_limit = 20
            for _ in range(startup_limit):
                stop = m.call("run_until_pc", addr=sym["start"], max_steps=1000000)
                startup.append(stop)
                if stop["reached"]:
                    break
            T.require(
                stop["reached"],
                f"ROM loader did not enter CODE within {startup_limit}M instructions",
            )
            loaded = read(0x8000, len(payload))
            T.require(loaded == list(payload), "ROM-loaded tape differs")
            advance(30)
        else:
            exe = (b / name).read_bytes()
            body, relocs = H.hunk(exe)
            found = []
            for _ in range(25):
                advance(100)
                hits = m.call("memory_scan", start=0, end=0x80000, value=0x31393858)
                T.require(not hits["truncated"], "Truncated signature scan")
                found = [
                    int(h["addr"][1:], 16) - sym["signature"]
                    for h in hits["hits"]
                    if read(int(h["addr"][1:], 16), 16) == list(b"198XTOOLKIT0000\0")
                    and read(
                        int(h["addr"][1:], 16) - sym["signature"] + sym["ready"], 2
                    )
                    == [186, 190]
                ]
                if found:
                    break
            T.require(len(found) == 1, "No unique completed ADF caller")
            base = found[0]
            relocated = bytearray(body)
            for i in relocs:
                relocated[i : i + 4] = (
                    int.from_bytes(body[i : i + 4], "big") + base
                ).to_bytes(4, "big")
            loaded = read(base, sym["code_end"])
            payload = relocated[: sym["code_end"]]
            T.require(loaded == list(payload), "Relocated immutable code differs")
        if not amiga:
            for _ in range(5):
                if read(sym["ready"], 1) == [165]:
                    break
                advance(40)
        ready = read(base + sym["ready"], 2 if amiga else 1)
        T.require(ready == ([186, 190] if amiga else [165]), "Guest did not complete")
        packet = read(base + sym["OUTPUT"], len(expected_packet(name)))
        T.require(
            packet == expected_packet(name),
            "Independent ownership/transition packet differs",
        )
        preview = read(base + sym["preview"], 8)
        expected = expected_preview(name)
        T.require(preview == expected, "Native preview differs")
        # Presentation observes the completed client; it does not update simulation.
        advance(3)
        image = v / (name + ".png")
        m.call("save_screenshot", path=str(image))
        result = {
            "packet": packet,
            "preview": preview,
            "ready": ready,
            "image": image.name,
            "image_sha256": T.sha(image),
            "server": m.server["serverInfo"],
            "loaded_bytes": loaded,
            "loaded_sha256": hashlib.sha256(bytes(loaded)).hexdigest(),
            "program_sha256": T.sha(program),
            "program_bytes": len(binary),
            "helper_code_bytes": sym["component_end"] - sym["component_start"],
            "state_bytes": len(oracle().FIELDS),
            "static_data_bytes": sym["data_end"] - sym["data_start"],
        }
        load_origin = 2049 if c64 else 0 if amiga else 32768
        offset = sym["component_start"] - load_origin
        result["helper_offset"] = offset
        result["helper_bytes"] = loaded[offset : offset + result["helper_code_bytes"]]
        if c64:
            result["program_zlib"] = zlib.compress(binary).hex()
            result["screen"] = read(1024, 1000)
        elif nes:
            result["program_zlib"] = zlib.compress(binary).hex()
        elif spec:
            result["program_zlib"] = zlib.compress(binary).hex()
            result["startup"] = startup
            result["bitmap_zlib"] = zlib.compress(bytes(read(0x4000, 6144))).hex()
            result["attributes"] = read(0x5800, 768)
            chars = int.from_bytes(bytes(read(23606, 2)), "little")
            text = " ".join(f"{n:02X}" for n in preview) + " "
            result["text"] = text
            result["glyphs"] = {
                str(ord(c)): read(chars + ord(c) * 8, 8) for c in set(text)
            }
        else:
            result.update(
                base=base,
                exe_zlib=zlib.compress(exe).hex(),
                program_zlib=zlib.compress(binary).hex(),
                code_end=sym["code_end"],
                plane_zlib=zlib.compress(bytes(read(base + sym["plane"], 10240))).hex(),
            )
        return result
    except Exception:
        m.call("save_screenshot", path=str(v / (name + "-diagnostic.png")))
        raise
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--topic", choices=TOPICS, required=True)
    p.add_argument("--system", choices=SYSTEMS, required=True)
    for n in ("assembler", "emulator", "firmware"):
        p.add_argument("--" + n, type=Path, required=True)
    p.add_argument("--build198x", type=Path)
    p.add_argument("--variants", default=",".join(VARIANTS))
    a = p.parse_args()
    global TOPIC
    TOPIC = a.topic
    f = folder(a.system)
    v = f / "verification"
    v.mkdir(exist_ok=True)
    env = __import__("os").environ | {"ASM198X": str(a.assembler)}
    if a.build198x:
        env["BUILD198X"] = str(a.build198x)
    subprocess.run(["make"], cwd=f, env=env, check=True, timeout=60)
    fw = (
        {}
        if a.system == "nintendo-entertainment-system"
        else (
            {
                n: T.sha(a.firmware / n)
                for n in ("basic.rom", "kernal.rom", "chargen.rom")
            }
            if a.firmware.is_dir()
            else {"firmware": T.sha(a.firmware)}
        )
    )
    cfg = {
        "model": {
            "commodore-64": "PAL stock-ROM PRG",
            "nintendo-entertainment-system": "NTSC NROM, background only, DMC/NMI disabled",
            "sinclair-zx-spectrum": "48K PAL ROM tape load and USR",
            "commodore-amiga": "A500 OCS PAL, Kickstart1.3 OFS cold boot",
        }[a.system],
        "assembler_sha256": T.sha(a.assembler),
        "emulator_sha256": T.sha(a.emulator),
        "firmware_sha256": fw,
    }
    if a.build198x:
        cfg["build198x_sha256"] = T.sha(a.build198x)
    (v / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = v / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": a.system, "topic": TOPIC, "language": "assembly", "cases": {}}
    )
    r.update(
        configuration=cfg,
        sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths(a.system)},
    )
    for name in a.variants.split(","):
        T.require(name in VARIANTS, "Unknown variant")
        r["cases"][name] = run(a, a.system, name)
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(a.system, name, "passed", flush=True)


if __name__ == "__main__":
    main()
