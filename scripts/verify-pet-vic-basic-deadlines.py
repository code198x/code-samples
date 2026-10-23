"""Type and qualify shared Commodore BASIC deadlines on PET and stock VIC-20."""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "basic_transport", ROOT / "scripts/verify-basic-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing BASIC observer")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T
SYSTEMS = ("commodore-pet", "commodore-vic-20")
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")
CASES = (
    (0, 0, 1),
    (1, 0, 0),
    (1, 0, 1),
    (1, 0, 2),
    (240, 100, 339),
    (240, 100, 340),
    (240, 100, 500),
    (240, 5183990, 10),
    (240, 65530, 65545),
    (65535, 10, 65545),
    (5183999, 0, 5183998),
    (5183999, 0, 5183999),
)


def folder(system: str) -> Path:
    return ROOT / system / "patterns/basic/framework/turn-deadline"


def source_paths(system: str) -> list[Path]:
    shared = ROOT / "commodore-64/patterns/basic/framework/turn-deadline"
    return (
        [folder(system) / n for n in ("caller.bas", "customise.bas", "Makefile")]
        + [
            shared / n
            for n in (
                "routines.bas",
                "clock.bas",
                "monitor.bas",
                "mistakes/reset-baseline.bas",
                "../command-loop/routines.bas",
            )
        ]
        + [
            ROOT
            / "commodore-pet/patterns/basic/framework/turn-deadline/presentation.bas",
            ROOT / "scripts/verify-basic-deadlines.py",
            ROOT / "scripts/verify-game-loops.py",
            Path(__file__),
        ]
    )


def memory_layout(machine: Any, system: str) -> dict[str, Any]:
    address = 0x28 if system == "commodore-pet" else 0x2B
    raw = machine.call("memory_read", addr=address, len=14)["bytes"]
    T.require(len(raw) == 14, "Short BASIC pointers")
    word = lambda i: int.from_bytes(bytes(raw[i : i + 2]), "little")
    start, end, heap_end, arrays_end, strings_start, _, limit = [
        word(i) for i in range(0, 14, 2)
    ]
    T.require(
        start == (0x401 if system == "commodore-pet" else 0x1001)
        and start < end <= heap_end <= arrays_end < strings_start <= limit,
        "Invalid BASIC workspace or exhausted heap",
    )
    program = []
    for offset in range(0, end - start, 128):
        size = min(128, end - start - offset)
        chunk = machine.call("memory_read", addr=start + offset, len=size)["bytes"]
        T.require(len(chunk) == size, "Short native program")
        program += chunk
    lines = []
    cursor = 0
    while cursor < len(program):
        next_line = int.from_bytes(bytes(program[cursor : cursor + 2]), "little")
        if next_line == 0:
            break
        number = int.from_bytes(bytes(program[cursor + 2 : cursor + 4]), "little")
        length = next_line - start - cursor
        T.require(
            length >= 5 and cursor + length <= len(program), "Invalid linked BASIC line"
        )
        lines.append({"number": number, "bytes": length})
        cursor += length
    variable_bytes = []
    for offset in range(0, heap_end - end, 128):
        size = min(128, heap_end - end - offset)
        chunk = machine.call("memory_read", addr=end + offset, len=size)["bytes"]
        T.require(len(chunk) == size, "Short variable table")
        variable_bytes += chunk
    T.require(len(variable_bytes) % 7 == 0, "Invalid variable-entry extent")
    names = []
    for offset in range(0, len(variable_bytes), 7):
        first, second = variable_bytes[offset : offset + 2]
        names.append(
            chr(first & 127)
            + (chr(second & 127) if second & 127 else "")
            + ("$" if second & 128 else "")
        )
    return {
        "variable_bytes": variable_bytes,
        "variable_names": names,
        "workspace_address": address,
        "workspace_bytes": raw,
        "program_start": start,
        "program_end": end,
        "program_bytes": program,
        "lines": lines,
        "helper_token_bytes": sum(
            x["bytes"] for x in lines if 3000 <= x["number"] <= 3250
        ),
        "heap_start": end,
        "heap_end": heap_end,
        "arrays_end": arrays_end,
        "strings_start": strings_start,
        "memory_limit": limit,
        "free_gap": strings_start - arrays_end,
    }


