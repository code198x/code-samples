"""Run maintained BASIC deadlines on independent Electron and CPC firmware.

Only typed source and actual input alter guest state. Supply lawful firmware.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "basic_deadlines", ROOT / "scripts/verify-basic-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing existing BASIC transport")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T
SYSTEMS = ("acorn-electron", "amstrad-cpc")
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")


def folder(system: str) -> Path:
    return ROOT / system / "patterns/basic/framework/turn-deadline"


def shared(system: str) -> Path:
    return (
        ROOT
        / ("bbc-micro" if system == "acorn-electron" else system)
        / "patterns/basic/framework/turn-deadline"
    )


def listing(system: str, variant: str) -> str:
    p = shared(system)
    if variant in ("boundaries", "wrong-boundary"):
        helper = (p / "routines.bas").read_text()
        if variant == "wrong-boundary":
            suffix = "%" if system == "acorn-electron" else "!"
            changed = helper.replace(
                "IF DR" + suffix + ">0 THEN RETURN",
                "IF DR" + suffix + ">=0 THEN RETURN",
            )
            T.require(changed != helper, "Equality control did not alter helper")
            helper = changed
        monitor = (
            "\n".join(
                l
                for l in (p / "monitor.bas").read_text().splitlines()
                if int(l.split()[0]) >= 9100
            )
            + "\n"
        )
        return (
            (p / "boundaries.bas").read_text()
            + helper
            + ((p / "reduce.bas").read_text() if system == "amstrad-cpc" else "")
            + monitor
        )
    return "".join(
        (p / name).read_text()
        for name in [
            "customise.bas" if variant == "custom" else "caller.bas",
            "turn.bas",
            "routines.bas",
            "mistakes/reset-baseline.bas" if variant == "wrong" else "clock.bas",
            "monitor.bas",
        ]
        + (["reduce.bas"] if system == "amstrad-cpc" else [])
    )


def source_paths(system: str) -> list[Path]:
    p = shared(system)
    return (
        sorted(p.glob("*.bas"))
        + sorted((p / "mistakes").glob("*.bas"))
        + [
            p / "Makefile",
            ROOT / "scripts/verify-basic-deadlines.py",
            ROOT / "scripts/verify-game-loops.py",
            Path(__file__),
        ]
        + ([folder(system) / "Makefile"] if system == "acorn-electron" else [])
    )


def cpc_program(machine: Any, source: str) -> dict:
    """Observe and validate the stock BASIC 1.0 tokenised line chain, not a universal ABI."""
    start = 0x170
    cursor = start
    program = []
    lines = []
    for _ in range(200):
        header = machine.call("memory_read", addr=cursor, len=4)["bytes"]
        length = header[0] + 256 * header[1]
        if length == 0:
            program += header[:2]
            break
        T.require(
            5 <= length <= 255 and cursor + length < 0xA000,
            "Invalid CPC BASIC line extent",
        )
        raw = machine.call("memory_read", addr=cursor, len=length)["bytes"]
        T.require(len(raw) == length and raw[-1] == 0, "Incomplete CPC BASIC line")
        lines.append({"number": header[2] + 256 * header[3], "bytes": length})
        program += raw
        cursor += length
    else:
        raise AssertionError("CPC tokenised program did not terminate")
    T.require(
        [l["number"] for l in lines]
        == sorted(int(l.split()[0]) for l in source.splitlines()),
        "CPC entered line inventory differs",
    )
    return {
        "program_start": start,
        "program_end": start + len(program),
        "program_bytes": program,
        "lines": lines,
        "helper_token_bytes": sum(
            l["bytes"] for l in lines if 3000 <= l["number"] <= 3250
        ),
    }


def execute(system: str, variant: str, a: argparse.Namespace) -> dict[str, Any]:
    electron = system == "acorn-electron"
    exe = a.tools / f"emu198x-{system}-aarch64-apple-darwin" / f"emu198x-{system}"
    rom = a.firmware / system
    command = [str(exe), "--mcp"] + (
        ["--os", str(rom / "os.rom"), "--basic", str(rom / "basic.rom")]
        if electron
        else ["--rom-dir", str(rom)]
    )
    out = folder(system) / "verification"
    out.mkdir(parents=True, exist_ok=True)
    text = listing(system, variant)
    machine = T.Machine(command)
    total = 0
    samples = []
    base = 0x3000 if electron else 0xA000

    def frames(n: int) -> None:
        nonlocal total
        while n:
            count = min(200, n)
            machine.call("run_frames", frames=count)
            n -= count
            total += count

    def observe(stage: str) -> dict:
        for _ in range(150):
            raw = machine.call("memory_read", addr=base, len=20)["bytes"]
            T.require(len(raw) == 20, "Short native mailbox")
            if raw[19] == 239 and raw[16:18] == [165, 90]:
                s = {
                    "stage": stage,
                    "frames": total,
                    "raw": raw,
                    "turn": raw[0],
                    "expiries": raw[1],
                    "active": raw[2],
                    **{
                        name: int.from_bytes(bytes(raw[i : i + 3]), "little")
                        for name, i in [
                            ("remaining", 3),
                            ("clock", 6),
                            ("duration", 9),
                            ("elapsed", 12),
                        ]
                    },
                }
                samples.append(s)
                print(
                    system,
                    variant,
                    stage,
                    {k: v for k, v in s.items() if k != "raw"},
                    flush=True,
                )
                return s
            frames(1)
        machine.call("save_screenshot", path=str(out / f"{variant}-failure.png"))
        raise AssertionError(f"{system}/{variant}/{stage}: no coherent mailbox {raw}")

    def tap(key: str) -> None:
        machine.call("input", events=[{"Key": {"name": key, "pressed": True}}])
        frames(3)
        machine.call("input", events=[{"Key": {"name": key, "pressed": False}}])
        frames(30)

    try:
        frames(150)
        for line in (text + "RUN\n").splitlines():
            r = machine.call(
                "type_string", text=line + "\n", hold_frames=3, settle_frames=8
            )
            T.require(r["chars_typed"] == len(line) + 1, "Incomplete typed source")
        frames(20)
        images = {}
        if variant in ("boundaries", "wrong-boundary"):
            for _ in range(60):
                frames(20)
                raw = machine.call("memory_read", addr=base, len=102)["bytes"]
                if raw[100:102] == [165, 90]:
                    break
            T.require(
                len(raw) == 102 and raw[100:] == [165, 90],
                "Boundary caller did not complete",
            )
            cases = [
                list(map(int, l.split(" DATA ")[1].split(",")))
                for l in text.splitlines()
                if " DATA " in l
            ]
            expected = []
            for previous, now, duration in cases:
                elapsed = (now - previous) % 65536
                expired = int(duration > 0 and elapsed >= duration)
                expected += (
                    [int(duration > 0 and not expired), expired]
                    + list(
                        (max(0, duration - elapsed) if duration else 0).to_bytes(
                            3, "little"
                        )
                    )
                    + list(elapsed.to_bytes(3, "little"))
                )
            equal = raw[:96] == expected
            T.require(
                equal == (variant == "boundaries"),
                "Native arithmetic control disagrees",
            )
            image = out / f"{variant}.png"
            machine.call("save_screenshot", path=str(image))
            images[image.name] = T.sha(image)
            result = {"raw": raw, "cases": cases, "oracle_matches": equal}
        else:
            first = observe("initial")
            T.require(first["turn"] == first["active"] == 0, "Must start untimed")
            frames(100)
            idle = observe("untimed-idle")
            T.require(
                idle["turn"] == 0 and idle["clock"] != first["clock"],
                "Idle clock or turn wrong",
            )
            tap("space")
            action = observe("untimed-action")
            T.require(
                action["turn"] == 1 and action["active"] == 0,
                "Untimed action enabled clock",
            )
            tap("t")
            enabled = observe("enabled")
            T.require(
                enabled["active"] == 1 and enabled["expiries"] == 0, "T did not enable"
            )
            frames(30)
            progress = observe("idle-progress")
            T.require(progress["clock"] != enabled["clock"], "Native clock stopped")
            if variant == "wrong":
                frames(300)
                end = observe("wrong-never-expires")
                T.require(
                    end["turn"] == 1
                    and end["expiries"] == 0
                    and end["remaining"] == end["duration"]
                    and end["elapsed"] == 0,
                    "Baseline fault not observed",
                )
            else:
                T.require(
                    progress["remaining"] < enabled["remaining"], "Countdown stopped"
                )
                tap("space")
                restart = observe("action-restarts")
                T.require(
                    restart["turn"] == 2
                    and restart["active"] == 1
                    and restart["remaining"] > progress["remaining"],
                    "Action did not restart",
                )
                for _ in range(90):
                    frames(5)
                    end = observe("await-expiry")
                    if end["expiries"]:
                        break
                T.require(
                    (end["turn"], end["expiries"], end["active"]) == (3, 1, 1),
                    "No-input expiry did not take exactly one turn",
                )
            image = out / f"{variant}-expiry.png"
            machine.call("save_screenshot", path=str(image))
            images[image.name] = T.sha(image)
            tap("t")
            disabled = observe("disabled")
            frames(250)
            stopped = observe("disabled-idle")
            T.require(
                disabled["active"] == stopped["active"] == 0
                and stopped["turn"] == disabled["turn"],
                "Disabled timer advanced game",
            )
            memory = (
                V.memory_layout(machine, True)
                if electron
                else cpc_program(machine, text)
            )
            result = {"samples": samples, "memory": memory}
        return {
            **result,
            "listing_sha256": __import__("hashlib").sha256(text.encode()).hexdigest(),
            "images": images,
            "server": machine.server["serverInfo"],
            "emulator_sha256": T.sha(exe),
            "firmware_sha256": {
                name: T.sha(rom / name)
                for name in (["os.rom", "basic.rom"] if electron else ["cpc464.rom"])
            },
        }
    except Exception:
        machine.call("save_screenshot", path=str(out / f"{variant}-failure.png"))
        raise
    finally:
        machine.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--systems", default=",".join(SYSTEMS))
    p.add_argument("--variants", default=",".join(VARIANTS))
    a = p.parse_args()
    for system in a.systems.split(","):
        T.require(system in SYSTEMS, "Unknown machine")
        subprocess.run(["make"], cwd=folder(system), check=True)
        out = folder(system) / "verification/results.json"
        record = (
            json.loads(out.read_text())
            if out.exists()
            else {
                "status": "native-checked",
                "system": system,
                "language": "basic",
                "cases": {},
            }
        )
        for variant in a.variants.split(","):
            T.require(variant in VARIANTS, "Unknown variant")
            record["cases"][variant] = execute(system, variant, a)
            record["sources"] = {
                str(p.relative_to(ROOT)): T.sha(p) for p in source_paths(system)
            }
            out.write_text(json.dumps(record, indent=2) + "\n")
            print(system, variant, "passed", flush=True)


if __name__ == "__main__":
    main()
