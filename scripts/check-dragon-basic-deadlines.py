"""Check retained Dragon BASIC execution, native lines and countdown invariants."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "native", ROOT / "scripts/verify-dragon-basic-deadlines.py"
)
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T
F = V.folder("dragon-32")


def listing(variant):
    shared = ROOT / "commodore-64/patterns/basic/framework/turn-deadline"
    if "boundar" in variant:
        return V.fixture_listing("dragon-32", variant == "wrong-boundary")
    parts = [
        F / ("customise.bas" if variant == "custom" else "caller.bas"),
        shared / "../command-loop/routines.bas",
        F / "routines.bas",
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
        == ("dragon-32", "basic", "native-checked"),
        "Wrong route",
    )
    T.require(
        r["sources"]
        == {
            str(p.resolve().relative_to(ROOT)): T.sha(p)
            for p in V.source_paths("dragon-32")
        },
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing caller")
    T.require(
        r["emulator_sha256"] == cfg["emulator_sha256"]
        and r["firmware_sha256"] == cfg["firmware_sha256"]
        and cfg["ram_bytes"] == 32768
        and cfg["mailbox"] == 28672,
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
        raw = m["workspace_bytes"]
        word = lambda i, values=raw: int.from_bytes(bytes(values[i : i + 2]), "big")
        T.require(
            [word(i) for i in (0, 2, 6, 14)]
            == [
                m[k]
                for k in ("program_start", "program_end", "arrays_end", "memory_limit")
            ],
            "Wrong workspace interpretation",
        )
        T.require(
            m["program_start"] == 0x1E01
            and m["program_start"]
            < m["program_end"]
            <= m["arrays_end"]
            < m["memory_limit"]
            < 0x7000,
            "Native memory reservation exceeded",
        )
        program = m["program_bytes"]
        cursor = 0
        lines = []
        T.require(
            len(program) == m["program_end"] - m["program_start"],
            "Program extent mismatch",
        )
        while cursor < len(program):
            nxt = int.from_bytes(bytes(program[cursor : cursor + 2]), "big")
            if not nxt:
                break
            size = nxt - m["program_start"] - cursor
            T.require(
                size >= 5 and cursor + size <= len(program), "Invalid native line link"
            )
            lines.append(
                {
                    "number": int.from_bytes(
                        bytes(program[cursor + 2 : cursor + 4]), "big"
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
            len(m["variable_bytes"]) == m["variable_extent"] == word(4) - word(2)
            and m["variable_extent"] % 7 == 0,
            "Variable allocation mismatch",
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
    print("Dragon BASIC native evidence passed")
