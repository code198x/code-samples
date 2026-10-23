"""Check retained MSX BASIC execution, native lines and countdown invariants."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "native", ROOT / "scripts/verify-msx-basic-deadlines.py"
)
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T
F = V.folder("msx")


def listing(variant):
    shared = ROOT / "commodore-64/patterns/basic/framework/turn-deadline"
    if "boundar" in variant:
        return V.fixture_listing("msx", variant == "wrong-boundary")
    parts = [
        F / ("customise.bas" if variant == "custom" else "caller.bas"),
        shared / "../command-loop/routines.bas",
        ROOT / "dragon-32/patterns/basic/framework/turn-deadline/routines.bas",
        F / ("mistakes/reset-baseline.bas" if variant == "wrong" else "clock.bas"),
        F / "presentation.bas",
    ]
    return "".join(p.read_text() for p in parts) + "".join(
        l + "\n"
        for l in (shared / "monitor.bas").read_text().splitlines()
        if int(l.split()[0]) >= 9000
    )


def check(record=None):
    r = (
        record
        if record is not None
        else json.loads((F / "verification/results.json").read_text())
    )
    cfg = json.loads((F / "verification/configuration.json").read_text())
    T.require(
        (r["machine"], r["language"], r["status"])
        == ("msx", "basic", "native-checked"),
        "Wrong route",
    )
    T.require(
        r["sources"]
        == {
            str(p.resolve().relative_to(ROOT)): T.sha(p) for p in V.source_paths("msx")
        },
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing caller")
    T.require(
        r["emulator_sha256"] == cfg["emulator_sha256"]
        and r["firmware_sha256"] == cfg["firmware_sha256"]
        and cfg["ram_bytes"] == 65536
        and cfg["mailbox"] == 49152,
        "Configuration mismatch",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong actual emulator")
        T.require(
            c["source_sha256"] == hashlib.sha256(listing(variant).encode()).hexdigest(),
            "Changed entered source",
        )
        T.require(
            T.sha(F / "verification" / c["image"]) == c["image_sha256"],
            "Changed capture",
        )
        m = c["memory"]
        pointers = m["pointers"]
        T.require(
            {k: v["address"] for k, v in pointers.items()}
            == {"text": 0xF676, "variables": 0xF6C2, "limit": 0xF672},
            "Wrong BIOS/BASIC pointer map",
        )
        raw = pointers["variables"]["bytes"]
        word = lambda i, values=raw: int.from_bytes(bytes(values[i : i + 2]), "little")
        T.require(
            [
                int.from_bytes(bytes(pointers["text"]["bytes"]), "little"),
                word(0),
                word(4),
                int.from_bytes(bytes(pointers["limit"]["bytes"]), "little"),
            ]
            == [
                m[k]
                for k in ("program_start", "program_end", "arrays_end", "memory_limit")
            ],
            "Workspace interpretation differs",
        )
        T.require(
            m["program_start"] == 0x8001
            and m["program_start"]
            < m["program_end"]
            <= m["arrays_end"]
            < m["memory_limit"]
            <= 0xC000,
            "BASIC reservation exceeded",
        )
        program = m["program_bytes"]
        cursor = 0
        lines = []
        T.require(
            len(program) == m["program_end"] - m["program_start"],
            "Program extent mismatch",
        )
        while cursor < len(program):
            nxt = int.from_bytes(bytes(program[cursor : cursor + 2]), "little")
            if not nxt:
                break
            size = nxt - m["program_start"] - cursor
            T.require(
                size >= 5 and cursor + size <= len(program), "Invalid native line link"
            )
            lines.append(
                {
                    "number": int.from_bytes(
                        bytes(program[cursor + 2 : cursor + 4]), "little"
                    ),
                    "bytes": size,
                }
            )
            cursor += size
        wanted = sorted(int(l.split()[0]) for l in listing(variant).splitlines())
        T.require(
            lines == m["lines"]
            and len(wanted) == len(set(wanted))
            and [l["number"] for l in lines] == wanted,
            "Native line inventory differs",
        )
        T.require(
            len(m["variable_bytes"]) == m["variable_extent"] == word(2) - word(0),
            "Variable allocation differs",
        )
        table = m["variable_bytes"]
        pos = 0
        types = {}
        while pos < len(table):
            kind = table[pos]
            T.require(kind in (2, 3, 4, 8), "Unknown native variable type")
            size = 3 + (3 if kind == 3 else kind)
            T.require(pos + size <= len(table), "Truncated native variable")
            name = "".join(chr(v) for v in table[pos + 1 : pos + 3] if v)
            types[name] = kind
            pos += size
        T.require(
            all(
                types.get(name) == 8
                for name in ("DU", "DC", "DP", "DR", "DA", "DX", "DE")
            ),
            "Helper state is not the qualified double representation",
        )
        T.require(
            m["helper_token_bytes"]
            == sum(l["bytes"] for l in lines if 3000 <= l["number"] <= 3250),
            "Helper allocation mismatch",
        )
        if "boundar" in variant:
            data = c["bytes"]
            good = variant == "boundaries"
            T.require(
                len(data) == 99 and data[0] == 165 and data[-2:] == [90, 239],
                "Incomplete synthetic fixture",
            )
            T.require(
                (data == V.expected_fixture()) == good and c["oracle_matches"] == good,
                "Boundary oracle mismatch",
            )
            continue
        states = c["samples"]
        by = {s["stage"]: s for s in states}
        duration = 120 if variant == "custom" else 240
        T.require(
            [s["stage"] for s in states[:5]]
            == ["initial", "untimed-idle", "untimed-action", "enabled", "idle-progress"]
            and [s["stage"] for s in states[-2:]] == ["disabled", "disabled-idle"],
            "Missing execution stage",
        )
        for state in states:
            b = state["raw"]
            values = b[:3] + [
                int.from_bytes(bytes(b[i : i + 3]), "little") for i in (3, 6, 9, 12)
            ]
            T.require(
                len(b) == 20
                and b[16:18] == [165, 90]
                and b[-1] == 239
                and values
                == [
                    state[k]
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
                and state["duration"] == duration,
                "Native mailbox disagrees",
            )
        T.require(
            by["initial"]["turn"] == by["untimed-idle"]["turn"] == 0
            and by["untimed-idle"]["clock"] != by["initial"]["clock"],
            "Idle changed world or clock stopped",
        )
        T.require(
            by["untimed-action"]["turn"] == 1 and by["untimed-action"]["active"] == 0,
            "Untimed action changed timing",
        )
        a, b = by["enabled"], by["idle-progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turn"] == b["turn"] == 1
            and a["clock"] != b["clock"],
            "No active advancing clock",
        )
        if variant == "wrong":
            e = by["wrong-never-expires"]
            T.require(
                e["turn"] == 1
                and e["expiries"] == 0
                and e["remaining"] == duration
                and e["elapsed"] == 0,
                "Fault did not reproduce",
            )
        else:
            T.require(
                a["remaining"] > b["remaining"] > 0
                and a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 65536,
                "Elapsed countdown mismatch",
            )
            e = by["action-restarts"]
            T.require(
                e["turn"] == 2 and e["remaining"] > b["remaining"], "Restart failed"
            )
            e = states[-3]
            T.require(
                e["turn"] == 3 and e["expiries"] == e["active"] == 1,
                "No automatic turn",
            )
        a, b = states[-2:]
        T.require(
            a["active"] == b["active"] == 0
            and a["turn"] == b["turn"] == (1 if variant == "wrong" else 3)
            and b["frames"] - a["frames"] >= 250,
            "Disable failed",
        )
    T.require(
        r["cases"]["working"]["source_sha256"]
        == r["cases"]["repaired"]["source_sha256"],
        "Repair differs",
    )


if __name__ == "__main__":
    check()
    print("MSX BASIC native evidence passed")
