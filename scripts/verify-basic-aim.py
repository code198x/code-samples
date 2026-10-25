"""Execute BASIC platform components through their native interpreters."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TOOLS = None


def module(name, path):
    s = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


T = module("transport", ROOT / "scripts/verify-game-loops.py")
TOPIC = ""
CATEGORIES = {"aimed-projectile": "physics"}
M = None
B = module("layout", ROOT / "scripts/verify-basic-deadlines.py")


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def execute(system, variant):
    f = ROOT / system / f"patterns/basic/{CATEGORIES[TOPIC]}/{TOPIC}"
    out = f / "verification"
    out.mkdir(exist_ok=True)
    bbc = system == "bbc-micro"
    zx = system == "sinclair-zx-spectrum"
    base = 24576 if bbc else 60000 if zx else 49152
    builder = next(TOOLS.rglob("build198x"))
    env = os.environ | {"BUILD198X": str(builder)}
    try:
        subprocess.run(
            ["make"],
            cwd=f,
            env=env,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=60,
        )
    except subprocess.CalledProcessError as error:
        if error.stdout:
            print(error.stdout.decode("utf-8", "replace"), flush=True)
        raise
    exe = next(
        TOOLS.rglob(
            "emu198x-acorn-bbc-micro"
            if bbc
            else "emu198x-spectrum"
            if zx
            else "emu198x-c64"
        )
    )
    rom = Path.home() / ".emu198x/roms"
    command = [str(exe), "--mcp"]
    command += (
        [
            "--mos",
            str(rom / "acorn-bbc-micro/os.rom"),
            "--rom",
            "acorn-bbc-basic=" + str(rom / "acorn-bbc-micro/basic.rom"),
        ]
        if bbc
        else ["--rom", str(rom / "sinclair-zx-spectrum-48k/48.rom")]
        if zx
        else ["--model", "pal", "--rom-dir", str(rom / "commodore-c64")]
    )
    source = f / "build" / (variant + ".bas")
    binary = f / "build" / (variant + (".tap" if zx else ".prg"))
    snapshot = f / "build" / (variant + ".vsf")
    if not zx and not bbc:
        script = f / "build" / (variant + "-load.json")
        script.write_text(
            json.dumps([{"action": "save_snapshot", "path": str(snapshot)}])
        )
        subprocess.run(
            [
                str(exe),
                "--model",
                "pal",
                "--rom-dir",
                str(rom / "commodore-c64"),
                "--load",
                str(binary),
                "--script",
                str(script),
            ],
            check=True,
            capture_output=True,
            timeout=60,
        )
    m = T.Machine(command)

    def read(addr, n):
        return [
            v
            for i in range(0, n, 128)
            for v in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    frames = 0

    def run(n):
        nonlocal frames
        r = m.call("run_frames", frames=n)
        T.require(
            r["frames"] == n and r["stop_reason"] == "ReachedTarget",
            "Incomplete execution",
        )
        frames += n

    try:
        receipt = []
        if zx:
            m.call("load_media", slot="tape-1", kind="tape", path=str(binary))
            m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        elif bbc:
            run(150)
            for line in source.read_text().splitlines():
                r = m.call(
                    "type_string", text=line + "\n", hold_frames=2, settle_frames=3
                )
                T.require(r["chars_typed"] == len(line) + 1, "Incomplete source line")
                receipt.append(len(line) + 1)
            layout = B.memory_layout(m, True)
            T.require(
                [l["number"] for l in layout["lines"]]
                == [int(l.split()[0]) for l in source.read_text().splitlines()],
                "Loaded BBC line identities differ",
            )
            r = m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
            T.require(r["chars_typed"] == 4, "RUN incomplete")
        else:
            m.call("load_snapshot", path=str(snapshot))
            data = binary.read_bytes()
            origin = int.from_bytes(data[:2], "little")
            loaded = read(origin, len(data) - 2)
            T.require(bytes(loaded) == data[2:], "Loaded PRG differs before RUN")
            layout = {"program_start": origin, "program_bytes": loaded}
            r = m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
            T.require(r["chars_typed"] == 4, "RUN incomplete")
        for _ in range(300):
            run(200)
            if read(base + 1000, 1) == [239]:
                break
        T.require(
            read(base + 1000, 2) == [239, 90],
            f"{system}/{variant}: BASIC caller did not finish",
        )
        # Completion records execution; two full frames also complete the display scan.
        run(2)
        expected = M.packet(variant)
        count = read(base + 998, 2)
        T.require(count[0] + 256 * count[1] == len(expected), "Wrong emitted count")
        packet = read(base, len(expected))
        T.require(
            packet == expected,
            f"{system}/{variant}: state mismatch at "
            + str(
                next(
                    (i for i, (a, b) in enumerate(zip(packet, expected)) if a != b),
                    None,
                )
            ),
        )
        T.require(read(base + 997, 1) == [165], "Public sentinel changed")
        T.require(
            read(base + 995, 2) == ([0, 0] if variant == "wrong" else [1, 1]),
            "Saved BASIC behaviour checks differ",
        )
        if zx:
            sysvars = read(23627, 2)
            start = int.from_bytes(bytes(read(23635, 2)), "little")
            end = int.from_bytes(bytes(sysvars), "little")
            program = read(start, end - start)
            tap = binary.read_bytes()
            blocks = []
            i = 0
            while i < len(tap):
                n = int.from_bytes(tap[i : i + 2], "little")
                blocks.append(tap[i + 2 : i + 2 + n])
                i += n + 2
            T.require(
                program == list(blocks[1][1:-1]),
                "ROM-loaded tokenised program differs from TAP",
            )
            layout = {"program_start": start, "program_bytes": program}
        image = out / (variant + ".png")
        m.call("save_screenshot", path=str(image))
        observation = m.call(
            "memory_read", addr=0x7C00 if bbc else 0x4000 if zx else 1024, len=128
        )["bytes"]
        T.require(len(observation) == 128, "Missing native display observation")
        record = {
            "status": "passed",
            "system": system,
            "variant": variant,
            "source_sha256": sha(source),
            "emulator_sha256": sha(exe),
            "builder_sha256": sha(builder),
            "frames_after_start": frames,
            "packet": packet,
            "count": len(expected),
            "guards": [165, 239, 90],
            "image_sha256": sha(image),
            "memory": layout,
            "source_entry_receipts": receipt,
        }
        record["loaded_program_sha256"] = hashlib.sha256(
            bytes(layout["program_bytes"])
        ).hexdigest()
        record["display_prefix"] = observation
        if not bbc:
            font_file = (
                rom / "sinclair-zx-spectrum-48k/48.rom"
                if zx
                else rom / "commodore-c64/chargen.rom"
            )
            font = font_file.read_bytes()
            codes = (
                sorted(set(map(ord, M.LABEL + "01")))
                if zx
                else sorted(set(observation[:80]))
            )
            record["glyphs"] = {
                str(code): list(
                    font[
                        (0x3C00 + code * 8 if zx else code * 8) : (
                            0x3C00 + code * 8 if zx else code * 8
                        )
                        + 8
                    ]
                )
                for code in codes
            }
            if zx:
                import zlib

                record["bitmap_zlib"] = zlib.compress(bytes(read(0x4000, 6144))).hex()

        record["image"] = image.name
        record["sources"] = {
            str(p.relative_to(ROOT)): sha(p)
            for p in [
                *sorted(f.glob("*.bas")),
                f / "build.py",
                f / "Makefile",
                ROOT
                / f"cross-platform/patterns/{CATEGORIES[TOPIC]}/{TOPIC}/basic_oracle.py",
                Path(__file__),
                ROOT / "cross-platform/patterns/framework/basic-aim-models/cases.py",
                ROOT / "scripts/verify-basic-deadlines.py",
                ROOT / "scripts/verify-game-loops.py",
            ]
        }
        firmware = (
            [
                rom / "acorn-bbc-micro/os.rom",
                rom / "acorn-bbc-micro/basic.rom",
                rom / "acorn-bbc-micro/saa5050.rom",
            ]
            if bbc
            else [rom / "sinclair-zx-spectrum-48k/48.rom"]
            if zx
            else [
                rom / "commodore-c64" / name
                for name in ["basic.rom", "kernal.rom", "chargen.rom"]
            ]
        )
        record["firmware_sha256"] = {p.name: sha(p) for p in firmware}
        if binary.exists():
            record["program_sha256"] = sha(binary)
        else:
            record["program_sha256"] = hashlib.sha256(
                bytes(layout["program_bytes"])
            ).hexdigest()
        (out / (variant + ".json")).write_text(json.dumps(record, indent=2) + "\n")
        print(
            system,
            variant,
            "passed",
            len(packet),
            "bytes",
            frames,
            "frames",
            flush=True,
        )
    except Exception:
        m.call("save_screenshot", path=str(out / (variant + "-failure.png")))
        raise
    finally:
        m.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument(
        "topic",
        choices=[
            "aimed-projectile",
        ],
    )
    p.add_argument(
        "system", choices=["commodore-64", "sinclair-zx-spectrum", "bbc-micro"]
    )
    p.add_argument("variants", nargs="*")
    p.add_argument("--tools", type=Path, required=True)
    a = p.parse_args()
    TOOLS = a.tools.resolve()
    TOPIC = a.topic
    M = module(
        "oracle",
        ROOT / f"cross-platform/patterns/{CATEGORIES[TOPIC]}/{TOPIC}/basic_oracle.py",
    )
    for variant in a.variants or ["demo", "custom", "wrong", "repaired"]:
        execute(a.system, variant)
