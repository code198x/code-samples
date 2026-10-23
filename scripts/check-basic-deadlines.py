"""Validate retained native BASIC observations; this does not rerun emulation."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SYSTEMS = ("commodore-64", "bbc-micro")


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def folder(system: str) -> Path:
    return ROOT / system / "patterns/basic/framework/turn-deadline"


def listing(system: str, variant: str) -> str:
    p = folder(system)
    caller = "customise.bas" if variant == "custom" else "caller.bas"
    turn = (
        p / "turn.bas" if system == "bbc-micro" else p / "../command-loop/routines.bas"
    )
    clock = "mistakes/reset-baseline.bas" if variant == "wrong" else "clock.bas"
    return "".join(
        f.read_text()
        for f in [p / caller, turn, p / "routines.bas", p / clock, p / "monitor.bas"]
    )


def check(
    system: str,
    record: dict[str, Any] | None = None,
    boundaries: dict[str, Any] | None = None,
) -> None:
    require(system in SYSTEMS, "Unknown system")
    p = folder(system)
    if record is None:
        record = json.loads((p / "verification/native.json").read_text())
    if boundaries is None:
        boundaries = json.loads((p / "verification/boundaries.json").read_text())
    require(
        record["status"] == "passed"
        and record["system"] == system
        and record["language"] == "basic",
        "Wrong identity/status",
    )
    sources = (
        sorted(p.glob("*.bas"))
        + sorted((p / "mistakes").glob("*.bas"))
        + [p / "Makefile"]
    )
    if system == "commodore-64":
        sources += [
            ROOT / "commodore-64/patterns/basic/framework/command-loop/routines.bas"
        ]
    require(
        record["sources"] == {str(f.relative_to(ROOT)): sha(f) for f in sources},
        "Changed source binding",
    )
    require(len(record["emulator_sha256"]) == 64, "Missing emulator identity")
    firmware = (
        {"os.rom", "basic.rom"}
        if system == "bbc-micro"
        else {"basic.rom", "kernal.rom", "chargen.rom"}
    )
    require(
        set(record["firmware_sha256"]) == firmware
        and all(len(x) == 64 for x in record["firmware_sha256"].values()),
        "Missing firmware identities",
    )
    require(
        set(record["variants"]) == {"working", "custom", "wrong", "repaired"},
        "Missing native variant",
    )
    for variant, case in record["variants"].items():
        require(
            case["source_sha256"]
            == hashlib.sha256(listing(system, variant).encode()).hexdigest(),
            "Changed entered program",
        )
        samples = case["samples"]
        require(len(samples) > 7, "No native trace")
        for state in samples:
            raw = state["raw"]
            require(
                len(raw) == 20 and raw[16:18] == [165, 90] and raw[19] == 239,
                "Incomplete or damaged native snapshot",
            )
            decoded = {
                "turn": raw[0],
                "expiries": raw[1],
                "active": raw[2],
                **{
                    k: int.from_bytes(bytes(raw[i : i + 3]), "little")
                    for k, i in [
                        ("remaining", 3),
                        ("clock", 6),
                        ("duration", 9),
                        ("elapsed", 12),
                    ]
                },
            }
            require(
                all(state[k] == v for k, v in decoded.items()),
                "Summary disagrees with native bytes",
            )
        stages = {x["stage"]: x for x in samples}
        initial, idle, action, enabled, progress = (
            stages[k]
            for k in [
                "initial",
                "untimed-idle",
                "untimed-action",
                "enabled",
                "idle-progress",
            ]
        )
        require(
            initial["turn"] == idle["turn"] == 0
            and initial["active"] == idle["active"] == 0
            and initial["clock"] != idle["clock"],
            "Untimed idle changed state or clock stopped",
        )
        require(
            action["turn"] == 1 and action["active"] == 0 and enabled["active"] == 1,
            "Wrong untimed action/enable policy",
        )
        expected_duration = (400 if system == "bbc-micro" else 240) // (
            2 if variant == "custom" else 1
        )
        require(
            all(x["duration"] == expected_duration for x in samples),
            "Wrong custom duration",
        )
        require(
            progress["clock"] != enabled["clock"], "No independent clock progression"
        )
        if variant == "wrong":
            wrong = stages["wrong-never-expires"]
            modulus = 65536 if system == "bbc-micro" else 5184000
            require(
                (wrong["clock"] - enabled["clock"]) % modulus > expected_duration,
                "Fault was not observed beyond deadline",
            )
            require(
                wrong["remaining"] == expected_duration
                and wrong["elapsed"] == 0
                and wrong["turn"] == 1
                and wrong["expiries"] == 0
                and wrong["active"] == 1,
                "Fault did not reveal baseline reset",
            )
        else:
            modulus = 65536 if system == "bbc-micro" else 5184000
            require(
                enabled["remaining"] - progress["remaining"]
                == (progress["clock"] - enabled["clock"]) % modulus
                > 0,
                "Remaining time disagrees with native clock",
            )
            restart = stages["action-restarts"]
            require(
                restart["turn"] == 2
                and restart["active"] == 1
                and restart["remaining"] > progress["remaining"],
                "Missing restart",
            )
            expired = [x for x in samples if x["stage"] == "await-expiry"][-1]
            require(
                expired["turn"] == 3
                and expired["expiries"] == 1
                and expired["active"] == 1,
                "Automatic expiry missing or duplicated",
            )
        disabled, stopped = stages["disabled"], stages["disabled-idle"]
        require(
            disabled["active"] == stopped["active"] == 0
            and disabled["turn"] == stopped["turn"]
            and stopped["frames"] - disabled["frames"] >= 250,
            "Disabled idle changed game or was not observed",
        )
        require(
            sha(p / "verification" / case["image"]) == case["image_sha256"],
            "Changed capture",
        )
    memory = record["variants"]["working"]["memory"]
    workspace = memory["workspace_bytes"]
    word = lambda i: int.from_bytes(bytes(workspace[i : i + 2]), "little")
    bbc = system == "bbc-micro"
    start = workspace[24] * 256 if bbc else word(0)
    end = word(18) if bbc else word(2)
    require(
        memory["program_start"] == start and memory["program_end"] == end,
        "Wrong native program pointers",
    )
    raw = memory["program_bytes"]
    require(len(raw) == end - start, "Truncated native BASIC program")
    decoded = []
    cursor = 0
    while cursor < len(raw):
        if bbc:
            if raw[cursor : cursor + 2] == [13, 255]:
                break
            require(
                raw[cursor] == 13 and cursor + 4 <= len(raw), "Wrong BBC line header"
            )
            number = raw[cursor + 1] * 256 + raw[cursor + 2]
            size = raw[cursor + 3]
        else:
            next_line = int.from_bytes(bytes(raw[cursor : cursor + 2]), "little")
            if next_line == 0:
                break
            number = int.from_bytes(bytes(raw[cursor + 2 : cursor + 4]), "little")
            size = next_line - start - cursor
        require(5 <= size <= len(raw) - cursor, "Wrong native line extent")
        decoded.append({"number": number, "bytes": size})
        cursor += size
    require(
        cursor + 2 == len(raw), "Native program has missing terminator or trailing data"
    )
    require(
        decoded == memory["lines"]
        and [x["number"] for x in decoded]
        == sorted(int(l.split()[0]) for l in listing(system, "working").splitlines()),
        "Entered line inventory differs from public source",
    )
    require(
        memory["helper_token_bytes"]
        == sum(x["bytes"] for x in decoded if 3000 <= x["number"] <= 3250)
        > 0,
        "Wrong helper size",
    )
    require(
        memory["heap_start"] == (word(0) if bbc else word(2))
        and memory["heap_end"] == (word(2) if bbc else word(4)) > memory["heap_start"],
        "Wrong native variable heap",
    )
    require(
        boundaries["system"] == system
        and boundaries["modulus"] == (65536 if system == "bbc-micro" else 5184000),
        "Wrong boundary configuration",
    )
    monitor = (
        "\n".join(
            l
            for l in (p / "monitor.bas").read_text().splitlines()
            if int(l.split()[0]) >= 9100
        )
        + "\n"
    )
    source = (
        (p / "boundaries.bas").read_text() + (p / "routines.bas").read_text() + monitor
    )
    require(
        boundaries["listing_sha256"] == hashlib.sha256(source.encode()).hexdigest(),
        "Changed boundary caller",
    )
    cases = [
        list(map(int, l.split(" DATA ")[1].split(",")))
        for l in source.splitlines()
        if " DATA " in l
    ]
    require(
        len(cases) == len(boundaries["cases"]) == 12
        and boundaries["raw"][100:] == [165, 90],
        "Missing completed boundary cases",
    )
    for i, ((previous, now, duration), case) in enumerate(
        zip(cases, boundaries["cases"], strict=True)
    ):
        elapsed = (now - previous) % boundaries["modulus"]
        expired = int(duration > 0 and elapsed >= duration)
        expected = (
            [int(duration > 0 and not expired), expired]
            + list(
                (max(0, duration - elapsed) if duration else 0).to_bytes(3, "little")
            )
            + list(elapsed.to_bytes(3, "little"))
        )
        require(
            [case[k] for k in ["previous", "now", "duration"]]
            == [previous, now, duration]
            and case["bytes"] == expected == boundaries["raw"][i * 8 : i * 8 + 8],
            "Native arithmetic disagrees with oracle",
        )
    require(
        boundaries["emulator_sha256"] == record["emulator_sha256"]
        and sha(p / "verification/boundaries.png") == boundaries["image_sha256"],
        "Changed boundary identity/capture",
    )


if __name__ == "__main__":
    for system in SYSTEMS:
        check(system)
        print(system, "native BASIC deadline records passed")
