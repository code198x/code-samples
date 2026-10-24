"""Validate native assembly deadline observations and reject incomplete evidence."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(system):
    name = {"dragon-32": "dragon", "jupiter-ace": "ace", "msx": "msx", "sinclair-zx-spectrum": "spectrum"}[system]
    spec = importlib.util.spec_from_file_location(
        "native", ROOT / f"scripts/verify-{name}-assembly-deadlines.py"
    )
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


def check(system="dragon-32", record=None):
    V = load(system)
    T = V.T
    f = V.F / "verification"
    r = record if record is not None else json.loads((f / "results.json").read_text())
    cfg = json.loads((f / "configuration.json").read_text())
    T.require((r["machine"], r["language"]) == (system, "assembly"), "Wrong route")
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Changed source or observer",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native case")
    T.require(
        all(
            r[k] == cfg[k]
            for k in ("emulator_sha256", "assembler_sha256", "firmware_sha256")
        ),
        "Changed producer/firmware identity",
    )
    ace = system == "jupiter-ace"
    spectrum = system == "sinclair-zx-spectrum"
    fifty = ace or spectrum
    z80 = system in ("jupiter-ace", "msx", "sinclair-zx-spectrum")
    offset = 4 if z80 else 16
    endian = "little" if z80 else "big"
    for variant, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong actual emulator version")
        T.require(
            0
            < len(c["loaded_bytes"])
            < (700 if system == "msx" or spectrum else 600 if ace else 512)
            and hashlib.sha256(bytes(c["loaded_bytes"])).hexdigest()
            == c["loaded_sha256"],
            "Loaded payload mismatch",
        )
        T.require(T.sha(f / c["image"]) == c["image_sha256"], "Changed native image")
        if variant == "no-entry":
            T.require(spectrum and c["ready"] == [0, 0] and any("0 OK, 30:1" in line for line in c["screen"]), "Missing loader-entry control")
            continue
        if "boundar" in variant:
            data = c["bytes"]
            good = variant == "boundaries"
            T.require(
                len(data) == len(V.expected_fixture())
                and data[0] == 165
                and data[-2:] == [90, 239],
                "Incomplete fixture",
            )
            T.require(
                (data == V.expected_fixture()) == good and c["oracle_matches"] == good,
                "Wrong unsigned oracle result",
            )
            continue
        states = c["samples"]
        by = {s["stage"]: s for s in states}
        T.require(
            [s["stage"] for s in states[:5]]
            == ["initial", "untimed-idle", "untimed-action", "enabled", "idle-progress"]
            and [s["stage"] for s in states[-2:]] == ["disabled", "disabled-idle"],
            "Missing stage",
        )
        for s in states:
            raw = s["raw"]
            T.require(
                len(raw) == (14 if z80 else 28)
                and [
                    raw[0],
                    raw[1],
                    raw[offset + 4],
                    int.from_bytes(bytes(raw[offset + 2 : offset + 4]), endian),
                    int.from_bytes(bytes(raw[offset + 8 : offset + 10]), endian),
                ]
                == [s[k] for k in ("turn", "expiries", "active", "remaining", "clock")],
                "Native state disagrees",
            )
            T.require(
                int.from_bytes(bytes(raw[offset : offset + 2]), endian)
                == (
                    (100 if variant == "custom" else 200)
                    if fifty
                    else (120 if variant == "custom" else 240)
                ),
                "Wrong configured duration",
            )
        a, b = by["initial"], by["untimed-idle"]
        T.require(
            a["turn"] == b["turn"] == a["active"] == b["active"] == 0
            and b["clock"] != a["clock"],
            "Untimed idle failed",
        )
        a = by["untimed-action"]
        T.require(a["turn"] == 1 and a["active"] == 0, "Untimed action enabled time")
        a, b = by["enabled"], by["idle-progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turn"] == b["turn"] == 1
            and a["clock"] != b["clock"],
            "No advancing timer",
        )
        if variant == "wrong":
            e = by["wrong-never-expires"]
            T.require(
                e["turn"] == 1
                and e["expiries"] == 0
                and e["remaining"] == (200 if fifty else 240),
                "No baseline-reset symptom",
            )
        else:
            T.require(
                a["remaining"] > b["remaining"] > 0
                and a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 65536,
                "Elapsed countdown differs",
            )
            e = by["action-restarts"]
            T.require(
                e["turn"] == 2 and e["active"] == 1 and e["remaining"] > b["remaining"],
                "No restart",
            )
            e = states[-3]
            T.require(
                e["turn"] == 3 and e["expiries"] == e["active"] == 1,
                "No automatic expiry",
            )
        a, b = states[-2:]
        T.require(
            a["active"] == b["active"] == 0
            and a["turn"] == b["turn"]
            and b["frames"] - a["frames"] >= 250,
            "Disable failed",
        )
        text = "".join(
            chr(v & 127)
            if z80
            else chr((v & 63) + 64)
            if (v & 63) < 32
            else chr(v & 63)
            for v in c["return_screen"]
        )
        import re

        T.require(
            re.search(r"RETURNED\s*5", text, re.IGNORECASE),
            "No interpreter arithmetic after return",
        )
    T.require(
        r["cases"]["working"]["loaded_bytes"] == r["cases"]["repaired"]["loaded_bytes"],
        "Repair differs from normal",
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "--system", default="dragon-32", choices=("dragon-32", "jupiter-ace", "msx", "sinclair-zx-spectrum")
    )
    a = p.parse_args()
    check(a.system)
    print(a.system, "assembly native evidence passed")
