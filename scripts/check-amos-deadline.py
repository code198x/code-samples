"""Validate retained AMOS execution and pixel/state agreement, not fresh emulation."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "commodore-amiga/patterns/amos/framework/turn-deadline"


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


V = load("verifier", ROOT / "scripts/verify-amos-deadline.py")
C = V.C


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sources() -> dict[str, str]:
    files = (
        sorted(FOLDER.glob("*.amos"))
        + sorted((FOLDER / "mistakes").glob("*.amos"))
        + [
            FOLDER / "Makefile",
            FOLDER / "build.py",
            FOLDER / "verification/configuration.json",
            ROOT / "scripts/verify-amos-deadline.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/check-amiga-command-loops.py",
            FOLDER / "../command-loop/routines.amos",
        ]
        + sorted(V.PHASES.glob("*.json"))
    )
    return {str(p.relative_to(ROOT)): sha(p) for p in files}


COUNTERS: dict[str, int] = {}
NUMBERS: dict[tuple[str, int, int, int], int] = {}


def counter(path: Path, digest: str) -> int:
    require(sha(path) == digest, "Counter image changed before decoding")
    if digest not in COUNTERS:
        COUNTERS[digest] = C.counter(path, "amos", 0)
    return COUNTERS[digest]


def number(path: Path, digest: str, x: int, y: int, digits: int = 8) -> int:
    require(sha(path) == digest, "Numeric image changed before decoding")
    key = (digest, x, y, digits)
    if key not in NUMBERS:
        NUMBERS[key] = V.number(path, x, y, digits)
    return NUMBERS[key]


def check(record: dict[str, Any] | None = None) -> None:
    out = FOLDER / "verification"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    require(
        record["status"] == "native-checked"
        and record["machine"] == "commodore-amiga"
        and record["language"] == "amos",
        "Wrong machine/language/status",
    )
    require(
        record["configuration"] == "PAL A1200, 2 MiB chip, no fast RAM",
        "Wrong named configuration",
    )
    baseline = json.loads((FOLDER / "verification/configuration.json").read_text())
    require(
        record["emulator_sha256"] == baseline["emulator_sha256"]
        and record["firmware_sha256"] == baseline["firmware_sha256"]
        and record["runtime_media_sha256"] == baseline["runtime_media_sha256"],
        "Wrong tool/firmware/runtime identity",
    )
    require(
        json.loads((out / "sources.json").read_text()) == sources(),
        "Changed source/observer binding",
    )
    require(set(record["cases"]) == set(V.VARIANTS), "Missing native variant")
    fixture = record["fixture"]
    require(
        len(fixture["fixture_sha256"]) == 64
        and fixture["builder_sha256"] == baseline["builder_sha256"]
        and fixture["program_sha256"]
        == {
            variant: case["program_sha256"] for variant, case in record["cases"].items()
        },
        "Missing or inconsistent native fixture provenance",
    )
    for variant, case in record["cases"].items():
        require(
            case["program_sha256"]
            == hashlib.sha256(V.B.program(variant).encode("ascii")).hexdigest(),
            "Changed imported program",
        )
        require(
            0 < case["bank_address"] < 2 * 1024 * 1024 - 160, "Invalid bank address"
        )
        if variant in {"boundaries", "wrong-boundary"}:
            raw = case["raw"]
            require(
                len(raw) == case["bank_length"] == 160
                and raw[156:158] == [165, 90]
                and raw[159] == 239,
                "Incomplete arithmetic observer",
            )
            image = out / case["image"]
            require(sha(image) == case["image_sha256"], "Changed boundary capture")
            require(
                number(image, case["image_sha256"], 388, 98) == case["bank_address"]
                and number(image, case["image_sha256"], 388, 66, 3) == 16
                and number(image, case["image_sha256"], 388, 114) == 160,
                "Arithmetic completion/allocation not visible",
            )
            rows = case["cases"]
            require(len(rows) == 16, "Missing arithmetic cases")
            inputs = [
                list(map(int, line[5:].split(",")))
                for line in (FOLDER / "boundaries.amos").read_text().splitlines()
                if line.startswith("Data ")
            ]
            elapsed_inputs = [
                ((now - previous) % 65536, duration)
                for previous, now, duration in inputs
            ]
            require(
                any(previous > now for previous, now, _ in inputs)
                and any(duration == 65535 for _, duration in elapsed_inputs)
                and any(duration == 0 for _, duration in elapsed_inputs)
                and any(elapsed == 0 for elapsed, _ in elapsed_inputs)
                and any(
                    elapsed == duration and duration > 0
                    for elapsed, duration in elapsed_inputs
                )
                and any(elapsed > duration > 0 for elapsed, duration in elapsed_inputs)
                and any(elapsed == 32768 for elapsed, _ in elapsed_inputs),
                "Missing arithmetic coverage class",
            )
            matches = []
            for index, ((previous, now, duration), row) in enumerate(
                zip(inputs, rows, strict=True)
            ):
                require(
                    [row[k] for k in ["previous", "now", "duration"]]
                    == [previous, now, duration]
                    and row["index"] == index,
                    "Wrong boundary inputs/order",
                )
                elapsed = (now - previous) % 65536
                expired = int(duration > 0 and elapsed >= duration)
                expected = [
                    expired,
                    max(0, duration - elapsed) if duration else 0,
                    elapsed,
                    int(duration > 0 and not expired),
                ]
                actual = [
                    int.from_bytes(bytes(raw[index * 8 + j : index * 8 + j + 2]), "big")
                    for j in [0, 2, 4, 6]
                ]
                require(
                    actual == row["actual"] and expected == row["expected"],
                    "Arithmetic summaries disagree with bank/oracle",
                )
                if variant == "wrong-boundary":
                    fault_expired = int(duration > 0 and elapsed > duration)
                    fault_expected = [
                        fault_expired,
                        max(0, duration - elapsed) if duration else 0,
                        elapsed,
                        int(duration > 0 and not fault_expired),
                    ]
                    require(
                        actual == fault_expected,
                        "Wrong control did not exhibit the strict-comparison fault",
                    )
                agrees = actual == expected
                require(
                    row["oracle_matches"] == agrees, "False arithmetic oracle result"
                )
                matches.append(agrees)
            require(
                all(matches) if variant == "boundaries" else not all(matches),
                "Exact-boundary fault did not distinguish implementation",
            )
            continue
        samples = case["samples"]
        stages = {s["stage"]: s for s in samples}
        expected_stages = {
            "initial",
            "idle",
            "action",
            "enabled",
            "progress",
            "disabled",
            "disabled-idle",
        } | ({"wrong-no-expiry"} if variant == "wrong" else {"restart", "waiting"})
        require(set(stages) == expected_stages, "Missing or unexpected native stage")
        for state in samples:
            raw = state["bank"]
            require(
                len(raw) == 32 and raw[28:30] == [165, 90] and raw[31] == 239,
                "Damaged or incomplete bank snapshot",
            )
            decoded = {
                key: int.from_bytes(bytes(raw[offset : offset + 2]), "big")
                for key, offset in [
                    ("turn", 0),
                    ("expiries", 2),
                    ("active", 4),
                    ("remaining", 6),
                    ("clock", 8),
                    ("duration", 10),
                    ("elapsed", 12),
                ]
            }
            require(
                all(state[key] == value for key, value in decoded.items()),
                "Summary disagrees with native bank",
            )
            image = out / state["image"]
            require(
                sha(image) == state["image_sha256"]
                and counter(image, state["image_sha256"]) == state["turn"],
                "Changed capture or native counter mismatch",
            )
            require(
                state["duration"] == (100 if variant == "custom" else 200),
                "Wrong custom duration",
            )
        first, idle, action = (stages[k] for k in ["initial", "idle", "action"])
        require(
            first["turn"] == idle["turn"] == 0
            and first["active"] == idle["active"] == 0
            and action["turn"] == 1
            and action["active"] == 0,
            "Untimed/held action changed policy",
        )
        observed = (idle["clock"] - first["clock"]) % 65536
        fields = idle["frames"] - first["frames"]
        require(
            fields >= 120 and abs(observed - fields) <= 1,
            "Native Timer rate disagrees with field window",
        )
        enabled, progress = stages["enabled"], stages["progress"]
        delta = (progress["clock"] - enabled["clock"]) % 65536
        window = progress["frames"] - enabled["frames"]
        require(
            enabled["active"] == 1 and window >= 30 and abs(delta - window) <= 1,
            "Enabled clock progression disagrees with native field window",
        )
        if variant == "wrong":
            bad = stages["wrong-no-expiry"]
            require(
                (bad["clock"] - enabled["clock"]) % 65536 > 200
                and bad["turn"] == 1
                and bad["expiries"] == 0
                and bad["remaining"] == 200
                and bad["elapsed"] == 0
                and bad["active"] == 1,
                "Baseline-reset symptom absent",
            )
        else:
            require(
                progress["remaining"] < enabled["remaining"],
                "Deadline did not progress without input",
            )
            restart = stages["restart"]
            require(
                restart["turn"] == 2
                and restart["active"] == 1
                and restart["remaining"] > progress["remaining"],
                "Restart missing",
            )
            expiry = [s for s in samples if s["stage"] == "waiting"][-1]
            require(
                expiry["turn"] == 3
                and expiry["expiries"] == 1
                and expiry["active"] == 1,
                "Automatic turn missing or duplicated",
            )
        disabled, stopped = stages["disabled"], stages["disabled-idle"]
        require(
            disabled["active"] == stopped["active"] == 0
            and disabled["turn"] == stopped["turn"]
            and stopped["frames"] - disabled["frames"] >= 250,
            "Disabled game advanced or interval absent",
        )
        initial_image = out / samples[0]["image"]
        require(
            number(initial_image, samples[0]["image_sha256"], 164, 130, 10)
            == 123456789,
            "Native digit fixture differs from the qualified font",
        )
        require(
            sha(out / case["quit_image"]) == case["quit_image_sha256"],
            "Changed exit capture",
        )
        require(
            number(out / samples[0]["image"], samples[0]["image_sha256"], 388, 98)
            == case["bank_address"],
            "Initial native bank address disagrees",
        )

    exports = json.loads((out / "published.json").read_text())
    require(set(exports) == {"working", "wrong"}, "Missing publication export")
    for variant, stage in [("working", "waiting"), ("wrong", "wrong-no-expiry")]:
        source = [
            s for s in record["cases"][variant]["samples"] if s["stage"] == stage
        ][-1]
        export = exports[variant]
        require(
            export["source"] == source["image"]
            and export["source_sha256"] == source["image_sha256"],
            "Publication used the wrong observed state",
        )
        raw = out / export["source"]
        published = out / export["published"]
        require(
            sha(raw) == export["source_sha256"]
            and sha(published) == export["published_sha256"],
            "Changed publication pixels",
        )
        require(
            published.read_bytes() == C.display_png(raw),
            "Publication removed unique pixels",
        )


if __name__ == "__main__":
    check()
    print("AMOS native deadlines, arithmetic and exact-boundary control passed")
