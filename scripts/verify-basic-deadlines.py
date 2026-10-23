"""Qualify BASIC deadlines through stock firmware, typed source and native clocks."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def memory_layout(machine: T.Machine, bbc: bool) -> dict:
    workspace = machine.call(
        "memory_read", addr=0 if bbc else 0x2B, len=25 if bbc else 10
    )["bytes"]
    word = lambda i: int.from_bytes(bytes(workspace[i : i + 2]), "little")
    start = workspace[24] * 256 if bbc else word(0)
    end = word(18) if bbc else word(2)
    T.require(0 < end - start < 8192, "Implausible native program extent")
    raw = []
    for offset in range(0, end - start, 128):
        size = min(128, end - start - offset)
        part = machine.call("memory_read", addr=start + offset, len=size)["bytes"]
        T.require(len(part) == size, "Truncated tokenised program")
        raw.extend(part)
    lines = []
    cursor = 0
    while cursor < len(raw):
        if bbc:
            if raw[cursor : cursor + 2] == [13, 255]:
                break
            T.require(
                raw[cursor] == 13 and cursor + 4 <= len(raw), "Invalid BBC BASIC line"
            )
            number = raw[cursor + 1] * 256 + raw[cursor + 2]
            length = raw[cursor + 3]
        else:
            next_line = int.from_bytes(bytes(raw[cursor : cursor + 2]), "little")
            if next_line == 0:
                break
            number = int.from_bytes(bytes(raw[cursor + 2 : cursor + 4]), "little")
            length = next_line - start - cursor
        T.require(
            length >= 5 and cursor + length <= len(raw), "Invalid native line extent"
        )
        lines.append({"number": number, "bytes": length})
        cursor += length
    return {
        "workspace_bytes": workspace,
        "program_start": start,
        "program_end": end,
        "program_bytes": raw,
        "lines": lines,
        "helper_token_bytes": sum(
            x["bytes"] for x in lines if 3000 <= x["number"] <= 3250
        ),
        "heap_start": word(0) if bbc else word(2),
        "heap_end": word(2) if bbc else word(4),
    }


def execute_variant(
    system: str, folder: Path, command: list[str], variant: str
) -> dict:
    bbc = system == "bbc-micro"
    out = folder / "verification"
    source = (
        folder
        / "build"
        / (
            "customise.bas"
            if variant == "custom"
            else "wrong.bas"
            if variant == "wrong"
            else "demo.bas"
        )
    )
    machine = T.Machine(command)
    total_frames = 0
    samples = []

    def frames(n: int) -> None:
        nonlocal total_frames
        while n:
            part = min(n, 200)
            machine.call("run_frames", frames=part)
            total_frames += part
            n -= part

    def observe(stage: str) -> dict:
        for _ in range(100):
            raw = machine.call("memory_read", addr=0x3000 if bbc else 0xC000, len=20)[
                "bytes"
            ]
            T.require(len(raw) == 20, "Truncated mailbox")
            if raw[19] == 239 and raw[16:18] == [165, 90]:
                state = {
                    "stage": stage,
                    "frames": total_frames,
                    "raw": raw,
                    "turn": raw[0],
                    "expiries": raw[1],
                    "active": raw[2],
                    "remaining": int.from_bytes(bytes(raw[3:6]), "little"),
                    "clock": int.from_bytes(bytes(raw[6:9]), "little"),
                    "duration": int.from_bytes(bytes(raw[9:12]), "little"),
                    "elapsed": int.from_bytes(bytes(raw[12:15]), "little"),
                }
                samples.append(state)
                print(
                    system,
                    variant,
                    stage,
                    {k: v for k, v in state.items() if k != "raw"},
                    flush=True,
                )
                return state
            frames(1)
        raise AssertionError(f"{system}/{variant}/{stage}: no coherent mailbox: {raw}")

    def key(name: str) -> None:
        machine.call("input", events=[{"Key": {"name": name, "pressed": True}}])
        frames(3)
        machine.call("input", events=[{"Key": {"name": name, "pressed": False}}])
        frames(30)

    try:
        frames(150)
        for line in (source.read_text() + "RUN\n").splitlines():
            result = machine.call(
                "type_string", text=line + "\n", hold_frames=3, settle_frames=8
            )
            T.require(
                result["chars_typed"] == len(line) + 1,
                f"Incomplete source: {result}",
            )
        frames(20)
        first = observe("initial")
        T.require(first["turn"] == 0 and first["active"] == 0, "Must start untimed")
        frames(100)
        idle = observe("untimed-idle")
        T.require(
            idle["turn"] == 0 and idle["clock"] != first["clock"],
            "Idle clock must run without a turn",
        )
        key("space")
        action = observe("untimed-action")
        T.require(
            action["turn"] == 1 and action["active"] == 0,
            "Untimed action must remain untimed",
        )
        key("t")
        enabled = observe("enabled")
        T.require(
            enabled["active"] == 1 and enabled["expiries"] == 0,
            "Toggle must enable deadline",
        )
        frames(30)
        progress = observe("idle-progress")
        T.require(progress["clock"] != enabled["clock"], "Native clock must advance")
        if variant == "wrong":
            frames(300)
            expired = observe("wrong-never-expires")
            T.require(
                expired["turn"] == 1
                and expired["expiries"] == 0
                and expired["remaining"] == expired["duration"]
                and expired["elapsed"] == 0,
                "Baseline mistake must prevent expiration",
            )
        else:
            T.require(
                progress["remaining"] < enabled["remaining"],
                "Deadline must progress without input",
            )
            key("space")
            restarted = observe("action-restarts")
            T.require(
                restarted["turn"] == 2
                and restarted["active"] == 1
                and restarted["remaining"] > progress["remaining"],
                "Action must restart active deadline",
            )
            # Poll in small steps; do not silently skip multiple expiries.
            for _ in range(80):
                frames(5)
                expired = observe("await-expiry")
                if expired["expiries"]:
                    break
            T.require(
                expired["expiries"] == 1
                and expired["turn"] == 3
                and expired["active"] == 1,
                "No-input deadline must commit exactly one turn and restart",
            )
        image = out / f"{variant}-expiry.png"
        machine.call("save_screenshot", path=str(image))
        key("t")
        disabled = observe("disabled")
        frames(250)
        stopped = observe("disabled-idle")
        T.require(
            disabled["active"] == 0
            and stopped["active"] == 0
            and stopped["turn"] == disabled["turn"],
            "Disabled time must not advance game",
        )
        memory = memory_layout(machine, bbc)
        result = {
            "memory": memory,
            "source_sha256": T.sha(source),
            "samples": samples,
            "image": image.name,
            "image_sha256": T.sha(image),
        }
    except Exception:
        machine.call("save_screenshot", path=str(out / f"{variant}-failure.png"))
        raise
    finally:
        machine.close()
    return result


def qualify(system: str, args: argparse.Namespace) -> None:
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
    subprocess.run(["make"], cwd=folder, check=True)
    out = folder / "verification"
    out.mkdir(exist_ok=True)
    records = (
        json.loads((out / "native.json").read_text())["variants"]
        if (out / "native.json").exists()
        else {}
    )
    for variant in args.variants.split(","):
        records[variant] = execute_variant(system, folder, command, variant)
    sources = {
        str(p.relative_to(ROOT)): T.sha(p)
        for p in sorted(folder.glob("*.bas"))
        + sorted((folder / "mistakes").glob("*.bas"))
        + [folder / "Makefile"]
    }
    if not bbc:
        shared = (
            ROOT / "commodore-64/patterns/basic/framework/command-loop/routines.bas"
        )
        sources[str(shared.relative_to(ROOT))] = T.sha(shared)
    result = {
        "status": "passed",
        "language": "basic",
        "sources": sources,
        "system": system,
        "emulator_sha256": T.sha(binary),
        "firmware_sha256": {
            p.name: T.sha(p) for p in [rom / "os.rom", rom / "basic.rom"] if p.exists()
        }
        if bbc
        else {
            name: T.sha(rom / name)
            for name in ["basic.rom", "kernal.rom", "chargen.rom"]
        },
        "variants": records,
    }
    (out / "native.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    parser.add_argument("--firmware", type=Path, required=True)
    parser.add_argument("--systems", default="commodore-64,bbc-micro")
    parser.add_argument("--variants", default="working,custom,wrong,repaired")
    options = parser.parse_args()
    for target in options.systems.split(","):
        qualify(target, options)
