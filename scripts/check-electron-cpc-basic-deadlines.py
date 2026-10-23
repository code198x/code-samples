"""Check retained typed BASIC execution and reject inconsistent observations."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from functools import cache
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "native_deadlines", ROOT / "scripts/verify-electron-cpc-basic-deadlines.py"
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


@cache
def capture(path: Path, digest: str) -> None:
    T.require(T.sha(path) == digest, "Changed native capture")
    width, height, _, _ = P.png(path)
    T.require(
        (width, height) in [(640, 256), (832, 288)], "Wrong named capture dimensions"
    )


def check(system: str, record: dict[str, Any] | None = None) -> None:
    T.require(system in V.SYSTEMS, "Wrong system")
    p = V.folder(system) / "verification"
    r = record if record is not None else json.loads((p / "results.json").read_text())
    cfg = json.loads((p / "configuration.json").read_text())
    T.require(
        (r["status"], r["system"], r["language"])
        == ("native-checked", system, "basic"),
        "Wrong identity/status",
    )
    T.require(
        r["sources"]
        == {str(f.relative_to(ROOT)): T.sha(f) for f in V.source_paths(system)},
        "Changed source/observer bindings",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native cases")
    for variant, c in r["cases"].items():
        T.require(
            c["emulator_sha256"] == cfg["emulator_sha256"]
            and c["firmware_sha256"] == cfg["firmware_sha256"]
            and c["server"]["version"] == "0.44.1",
            "Different native configuration",
        )
        source = V.listing(system, variant)
        T.require(
            c["listing_sha256"] == hashlib.sha256(source.encode()).hexdigest(),
            "Changed entered listing",
        )
        if variant in ("boundaries", "wrong-boundary"):
            expected = []
            cases = [
                list(map(int, l.split(" DATA ")[1].split(",")))
                for l in source.splitlines()
                if " DATA " in l
            ]
            T.require(c["cases"] == cases and len(cases) == 12, "Wrong boundary cases")
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
            raw = c["raw"]
            good = variant == "boundaries"
            T.require(
                len(raw) == 102 and raw[100:] == [165, 90],
                "Incomplete arithmetic caller",
            )
            T.require(
                (raw[:96] == expected) == good and c["oracle_matches"] == good,
                "Arithmetic oracle/control mismatch",
            )
            expected_images = {variant + ".png"}
        else:
            samples = c["samples"]
            names = [s["stage"] for s in samples]
            fixed = [
                "initial",
                "untimed-idle",
                "untimed-action",
                "enabled",
                "idle-progress",
            ]
            if variant == "wrong":
                fixed += ["wrong-never-expires"]
            else:
                fixed += ["action-restarts"] + ["await-expiry"] * (len(samples) - 8)
            fixed += ["disabled", "disabled-idle"]
            T.require(
                len(samples) >= 8 and names == fixed, "Incomplete native sequence"
            )
            by = {s["stage"]: s for s in samples}
            for s in samples:
                raw = s["raw"]
                T.require(
                    len(raw) == 20 and raw[16:18] == [165, 90] and raw[19] == 239,
                    "Damaged native mailbox",
                )
                decoded = {
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
                T.require(
                    all(s[k] == v for k, v in decoded.items()),
                    "Native bytes disagree with decoded state",
                )
            first, idle = by["initial"], by["untimed-idle"]
            T.require(
                first["turn"] == idle["turn"] == first["active"] == idle["active"] == 0,
                "Untimed idle advanced",
            )
            ticks = (idle["clock"] - first["clock"]) % 65536
            expected_ticks = (idle["frames"] - first["frames"]) * (
                2 if system == "acorn-electron" else 6
            )
            T.require(
                abs(ticks - expected_ticks)
                <= 2 * max(first["elapsed"], idle["elapsed"]) + 6,
                "Wrong native clock units",
            )
            action = by["untimed-action"]
            T.require(
                action["turn"] == 1 and action["active"] == 0,
                "Untimed action enabled clock",
            )
            enabled, progress = by["enabled"], by["idle-progress"]
            duration = (200 if variant == "custom" else 400) * (
                1 if system == "acorn-electron" else 3
            )
            T.require(all(s["duration"] == duration for s in samples), "Wrong duration")
            T.require(
                enabled["active"] == 1
                and enabled["expiries"] == 0
                and progress["clock"] != enabled["clock"],
                "Enabled timer/clock wrong",
            )
            if variant == "wrong":
                end = by["wrong-never-expires"]
                T.require(
                    end["turn"] == 1
                    and end["expiries"] == 0
                    and end["remaining"] == end["duration"]
                    and end["elapsed"] == 0,
                    "Baseline-reset fault absent",
                )
            else:
                T.require(
                    progress["remaining"] < enabled["remaining"],
                    "Countdown did not progress",
                )
                restart = by["action-restarts"]
                T.require(
                    restart["turn"] == 2
                    and restart["active"] == 1
                    and restart["remaining"] > progress["remaining"],
                    "Action restart absent",
                )
                end = by["await-expiry"]
                T.require(
                    (end["turn"], end["expiries"], end["active"]) == (3, 1, 1),
                    "No-input expiry missing",
                )
            disabled, stopped = by["disabled"], by["disabled-idle"]
            T.require(
                disabled["active"] == stopped["active"] == 0
                and disabled["turn"] == stopped["turn"],
                "Disabled game advanced",
            )
            memory = c["memory"]
            raw = memory["program_bytes"]
            cursor = 0
            lines = []
            while cursor < len(raw):
                if system == "acorn-electron":
                    if raw[cursor : cursor + 2] == [13, 255]:
                        break
                    T.require(
                        raw[cursor] == 13 and cursor + 4 <= len(raw),
                        "Bad BBC BASIC line",
                    )
                    size = raw[cursor + 3]
                    number = raw[cursor + 1] * 256 + raw[cursor + 2]
                else:
                    size = raw[cursor] + 256 * raw[cursor + 1]
                    if size == 0:
                        break
                    number = raw[cursor + 2] + 256 * raw[cursor + 3]
                T.require(5 <= size <= len(raw) - cursor, "Bad tokenised line extent")
                lines.append({"number": number, "bytes": size})
                cursor += size
            T.require(
                cursor + 2 == len(raw) and lines == memory["lines"],
                "Incomplete tokenised program",
            )
            T.require(
                [l["number"] for l in lines]
                == sorted(int(l.split()[0]) for l in source.splitlines()),
                "Wrong native line inventory",
            )
            T.require(
                memory["program_end"] - memory["program_start"] == len(raw)
                and memory["helper_token_bytes"]
                == sum(l["bytes"] for l in lines if 3000 <= l["number"] <= 3250)
                > 0,
                "Wrong native memory cost",
            )
            expected_images = {variant + "-expiry.png"}
        T.require(set(c["images"]) == expected_images, "Missing native capture")
        for name, digest in c["images"].items():
            path = p / name
            capture(path, digest)
            T.require(
                path.parent == p
                and path.read_bytes().startswith(b"\x89PNG\r\n\x1a\n")
                and T.sha(path) == digest,
                "Changed native capture",
            )


if __name__ == "__main__":
    for system in V.SYSTEMS:
        check(system)
        print(system, "retained native BASIC deadlines passed")
