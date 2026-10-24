"""Recheck Atari BASIC native program, allocation, policies, pixels and return."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


V = module("native", "verify-atari-xl-basic-deadlines.py")
T = V.T
F = V.F
P = module("png", "check-amiga-command-loops.py")


def pixels(case: dict[str, Any], text: str) -> None:
    cap = case["capture"]
    codes = [ord(c) - 32 for c in text]
    T.require(
        cap["text"] == text and cap["codes"] == codes and cap["font_base"] == 57344,
        "Wrong native screen/font",
    )
    T.require(
        set(cap["glyphs"]) == {str(c) for c in codes}
        and all(len(g) == 8 for g in cap["glyphs"].values()),
        "Missing native glyph",
    )
    w, h, channels, rgba = P.png(F / "verification" / case["image"])
    T.require((w, h, channels) == (376, 240, 4), "Wrong capture geometry")
    x0, y0 = 28, 24
    pos = (y0 * w + x0 + 16) * channels
    paper = tuple(rgba[pos : pos + 3])
    for y in range(8):
        for x in range(64):
            wanted = bool(cap["glyphs"][str(codes[x // 8])][y] & (128 >> (x % 8)))
            pos = ((y0 + y) * w + x0 + x) * channels
            rgb = tuple(rgba[pos : pos + 3])
            actual = rgb != paper
            T.require(
                wanted == actual and rgba[pos + 3] == 255,
                "PNG differs from native glyphs",
            )


def check(record: dict[str, Any] | None = None) -> None:
    r = (
        record
        if record is not None
        else json.loads((F / "verification/results.json").read_text())
    )
    cfg = json.loads((F / "verification/configuration.json").read_text())
    T.require((r["machine"], r["language"]) == ("atari-800xl", "basic"), "Wrong route")
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing caller")
    T.require(
        all(r[k] == cfg[k] for k in ["emulator_sha256", "firmware_sha256"])
        and cfg["mailbox"] == 32768
        and cfg["ramtop_page"] == 124,
        "Wrong configuration",
    )
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong emulator")
        text = V.listing(variant)
        T.require(
            c["source_sha256"] == hashlib.sha256(text.encode()).hexdigest(),
            "Changed selected listing",
        )
        T.require(
            T.sha(F / "verification" / c["image"]) == c["image_sha256"],
            "Changed capture",
        )
        for layout in [c["before"], c["layout"]]:
            ptr = layout["pointers"]
            word = lambda i, values=ptr: int.from_bytes(
                bytes(values[i : i + 2]), "little"
            )
            nt, ne, vt, st, ar = [word(i) for i in [2, 4, 6, 8, 12]]
            T.require(0 < nt < ne <= vt < st < ar < 31744, "Workspace overrun")
            program = layout["program_bytes"]
            T.require(ar - st - len(program) in (3, 6), "Immediate-mode extent differs")
            lines = []
            i = 0
            while i < len(program):
                T.require(i + 3 < len(program), "Truncated line")
                n = int.from_bytes(bytes(program[i : i + 2]), "little")
                size = program[i + 2]
                T.require(size >= 4 and i + size <= len(program), "Bad native line")
                lines.append({"number": n, "bytes": size})
                i += size
            T.require(
                lines == layout["lines"]
                and [l["number"] for l in lines]
                == [int(l.split()[0]) for l in text.splitlines()],
                "Native lines differ",
            )
            T.require(
                layout["helper_token_bytes"]
                == sum(l["bytes"] for l in lines if 3000 <= l["number"] <= 3250),
                "Helper allocation differs",
            )
            names = []
            name = ""
            for b in layout["name_bytes"]:
                if b == 0:
                    break
                name += chr(b & 127)
                if b & 128:
                    names.append(name)
                    name = ""
            values = layout["value_bytes"]
            T.require(
                names == layout["names"]
                and len(layout["name_bytes"]) == ne - nt
                and len(values) == st - vt == 8 * len(names),
                "Name/value storage differs",
            )
            for index, name in enumerate(names):
                T.require(
                    values[index * 8 : index * 8 + 2] == [0, index],
                    "Not the qualified scalar representation",
                )
            T.require(
                {"DU", "DC", "DP", "DR", "DA", "DX", "DE"} <= set(names),
                "Missing helper variable",
            )
        T.require(
            c["before"]["program_bytes"] == c["layout"]["program_bytes"],
            "Program changed during execution",
        )
        layout = c["layout"]
        base = int.from_bytes(bytes(layout["savmsc"]), "little")
        T.require(
            layout["ramtop"] == [124]
            and int.from_bytes(bytes(layout["memtop"]), "little") < base
            and base + 960 <= 31744,
            "Reservation failed",
        )
        ret = c["return_screen"]
        native = "".join(
            chr((b & 127) + 32) if (b & 127) < 64 else " " for b in ret["bytes"]
        )
        T.require(
            native == ret["text"] and "RETURNED5" in native.replace(" ", ""),
            "Return arithmetic absent",
        )
        if "boundar" in variant:
            data = c["bytes"]
            T.require(
                len(data) == 105 and data[0] == 165 and data[-2:] == [90, 239],
                "Fixture incomplete",
            )
            T.require(
                (data == V.A.expected_fixture()) == (variant == "boundaries")
                and c["oracle_matches"] == (variant == "boundaries"),
                "Boundary oracle failed",
            )
            continue
        states = c["samples"]
        by = {s["stage"]: s for s in states}
        duration = 120 if variant == "custom" else 240
        T.require(
            [s["stage"] for s in states[:5]]
            == ["initial", "untimed-idle", "untimed-action", "enabled", "idle-progress"]
            and [s["stage"] for s in states[-2:]] == ["disabled", "disabled-idle"],
            "Missing stage",
        )
        for state in states:
            b = state["raw"]
            decoded = b[:4] + [
                int.from_bytes(bytes(b[i : i + 2]), "little") for i in [4, 6, 8, 10, 12]
            ]
            T.require(
                len(b) == 19
                and b[16:19] == [165, 90, 202]
                and decoded
                == [
                    state[k]
                    for k in [
                        "turn",
                        "expiries",
                        "active",
                        "event",
                        "remaining",
                        "clock",
                        "previous",
                        "elapsed",
                        "duration",
                    ]
                ]
                and state["duration"] == duration,
                "Mailbox interpretation differs",
            )
        T.require(
            by["initial"]["turn"] == by["untimed-idle"]["turn"] == 0
            and by["initial"]["clock"] != by["untimed-idle"]["clock"],
            "Untimed idle",
        )
        T.require(
            by["untimed-action"]["turn"] == 1 and not by["untimed-action"]["active"],
            "Held/untimed action",
        )
        a, b = by["enabled"], by["idle-progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turn"] == b["turn"] == 1
            and a["clock"] != b["clock"],
            "Enabled clock",
        )
        if variant == "wrong":
            e = by["wrong-never-expires"]
            T.require(
                e["turn"] == 1
                and e["expiries"] == 0
                and e["remaining"] == duration
                and e["elapsed"] == 0,
                "No fault symptom",
            )
        else:
            T.require(
                0 < b["remaining"] < a["remaining"]
                and a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 65536,
                "Elapsed countdown differs",
            )
            restart = by["action-restarts"]
            T.require(restart["turn"] == 2 and restart["active"] == 1, "Action restart")
            e = states[-3]
            T.require(e["turn"] == 3 and e["expiries"] == e["active"] == 1, "No expiry")
        pixels(c, f"{e['turn']:02X} {e['expiries']:02X} {e['active']:02X}")
        a, b = states[-2:]
        T.require(
            a["active"] == b["active"] == 0
            and a["turn"] == b["turn"] == e["turn"]
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
    print("Atari BASIC native evidence passed")
