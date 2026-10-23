"""Run a second BASIC caller with synthetic clock samples through stock firmware."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "deadline", ROOT / "scripts/verify-basic-deadlines.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
T = V.T


def run(system: str, args: argparse.Namespace) -> None:
    bbc = system == "bbc-micro"
    family = "acorn-bbc-micro" if bbc else "c64"
    binary = args.tools / f"emu198x-{family}-aarch64-apple-darwin" / f"emu198x-{family}"
    rom = args.firmware / ("acorn-bbc-micro" if bbc else "commodore-c64")
    command = [str(binary), "--mcp"]
    command += (
        ["--mos", str(rom / "os.rom"), "--rom", f"acorn-bbc-basic={rom / 'basic.rom'}"]
        if bbc
        else ["--rom-dir", str(rom), "--model", "pal"]
    )
    folder = ROOT / system / "patterns/basic/framework/turn-deadline"
    monitor = (
        "\n".join(
            l
            for l in (folder / "monitor.bas").read_text().splitlines()
            if int(l.split()[0]) >= 9100
        )
        + "\n"
    )
    source = (
        (folder / "boundaries.bas").read_text()
        + (folder / "routines.bas").read_text()
        + monitor
    )
    machine = T.Machine(command)
    try:
        machine.call("run_frames", frames=150)
        for line in (source + "RUN\n").splitlines():
            result = machine.call(
                "type_string", text=line + "\n", hold_frames=3, settle_frames=8
            )
            T.require(
                result["chars_typed"] == len(line) + 1, "Incomplete boundary caller"
            )
        address = 0x3000 if bbc else 0xC000
        for _ in range(20):
            machine.call("run_frames", frames=50)
            raw = machine.call("memory_read", addr=address, len=102)["bytes"]
            if raw[100:102] == [165, 90]:
                break
        T.require(
            len(raw) == 102 and raw[100:] == [165, 90], "Boundary driver did not finish"
        )
        modulus = 65536 if bbc else 5184000
        cases = []
        for i, line in enumerate(l for l in source.splitlines() if " DATA " in l):
            previous, now, duration = map(int, line.split(" DATA ")[1].split(","))
            elapsed = (now - previous) % modulus
            expired = int(duration > 0 and elapsed >= duration)
            expected = (
                [int(duration > 0 and not expired), expired]
                + list(
                    max(0, duration - elapsed).to_bytes(3, "little")
                    if duration
                    else bytes(3)
                )
                + list(elapsed.to_bytes(3, "little"))
            )
            actual = raw[i * 8 : i * 8 + 8]
            T.require(
                actual == expected, f"{system} boundary {i}: {actual} != {expected}"
            )
            cases.append(
                {
                    "previous": previous,
                    "now": now,
                    "duration": duration,
                    "bytes": actual,
                }
            )
        image = folder / "verification/boundaries.png"
        machine.call("save_screenshot", path=str(image))
        record = {
            "system": system,
            "modulus": modulus,
            "cases": cases,
            "raw": raw,
            "listing_sha256": __import__("hashlib").sha256(source.encode()).hexdigest(),
            "emulator_sha256": T.sha(binary),
            "image_sha256": T.sha(image),
        }
        (folder / "verification/boundaries.json").write_text(
            json.dumps(record, indent=2) + "\n"
        )
        print(system, len(cases), "native BASIC boundary cases passed", flush=True)
    finally:
        machine.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--systems", default="commodore-64,bbc-micro")
    args = p.parse_args()
    for system in args.systems.split(","):
        run(system, args)
