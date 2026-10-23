"""Check retained native Commodore observations and decode their visible counts."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError("Missing maintained checker dependency")
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


V = module("cbm_deadline", "verify-pet-deadlines.py")
P = module("png_reader", "check-amiga-command-loops.py")
T = V.T
DIGITS = {
    "commodore-64": [
        (60, 102, 110, 118, 102, 102, 60, 0),
        (24, 24, 56, 24, 24, 24, 126, 0),
        (60, 102, 6, 12, 48, 96, 126, 0),
        (60, 102, 6, 28, 6, 102, 60, 0),
    ],
    "commodore-vic-20": [
        (60, 66, 70, 90, 98, 66, 60, 0),
        (8, 24, 40, 8, 8, 8, 62, 0),
        (60, 66, 2, 12, 48, 64, 126, 0),
        (60, 66, 2, 28, 2, 66, 60, 0),
    ],
}

DIGITS["commodore-pet"] = DIGITS["commodore-vic-20"]


def visible(system: str, path: Path) -> tuple[int, int, int]:
    w, h, c, pixels = P.png(path)
    x, y = (32, 24)
    T.require(
        (w, h) == (384, 248),
        "Wrong native geometry",
    )

    def pixel(xx: int, yy: int) -> bytes:
        at = (yy * w + xx) * c
        return bytes(pixels[at : at + 3])

    background = pixel(x, y)
    text = ""
    for col in (0, 1, 2, 3, 5, 6, 8, 9):
        rows = tuple(
            sum(
                int(pixel(x + col * 8 + xx, y + yy) != background) << (7 - xx)
                for xx in range(8)
            )
            for yy in range(8)
        )
        T.require(rows in DIGITS[system], f"Unrecognised native digit: {rows}")
        text += str(DIGITS[system].index(rows))
    return int(text[:4], 16), int(text[4:6], 16), int(text[6:], 16)


def check(system: str, record: dict[str, Any] | None = None) -> None:
    T.require(system in V.SYSTEMS, "Unknown machine")
    folder = ROOT / system / "patterns/assembly/framework/turn-deadline/verification"
    r = (
        record
        if record is not None
        else json.loads((folder / "results.json").read_text())
    )
    cfg = json.loads((folder / "configuration.json").read_text())
    T.require(
        (r["machine"], r["language"], r["status"])
        == (system, "assembly", "native-checked"),
        "Wrong record identity",
    )
    T.require(
        r["sources"]
        == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths(system)},
        "Source binding changed",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing variant")
    T.require(
        r["assembler_sha256"] == cfg["assembler_sha256"]
        and r["assembler_release"] == "0.0.72"
        and r["emulator_release"] == "0.44.2",
        "Wrong released tools",
    )
    T.require(
        cfg["system"] == system
        and cfg["region"] == "emulator default"
        and cfg["ram_bytes"] == 32768,
        "Wrong machine configuration",
    )
    for variant, c in r["cases"].items():
        T.require(
            c["emulator_sha256"] == cfg["emulator_sha256"]
            and c["firmware_sha256"] == cfg["firmware_sha256"]
            and c["server"]["version"] == "0.44.2",
            "Tool or firmware identity changed",
        )
        T.require(
            c["prg_bytes"] > 100
            and c["helper_bytes"] == 140
            and c["adapter_bytes"] == 69
            and len(c["prg_sha256"]) == 64,
            "Missing artifact or cost",
        )
        image = folder / c["image"]
        T.require(
            image.name == variant + ".png" and T.sha(image) == c["image_sha256"],
            "Changed native image",
        )
        if variant in ("boundaries", "wrong-boundary", "wrong-midnight"):
            data = c["fixture"]
            good = variant == "boundaries"
            T.require(len(data) == 142 and data[-1] == 239, "Incomplete fixture")
            T.require(
                (data == V.V.expected_fixture()) == good
                and c["oracle_matches"] == good,
                "Native boundary/control mismatch",
            )
            if variant == "wrong-boundary":
                T.require(
                    data[120:] == V.V.expected_fixture()[120:],
                    "Comparator fault changed unrelated clock or dispatch",
                )
            if variant == "wrong-midnight":
                T.require(
                    data[:120] == V.V.expected_fixture()[:120]
                    and data[132:] == V.V.expected_fixture()[132:],
                    "Clock fault changed unrelated helper or dispatch",
                )
            continue
        wrong = variant == "wrong-input-gate"
        expected = [
            "idle",
            "idle-after",
            "untimed-action",
            "enabled",
            "progress",
            "expiry",
        ] + ([] if wrong else ["restart", "disabled", "disabled-after"])
        T.require(
            [s["stage"] for s in c["observations"]] == expected, "Missing caller stage"
        )
        states = {s["stage"]: s for s in c["observations"]}
        duration = 120 if variant == "custom-duration" else 240
        T.require(
            all(
                s["duration"] == duration and s["guards"] == [165, 90]
                for s in states.values()
            ),
            "Changed duration or guards",
        )
        a, b = states["idle"], states["idle-after"]
        ticks = (b["clock"] - a["clock"]) % 65536
        T.require(
            a["turns"] == b["turns"] == a["active"] == b["active"] == 0
            and b["frames"] - a["frames"] == 30
            and 28 <= ticks <= 38
            and ticks == c["ticks_in_30_fields"],
            "Untimed idle or clock failed",
        )
        a = states["untimed-action"]
        T.require(a["turns"] == 1 and a["active"] == 0, "Untimed action enabled timing")
        a, b = states["enabled"], states["progress"]
        T.require(
            a["active"] == b["active"] == 1
            and a["turns"] == b["turns"] == 1
            and a["remaining"] - b["remaining"] == (b["clock"] - a["clock"]) % 65536
            and a["remaining"] > b["remaining"] > 0,
            "Clock and countdown disagree",
        )
        a = states["expiry"]
        expected_expiry = (1, 0, 0) if wrong else (2, 1, 1)
        T.require(
            (a["turns"], a["expiries"], a["active"]) == expected_expiry,
            "Idle expiry failed",
        )
        T.require(
            visible(system, image) == ((1, 0, 1) if wrong else (2, 1, 1)),
            "Native visible counts disagree",
        )
        if not wrong:
            a = states["restart"]
            T.require(
                a["turns"] == 3 and a["remaining"] > duration // 2,
                "Action did not restart",
            )
            a, b = states["disabled"], states["disabled-after"]
            T.require(
                a["active"] == b["active"] == 0
                and a["turns"] == b["turns"] == 3
                and b["frames"] - a["frames"] == 300,
                "Disabled timer advanced",
            )
    T.require(
        r["cases"]["working"]["prg_sha256"] == r["cases"]["repaired"]["prg_sha256"],
        "Repair does not restore working program",
    )


if __name__ == "__main__":
    for system in V.SYSTEMS:
        check(system)
        print(system, "native deadlines, pixels and controls passed")
