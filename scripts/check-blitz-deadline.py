"""Recheck retained native Blitz output, modular arithmetic and failure controls."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "commodore-amiga/patterns/blitz/framework/turn-deadline"
spec = importlib.util.spec_from_file_location(
    "native", ROOT / "scripts/verify-blitz-deadline.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)


def require(v: bool, message: str) -> None:
    if not v:
        raise ValueError(message)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def sources() -> dict[str, str]:
    files = (
        sorted(FOLDER.glob("*.bb2"))
        + sorted((FOLDER / "mistakes").glob("*.bb2"))
        + sorted(V.PHASES.glob("*.json"))
        + [
            FOLDER / "build.py",
            FOLDER / "Makefile",
            FOLDER / "verification/configuration.json",
            FOLDER / "../command-loop/routines.bb2",
            ROOT / "scripts/verify-blitz-deadline.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/check-amiga-command-loops.py",
        ]
    )
    return {str(p.relative_to(ROOT)): sha(p) for p in files}


NUMBERS: dict[tuple[str, int, int, int], int] = {}


def number(p: Path, digest: str, x: int, y: int, n: int = 8) -> int:
    require(sha(p) == digest, "Changed native pixels")
    key = (digest, x, y, n)
    if key not in NUMBERS:
        NUMBERS[key] = V.number(p, x, y, n)
    return NUMBERS[key]


def check(record: dict[str, Any] | None = None) -> None:
    out = FOLDER / "verification"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    cfg = V.config()
    require(
        record["machine"] == "commodore-amiga"
        and record["language"] == "blitz"
        and record["toolchain"] == cfg,
        "Wrong machine/language/toolchain",
    )
    require(
        record["status"] == "native-checked"
        and record["configuration"] == cfg["configuration"],
        "Wrong execution/configuration status",
    )
    require(
        json.loads((out / "sources.json").read_text()) == sources(),
        "Changed source/observer binding",
    )
    require(set(record["cases"]) == set(V.B.VARIANTS), "Missing native variant")
    fixture = record["fixture"]
    digest = fixture["disk_sha256"]
    require(
        len(digest) == 64
        and all(c in "0123456789abcdef" for c in digest)
        and fixture["builder_sha256"] == cfg["builder_sha256"],
        "Invalid fixture provenance",
    )
    require(
        fixture["program_sha256"]
        == {v: c["program_sha256"] for v, c in record["cases"].items()},
        "Wrong fixture programs",
    )
    for variant, case in record["cases"].items():
        require(
            case["program_sha256"]
            == hashlib.sha256(V.B.program(variant).encode("ascii")).hexdigest(),
            "Changed imported source",
        )
        size = 272 if variant in {"boundaries", "wrong-boundary"} else 40
        base = case["bank_address"]
        require(
            0 < base < 2 * 1024 * 1024 - size and case["bank_length"] == size,
            "Bad native allocation",
        )
        first = out / case["initial_image"]
        h = case["initial_sha256"]
        require(
            number(first, h, 288, 200) == base
            and number(first, h, 288, 240) == size
            and number(first, h, 192, 280, 10) == 123456789,
            "Native address/allocation/font not visible",
        )
        require(
            sha(out / case["quit_image"]) == case["quit_sha256"],
            "Changed normal-exit capture",
        )
        if size == 272:
            raw = case["raw"]
            require(
                len(raw) == 272
                and raw[264:268] == [26, 43, 60, 77]
                and int.from_bytes(bytes(raw[268:272]), "big") == 239,
                "Incomplete arithmetic results",
            )
            require(number(first, h, 304, 120) == 16, "Missing arithmetic completion")
            inputs = [
                list(map(int, l[7:].split(",")))
                for l in (FOLDER / "boundaries.bb2").read_text().splitlines()
                if l.startswith("Data.l ")
            ]
            require(len(inputs) == 16, "Missing arithmetic cases")
            covered = [((now - prev) % 65536, d) for prev, now, d in inputs]
            require(
                any(prev > now for prev, now, d in inputs)
                and any(d == 0 for e, d in covered)
                and any(d == 65535 for e, d in covered)
                and any(e == 0 for e, d in covered)
                and any(e == 32768 for e, d in covered)
                and any(e > d > 0 for e, d in covered),
                "Missing arithmetic coverage class",
            )
            failures = 0
            for i, (previous, now, duration) in enumerate(inputs):
                elapsed = (now - previous) % 65536
                expired = int(duration > 0 and elapsed >= duration)
                expected = [
                    expired,
                    max(0, duration - elapsed) if duration else 0,
                    elapsed,
                    int(duration > 0 and not expired),
                ]
                actual = [
                    int.from_bytes(bytes(raw[i * 16 + j : i * 16 + j + 4]), "big")
                    for j in [0, 4, 8, 12]
                ]
                if variant == "boundaries":
                    require(
                        actual == expected,
                        "Native arithmetic disagrees with modular oracle",
                    )
                else:
                    strict = int(duration > 0 and elapsed > duration)
                    require(
                        actual
                        == [
                            strict,
                            max(0, duration - elapsed) if duration else 0,
                            elapsed,
                            int(duration > 0 and not strict),
                        ],
                        "Control is not the intended strict-comparison fault",
                    )
                    failures += int(actual != expected)
            if variant == "wrong-boundary":
                require(
                    failures == 3,
                    "Wrong control did not expose three exact-expiry faults",
                )
            continue
        require(
            number(first, h, 304, 120) == 0 and number(first, h, 304, 160) == 0,
            "Caller did not start untimed at zero",
        )
        samples = case["samples"]
        stages = {s["stage"]: s for s in samples}
        required = {
            "initial",
            "idle",
            "action",
            "enabled",
            "progress",
            "disabled",
            "disabled-idle",
        } | ({"wrong-no-expiry"} if variant == "wrong" else {"restart", "expiry"})
        require(
            len(samples) == len(required) and set(stages) == required,
            "Missing/duplicate stage",
        )
        for sample in samples:
            raw = sample["bank"]
            require(
                len(raw) == 40
                and raw[32:36] == [26, 43, 60, 77]
                and int.from_bytes(bytes(raw[36:40]), "big") == 239,
                "Incomplete state snapshot",
            )
            fields = {
                k: int.from_bytes(bytes(raw[i * 4 : i * 4 + 4]), "big")
                for i, k in enumerate(
                    [
                        "turn",
                        "expiries",
                        "active",
                        "remaining",
                        "clock",
                        "duration",
                        "elapsed",
                    ]
                )
            }
            require(
                all(sample[k] == v for k, v in fields.items()),
                "Summary differs from native bank",
            )
            image = out / sample["image"]
            h = sample["image_sha256"]
            require(
                number(image, h, 304, 120) == fields["turn"]
                and number(image, h, 304, 160) == fields["active"],
                "Native screen differs from state",
            )
            require(
                sample["duration"] == (100 if variant == "custom" else 200),
                "Custom duration differs",
            )
        initial, idle, action = (stages[k] for k in ["initial", "idle", "action"])
        require(
            initial["turn"] == idle["turn"] == 0
            and initial["active"] == idle["active"] == action["active"] == 0
            and action["turn"] == 1,
            "Untimed action policy differs",
        )
        for earlier, later in [("initial", "idle"), ("enabled", "progress")]:
            a, b = stages[earlier], stages[later]
            fields = b["frames"] - a["frames"]
            delta = (b["clock"] - a["clock"]) % 65536
            require(
                fields > 0 and abs(delta - fields) <= 1,
                "Native clock does not agree with completed field window",
            )
        enabled, progress = stages["enabled"], stages["progress"]
        require(
            enabled["active"] == 1 and progress["frames"] - enabled["frames"] >= 30,
            "Missing enabled/progression window",
        )
        if variant == "wrong":
            bad = stages["wrong-no-expiry"]
            require(
                (bad["clock"] - enabled["clock"]) % 65536 > 200
                and bad["turn"] == 1
                and bad["expiries"] == 0
                and bad["elapsed"] == 0
                and bad["remaining"] == 200
                and bad["active"] == 1,
                "Missing baseline-reset symptom",
            )
        else:
            require(
                progress["remaining"] < enabled["remaining"],
                "Deadline did not progress",
            )
            restart, expiry = stages["restart"], stages["expiry"]
            require(
                restart["turn"] == 2
                and restart["active"] == 1
                and restart["remaining"] > progress["remaining"],
                "Active action did not restart",
            )
            require(
                expiry["turn"] == 3
                and expiry["expiries"] == 1
                and expiry["active"] == 1
                and 0 < expiry["remaining"] <= expiry["duration"],
                "Automatic turn absent or duplicated",
            )
            require(
                expiry["frames"] - restart["frames"] <= expiry["duration"] + 20,
                "Custom expiry did not shorten observation window",
            )
        stopped, waited = stages["disabled"], stages["disabled-idle"]
        require(
            stopped["active"] == waited["active"] == 0
            and stopped["turn"] == waited["turn"]
            and waited["frames"] - stopped["frames"] >= 250,
            "Disabled deadline advanced",
        )
    exports = json.loads((out / "published.json").read_text())
    require(set(exports) == {"working", "wrong"}, "Missing publication export")
    for variant, stage in [("working", "expiry"), ("wrong", "wrong-no-expiry")]:
        sample = next(
            s for s in record["cases"][variant]["samples"] if s["stage"] == stage
        )
        export = exports[variant]
        require(
            export["source"] == sample["image"]
            and export["source_sha256"] == sample["image_sha256"],
            "Wrong publication state",
        )
        raw, published = out / export["source"], out / export["published"]
        require(
            sha(raw) == export["source_sha256"]
            and sha(published) == export["published_sha256"]
            and published.read_bytes() == V.C.display_png(raw),
            "Publication changed unique pixels",
        )


if __name__ == "__main__":
    check()
    print("Blitz native deadlines, clock/pixels and exact-expiry control passed")