def execute_variant(
    system: str, folder: Path, command: list[str], variant: str
) -> dict:
    mailbox = 826 if system == "commodore-pet" else 828
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
            raw = machine.call("memory_read", addr=mailbox, len=20)["bytes"]
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
        memory = memory_layout(machine, system)
        expected_lines = sorted(
            int(line.split()[0]) for line in source.read_text().splitlines()
        )
        T.require(
            [line["number"] for line in memory["lines"]] == expected_lines,
            "Typed program line inventory differs",
        )
        result = {
            "server": machine.server["serverInfo"],
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


def fixture_listing(system: str, wrong: bool) -> str:
    shared = ROOT / "commodore-64/patterns/basic/framework/turn-deadline"
    helper = (shared / "routines.bas").read_text()
    if wrong:
        changed = helper.replace("IF DR>0 THEN RETURN", "IF DR>=0 THEN RETURN")
        T.require(changed != helper, "No equality mutation")
        helper = changed
    mailbox = 826 if system == "commodore-pet" else 828
    header = f"10 MB={mailbox}:POKE MB,165:POKE MB+97,90\n20 FOR I=0 TO 11:READ DU,PV,NW\n30 DC=PV:GOSUB 3000:GOSUB 3100:DC=NW:GOSUB 3200\n40 V=DR:O=1+I*8:GOSUB 9100\n50 V=DE:O=4+I*8:GOSUB 9100\n60 POKE MB+7+I*8,DA:POKE MB+8+I*8,DX:NEXT\n70 POKE MB+98,239:END\n"
    data = "".join(
        f"{2000 + i} DATA {duration},{previous},{now}\n"
        for i, (duration, previous, now) in enumerate(CASES)
    )
    encoder = (
        "\n".join(
            l
            for l in (shared / "monitor.bas").read_text().splitlines()
            if int(l.split()[0]) >= 9100
        )
        + "\n"
    )
    return header + data + helper + encoder


def expected_fixture() -> list[int]:
    data = [165]
    for duration, previous, now in CASES:
        elapsed = (now - previous) % 5184000
        expired = int(duration > 0 and elapsed >= duration)
        remaining = max(0, duration - elapsed) if duration else 0
        active = int(duration > 0 and not expired)
        data += (
            list(remaining.to_bytes(3, "little"))
            + list(elapsed.to_bytes(3, "little"))
            + [active, expired]
        )
    return data + [90, 239]


def execute_fixture(system: str, variant: str, cmd: list[str]) -> dict[str, Any]:
    f = folder(system)
    out = f / "verification"
    source = fixture_listing(system, variant == "wrong-boundary")
    (f / f"build/{variant}.bas").write_text(source)
    m = T.Machine(cmd)
    mailbox = 826 if system == "commodore-pet" else 828
    try:
        m.call("run_frames", frames=150)
        for line in (source + "RUN\n").splitlines():
            result = m.call(
                "type_string", text=line + "\n", hold_frames=3, settle_frames=8
            )
            T.require(
                result["chars_typed"] == len(line) + 1, "Incomplete typed fixture"
            )
        for _ in range(100):
            m.call("run_frames", frames=10)
            data = m.call("memory_read", addr=mailbox, len=99)["bytes"]
            if len(data) == 99 and data[-1] == 239:
                break
        T.require(
            len(data) == 99 and data[0] == 165 and data[-2:] == [90, 239],
            "Fixture or guards incomplete",
        )
        good = variant == "boundaries"
        equal = data == expected_fixture()
        T.require(equal == good, "Native boundary/control mismatch")
        image = out / f"{variant}.png"
        m.call("save_screenshot", path=str(image))
        return {
            "bytes": data,
            "oracle_matches": equal,
            "source_sha256": T.sha(f / f"build/{variant}.bas"),
            "image": image.name,
            "image_sha256": T.sha(image),
            "memory": memory_layout(m, system),
            "server": m.server["serverInfo"],
        }
    finally:
        m.close()


def command(system: str, args: argparse.Namespace) -> tuple[list[str], Path, Path]:
    exe = args.tools / f"emu198x-{system}-aarch64-apple-darwin" / f"emu198x-{system}"
    rom = args.firmware / system
    return (
        [str(exe), "--mcp", "--rom-dir", str(rom)]
        + (
            ["--columns", "40"]
            if system == "commodore-pet"
            else ["--region", "pal", "--ram-expansion", "none"]
        ),
        exe,
        rom,
    )


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--systems", default=",".join(SYSTEMS))
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    for system in args.systems.split(","):
        T.require(system in SYSTEMS, "Unknown system")
        f = folder(system)
        out = f / "verification"
        out.mkdir(exist_ok=True)
        subprocess.run(["make"], cwd=f, check=True, capture_output=True, timeout=30)
        cmd, exe, rom = command(system, args)
        target = out / "results.json"
        r = (
            json.loads(target.read_text())
            if target.exists()
            else {
                "status": "native-checked",
                "machine": system,
                "language": "basic",
                "cases": {},
            }
        )
        for variant in args.variants.split(","):
            T.require(variant in VARIANTS, "Unknown variant")
            r["cases"][variant] = (
                execute_fixture(system, variant, cmd)
                if variant in ("boundaries", "wrong-boundary")
                else execute_variant(system, f, cmd, variant)
            )
            r.update(
                sources={
                    str(q.resolve().relative_to(ROOT)): T.sha(q)
                    for q in source_paths(system)
                },
                emulator_release="0.44.2",
                emulator_sha256=T.sha(exe),
                firmware_sha256={q.name: T.sha(q) for q in rom.glob("*.rom")},
            )
            target.write_text(json.dumps(r, indent=2) + "\n")
            print(system, variant, "passed", flush=True)


if __name__ == "__main__":
    main()
