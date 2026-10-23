"""Check retained PET/VIC BASIC state, tokenised memory and native pixels."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError("Missing maintained evidence module")
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


V = module("pet_vic_basic", "verify-pet-vic-basic-deadlines.py")
C = module("cbm_pixels", "check-commodore-deadlines.py")
T = V.T


def visible(system: str, path: Path) -> tuple[int, int, int]:
    w, h, c, b = C.P.png(path)
    expected = (384, 248) if system == "commodore-pet" else (230, 288)
    T.require((w, h) == expected, "Wrong native BASIC geometry")
    x, y = (32, 24) if system == "commodore-pet" else (28, 52)
    digits = C.DIGITS["commodore-vic-20"]

    def pixel(xx: int, yy: int) -> bytes:
        at = (yy * w + xx) * c
        return bytes(b[at : at + 3])

    background = pixel(x, y + 8)
    output = []
    for col in (5, 10, 15):
        rows = tuple(
            sum(
                int(pixel(x + col * 8 + xx, y + 8 + yy) != background) << (7 - xx)
                for xx in range(8)
            )
            for yy in range(8)
        )
        T.require(rows in digits, "Unrecognised native BASIC digit")
        output.append(digits.index(rows))
    return tuple(output)


def listing(system: str, variant: str) -> str:
    f = V.folder(system)
    shared = ROOT / "commodore-64/patterns/basic/framework/turn-deadline"
    if variant in ("boundaries", "wrong-boundary"):
        return V.fixture_listing(system, variant == "wrong-boundary")
    paths = [
        f / ("customise.bas" if variant == "custom" else "caller.bas"),
        shared / "../command-loop/routines.bas",
        shared / "routines.bas",
        shared / ("mistakes/reset-baseline.bas" if variant == "wrong" else "clock.bas"),
        ROOT / "commodore-pet/patterns/basic/framework/turn-deadline/presentation.bas",
    ]
    source = "".join(p.read_text() for p in paths)
    return source + "".join(
        l + "\n"
        for l in (shared / "monitor.bas").read_text().splitlines()
        if int(l.split()[0]) >= 9000
    )


def check(system: str, record: dict[str, Any] | None = None) -> None:
    T.require(system in V.SYSTEMS, "Wrong machine")
    folder = V.folder(system) / "verification"
    r = (
        record
        if record is not None
        else json.loads((folder / "results.json").read_text())
    )
    cfg = json.loads((folder / "configuration.json").read_text())
    T.require(
        (r["machine"], r["language"], r["status"])
        == (system, "basic", "native-checked"),
        "Wrong route identity",
    )
    T.require(
        r["sources"]
        == {
            str(p.resolve().relative_to(ROOT)): T.sha(p) for p in V.source_paths(system)
        },
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing case")
    T.require(
        r["emulator_release"] == "0.44.2"
        and r["emulator_sha256"] == cfg["emulator_sha256"]
        and r["firmware_sha256"] == cfg["firmware_sha256"],
        "Changed tools/firmware",
    )
    T.require(
        cfg["system"] == system
        and cfg["mailbox"] == (826 if system == "commodore-pet" else 828)
        and cfg["ram_bytes"] == (32768 if system == "commodore-pet" else 5120),
        "Wrong memory configuration",
    )
    for variant, c in r["cases"].items():
        source = listing(system, variant)
        import hashlib

        T.require(
            c["source_sha256"] == hashlib.sha256(source.encode()).hexdigest(),
            "Changed entered program",
        )
        T.require(c["server"]["version"] == "0.44.2", "Wrong actual emulator version")
        memory = c["memory"]
        workspace = memory["workspace_bytes"]
        word = lambda i, values=workspace: int.from_bytes(
            bytes(values[i : i + 2]), "little"
        )
        T.require(
            memory["workspace_address"] == (40 if system == "commodore-pet" else 43)
            and len(workspace) == 14,
            "Wrong BASIC pointer map",
        )
        T.require(
            [word(i) for i in (0, 2, 4, 6, 8, 12)]
            == [
                memory[k]
                for k in (
                    "program_start",
                    "program_end",
                    "heap_end",
                    "arrays_end",
                    "strings_start",
                    "memory_limit",
                )
            ],
            "Workspace values disagree",
        )
        T.require(
            memory["program_start"] == (1025 if system == "commodore-pet" else 4097)
            and memory["program_start"]
            < memory["program_end"]
            <= memory["heap_end"]
            <= memory["arrays_end"]
            < memory["strings_start"]
            <= memory["memory_limit"]
            <= (32768 if system == "commodore-pet" else 7680),
            "Native RAM limit exceeded",
        )
        T.require(
            len(memory["program_bytes"])
            == memory["program_end"] - memory["program_start"]
            and memory["free_gap"]
            == memory["strings_start"] - memory["arrays_end"]
            > 0,
            "Wrong program extent or free RAM",
        )
        program = memory["program_bytes"]
        parsed = []
        cursor = 0
        while cursor < len(program):
            next_line = int.from_bytes(bytes(program[cursor : cursor + 2]), "little")
            if next_line == 0:
                break
            length = next_line - memory["program_start"] - cursor
            T.require(
                length >= 5 and cursor + length <= len(program),
                "Invalid retained linked program",
            )
            parsed.append(
                {
                    "number": int.from_bytes(
                        bytes(program[cursor + 2 : cursor + 4]), "little"
                    ),
                    "bytes": length,
                }
            )
            cursor += length
        T.require(
            parsed == memory["lines"], "Tokenised program disagrees with line inventory"
        )
        variables = memory["variable_bytes"]
        actual_names = []
        for offset in range(0, len(variables), 7):
            first, second = variables[offset : offset + 2]
            actual_names.append(
                chr(first & 127)
                + (chr(second & 127) if second & 127 else "")
                + ("$" if second & 128 else "")
            )
        T.require(
            actual_names == memory["variable_names"],
            "Variable names disagree with native table",
        )
        expected_numbers = sorted(int(l.split()[0]) for l in source.splitlines())
        T.require(
            len(expected_numbers) == len(set(expected_numbers))
            and [l["number"] for l in memory["lines"]] == expected_numbers,
            "Missing or duplicate native lines",
        )
        T.require(
            memory["helper_token_bytes"]
            == (192 if variant == "wrong-boundary" else 191),
            "Changed helper token size",
        )
        T.require(
            len(memory["variable_bytes"]) == memory["heap_end"] - memory["heap_start"]
            and len(memory["variable_names"]) * 7 == len(memory["variable_bytes"])
            and {"DU", "DC", "DP", "DR", "DA", "DX", "DE"}
            <= set(memory["variable_names"]),
            "Missing numeric state or wrong variable extent",
        )
        image = folder / c["image"]
        T.require(T.sha(image) == c["image_sha256"], "Changed image")
        if variant in ("boundaries", "wrong-boundary"):
            data = c["bytes"]
            good = variant == "boundaries"
            T.require(
                len(data) == 99 and data[0] == 165 and data[-2:] == [90, 239],
                "Incomplete boundary fixture",
            )
            T.require(
                (data == V.expected_fixture()) == good and c["oracle_matches"] == good,
                "Boundary oracle/control mismatch",
            )
            continue
        wrong = variant == "wrong"
        states = c["samples"]
        names = [s["stage"] for s in states]
        T.require(
            names[:5]
            == ["initial", "untimed-idle", "untimed-action", "enabled", "idle-progress"]
            and names[-2:] == ["disabled", "disabled-idle"],
            "Missing caller stages",
        )
        T.require(
            names[5:-2]
            == (
                ["wrong-never-expires"]
                if wrong
                else ["action-restarts"] + ["await-expiry"] * (len(names) - 8)
            ),
            "Wrong expiry sequence",
        )
        duration = 120 if variant == "custom" else 240
        for s in states:
            raw = s["raw"]
            T.require(
                len(raw) == 20 and raw[16:18] == [165, 90] and raw[19] == 239,
                "Wrong coherent mailbox/guards",
            )
            values = [raw[0], raw[1], raw[2]] + [
                int.from_bytes(bytes(raw[i : i + 3]), "little") for i in (3, 6, 9, 12)
            ]
            T.require(
                values
                == [
                    s[k]
                    for k in (
                        "turn",
                        "expiries",
                        "active",
                        "remaining",
                        "clock",
                        "duration",
                        "elapsed",
                    )
                ]
                and s["duration"] == duration,
                "Mailbox disagrees with reported state",
            )
        by = {s["stage"]: s for s in states}
        a, b = states[0], states[1]
        T.require(
            a["turn"] == b["turn"] == a["active"] == b["active"] == 0
            and b["clock"] != a["clock"],
            "Untimed idle did not work",
        )
        T.require(
            by["untimed-action"]["turn"] == 1 and by["untimed-action"]["active"] == 0,
            "Untimed action enabled clock",
        )
        a, b = by["enabled"], by["idle-progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turn"] == b["turn"] == 1
            and b["clock"] != a["clock"],
            "No enabled advancing timer",
        )
        if wrong:
            e = by["wrong-never-expires"]
            T.require(
                e["turn"] == 1
                and e["expiries"] == 0
                and e["remaining"] == duration
                and e["elapsed"] == 0
                and e["clock"] != b["clock"],
                "Baseline-reset fault did not run",
            )
        else:
            T.require(
                a["remaining"] > b["remaining"] > 0
                and a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 5184000,
                "Countdown and elapsed time disagree",
            )
            e = by["action-restarts"]
            T.require(
                e["turn"] == 2 and e["active"] == 1 and e["remaining"] > b["remaining"],
                "Action failed to restart",
            )
            e = states[-3]
            T.require(
                e["turn"] == 3 and e["expiries"] == e["active"] == 1,
                "No automatic turn",
            )
        T.require(
            visible(system, image) == ((1, 0, 1) if wrong else (3, 1, 1)),
            "Native BASIC pixels disagree",
        )
        a, b = states[-2:]
        T.require(
            a["active"] == b["active"] == 0
            and a["turn"] == b["turn"] == (1 if wrong else 3)
            and b["frames"] - a["frames"] >= 250,
            "Disabled turns advanced",
        )
    T.require(
        r["cases"]["working"]["source_sha256"]
        == r["cases"]["repaired"]["source_sha256"],
        "Repair is not the working source",
    )


if __name__ == "__main__":
    for machine in V.SYSTEMS:
        check(machine)
        print(machine, "native BASIC deadlines, memory and pixels passed")
