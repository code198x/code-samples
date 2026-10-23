"""Validate retained native MOS observations, not a fresh emulator run."""

from __future__ import annotations

import importlib.util
import json
from functools import cache
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "mos_deadlines", ROOT / "scripts/verify-mos-deadlines.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native observer")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T = V.T


png_spec = importlib.util.spec_from_file_location(
    "native_png", ROOT / "scripts/check-amiga-command-loops.py"
)
if png_spec is None or png_spec.loader is None:
    raise RuntimeError("Missing native PNG reader")
P = importlib.util.module_from_spec(png_spec)
png_spec.loader.exec_module(P)
DIGITS = {
    (60, 102, 110, 126, 118, 102, 60, 0): "0",
    (24, 56, 24, 24, 24, 24, 126, 0): "1",
    (60, 102, 6, 12, 24, 48, 126, 0): "2",
    (60, 102, 6, 28, 6, 102, 60, 0): "3",
    (12, 28, 60, 108, 126, 12, 12, 0): "4",
}


@cache
def visible(path: Path, digest: str) -> tuple[int, int, int]:
    T.require(T.sha(path) == digest, "Changed native image")
    w, h, c, pixels = P.png(path)
    T.require((w, h) in [(640, 512), (640, 256)], "Wrong MODE 6 capture geometry")
    text = ""
    for gx in [0, 16, 32, 48, 80, 96, 128, 144]:
        rows = []
        for y in range(8):
            row = 0
            for x in range(8):
                at = ((20 * (h // 256) + y * (h // 256)) * w + gx + x * 2) * c
                row = (row << 1) | int(any(pixels[at : at + 3]))
            rows.append(row)
        T.require(tuple(rows) in DIGITS, f"Unknown native glyph {rows}")
        text += DIGITS[tuple(rows)]
    return int(text[:4], 16), int(text[4:6], 16), int(text[6:], 16)


def check(system: str, record: dict[str, Any] | None = None) -> None:
    T.require(system in V.SYSTEMS, "Wrong machine")
    folder = ROOT / system / "patterns/assembly/framework/turn-deadline/verification"
    r = (
        record
        if record is not None
        else json.loads((folder / "results.json").read_text())
    )
    T.require(
        (r["status"], r["machine"], r["language"])
        == ("native-checked", system, "assembly"),
        "Wrong status/machine/language",
    )
    T.require(
        r["sources"] == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths()},
        "Source/observer binding changed",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native variant")
    T.require(len(r["assembler_sha256"]) == 64, "Missing assembler identity")
    # Tool/firmware identities are bound in the checked-in configuration, not inferred from a filename.
    cfg = json.loads((folder / "configuration.json").read_text())
    T.require(
        cfg["system"] == system
        and cfg["region"] == "PAL"
        and cfg["ram_bytes"] == 32768,
        "Wrong configuration",
    )
    T.require(r["assembler_sha256"] == cfg["assembler_sha256"], "Assembler changed")
    for variant, c in r["cases"].items():
        T.require(
            c["emulator_sha256"] == cfg["emulator_sha256"]
            and c["firmware_sha256"] == cfg["firmware_sha256"],
            "Tool/firmware changed",
        )
        T.require(c["server"]["version"] == "0.44.1", "Wrong native release")
        T.require(
            c["binary_bytes"] > 0
            and c["helper_bytes"] > 0
            and len(c["binary_sha256"]) == len(c["loader_sha256"]) == 64,
            "Missing built artifact",
        )
        if variant in ("boundaries", "wrong-boundary"):
            data = c["bytes"]
            good = variant == "boundaries"
            T.require(
                len(data) == 121 and data[-1] == 239, "Arithmetic caller incomplete"
            )
            T.require(
                (data == V.V.expected_arithmetic()) == good
                and c["oracle_matches"] == good,
                "Arithmetic oracle/control mismatch",
            )
            images = [(c["image"], c["image_sha256"])]
        else:
            expected = [
                "idle",
                "idle-after",
                "untimed-action",
                "enabled",
                "progress",
                "expiry",
            ]
            wrong = variant == "wrong-input-gate"
            if not wrong:
                expected += [
                    "restart",
                    "held-start",
                    "held-after",
                    "disabled",
                    "disabled-after",
                ]
            T.require(
                [s["stage"] for s in c["samples"]] == expected,
                "Missing/reordered caller observations",
            )
            states = {s["stage"]: s for s in c["samples"]}
            duration = 200 if variant == "custom-duration" else 400
            T.require(
                all(
                    s["duration"] == duration and s["guards"] == [165, 90]
                    for s in states.values()
                ),
                "Duration/guard changed",
            )
            a, b = states["idle"], states["idle-after"]
            T.require(
                a["turns"] == b["turns"] == a["active"] == b["active"] == 0,
                "Untimed idle advanced",
            )
            ticks = (b["clock"] - a["clock"]) % 65536
            T.require(
                b["frames"] - a["frames"] == 30
                and ticks == c["ticks_in_30_fields"]
                and 58 <= ticks <= 62,
                "Clock rate changed",
            )
            a = states["untimed-action"]
            T.require(
                a["turns"] == 1 and a["active"] == 0, "Untimed action enabled clock"
            )
            a, b = states["enabled"], states["progress"]
            T.require(
                a["active"] == b["active"] == 1 and a["turns"] == b["turns"] == 1,
                "No enabled timer",
            )
            T.require(
                0
                < a["remaining"] - b["remaining"]
                == (b["clock"] - a["clock"]) % 65536,
                "Clock/countdown disagree",
            )
            e = states["expiry"]
            T.require(
                (e["turns"], e["expiries"], e["active"])
                == ((1, 0, 0) if wrong else (2, 1, 1)),
                "Expiry policy mismatch",
            )
            if wrong:
                T.require(e["remaining"] == 0, "Fault did not lose a completed expiry")
            else:
                a = states["restart"]
                T.require(
                    a["turns"] == 3 and a["remaining"] > duration // 2,
                    "Action did not restart",
                )
                a, b = states["held-start"], states["held-after"]
                T.require(
                    a["turns"] == b["turns"] == 4 and a["held"] == b["held"] == 1,
                    "Held action repeated",
                )
                a, b = states["disabled"], states["disabled-after"]
                T.require(
                    a["active"] == b["active"] == 0
                    and a["remaining"] == b["remaining"] == 0
                    and a["turns"] == b["turns"] == 4,
                    "Disabled clock advanced game",
                )
            images = [(s["image"], s["image_sha256"]) for s in c["samples"]]
            for sample in c["samples"]:
                T.require(
                    visible(folder / sample["image"], sample["image_sha256"])
                    == (
                        sample["turns"],
                        sample["expiries"],
                        1
                        if wrong and sample["stage"] == "expiry"
                        else sample["active"],
                    ),
                    "Native pixels disagree with observed state",
                )
        for name, digest in images:
            path = folder / name
            T.require(
                path.parent == folder
                and path.suffix == ".png"
                and path.read_bytes().startswith(b"\x89PNG\r\n\x1a\n")
                and T.sha(path) == digest,
                "Changed or missing native capture",
            )


if __name__ == "__main__":
    for system in V.SYSTEMS:
        check(system)
        print(system, "retained MOS deadline observations passed")
