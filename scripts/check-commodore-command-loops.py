"""Validate bound native screen observations; never claims fresh execution."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
_spec = importlib.util.spec_from_file_location(
    "cbm", ROOT / "scripts/verify-commodore-command-loops.py"
)
assert _spec and _spec.loader
V = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(V)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def check(
    system: str, track: str, root: Path = ROOT, record: dict | None = None
) -> None:
    folder = root / system / f"patterns/{track}/framework/command-loop"
    out = folder / "verification/reusable"
    r = record if record is not None else json.loads((out / "results.json").read_text())
    require(
        (r["status"], r["machine"], r["track"]) == ("passed", system, track),
        "Wrong successful route",
    )
    expected_inputs = (
        {
            "caller.bas",
            "routines.bas",
            "complete.bas",
            "customise.bas",
            "mistakes/reset-each-command.bas",
        }
        if track == "basic"
        else {
            "caller.inc",
            "routines.inc",
            "presentation.inc",
            "demo.asm",
            "customise.inc",
            "mistakes/reset-each-command.inc",
        }
    )
    prefix = str(folder.relative_to(root))
    require(
        set(r["sources"]) == {prefix + "/" + p for p in expected_inputs},
        "Missing source binding",
    )
    require(
        set(r["observer_sources"])
        == {
            "scripts/verify-commodore-command-loops.py",
            "scripts/verify-game-loops.py",
        },
        "Missing observer binding",
    )
    for name, digest in {**r["sources"], **r["observer_sources"]}.items():
        require(
            hashlib.sha256((root / name).read_bytes()).hexdigest() == digest,
            "Changed input " + name,
        )
    # Rebuild the exact entered source independently from maintained callers.
    # A record from the wrong caller must not qualify a different variant.
    require(
        track != "basic"
        or (folder / "complete.bas").read_text()
        == (folder / "caller.bas").read_text() + (folder / "routines.bas").read_text(),
        "Complete program differs from its reusable parts",
    )
    require(set(r["cases"]) == set(V.VARIANTS), "Incomplete case set")
    require(
        r["emulator_release"] == "v0.44.1"
        and r["producer_source_lock"]["version"] == "0.44.1",
        "Unqualified emulator release",
    )
    if track == "assembly":
        require(
            r["assembler_source_lock"]["version"] == "0.0.71",
            "Unqualified assembler release",
        )

    require(
        r["screen_length"]
        == {"commodore-64": 1000, "commodore-pet": 1000, "commodore-vic-20": 506}[
            system
        ],
        "Screen qualification changed",
    )
    require(
        r["emulator_sha256"] == r["producer_source_lock"]["executable_sha256"],
        "Emulator identity mismatch",
    )
    require(
        len(r["firmware_sha256"]) >= 3
        and all(len(x) == 64 for x in r["firmware_sha256"].values()),
        "Missing firmware",
    )
    for variant, (initial, step) in V.VARIANTS.items():
        if track == "basic":
            filename = (
                "customise.bas"
                if variant == "step-three"
                else "mistakes/reset-each-command.bas"
                if variant == "wrong-reset"
                else "caller.bas"
            )
            caller = (folder / filename).read_text()
            if variant in ("wrap", "nonzero"):
                caller = caller.replace("N=0:S=1", f"N={initial}:S={step}")
            entered = caller + (folder / "routines.bas").read_text()
        else:
            filename = (
                "customise.inc"
                if variant == "step-three"
                else "mistakes/reset-each-command.inc"
                if variant == "wrong-reset"
                else "caller.inc"
            )
            caller = (folder / filename).read_text()
            if variant in ("wrap", "nonzero"):
                caller = caller.replace(
                    "lda #0\n    sta turn_count", f"lda #{initial}\n    sta turn_count"
                ).replace(
                    "lda #1\n    sta turn_step", f"lda #{step}\n    sta turn_step"
                )
            entered = (folder / "demo.asm").read_text()
            for include in ["caller", "routines", "presentation"]:
                entered = entered.replace(
                    f'    !source "{include}.inc"',
                    caller
                    if include == "caller"
                    else (folder / f"{include}.inc").read_text(),
                )
        case = r["cases"][variant]
        require(
            hashlib.sha256(entered.encode()).hexdigest() == case["entered_sha256"],
            "Wrong entered caller identity",
        )
        obs = case["observations"]
        first = (initial + step) % 256
        second = (initial + step * 2) % 256
        expected = [initial, initial, first, first, first, second]
        if variant == "wrong-reset":
            expected = [0, 0, 1, 1, 0, 1]
        require(
            [o["stage"] for o in obs]
            == ["initial", "idle", "first", "idle-after", "ignored", "second"],
            "Missing observation stage",
        )
        require([o["count"] for o in obs] == expected, "Incorrect progression")
        for observation, value in zip(obs, expected, strict=True):
            raw = observation["screen_bytes"]
            require(len(raw) == r["screen_length"], "Short screen observation")
            import re

            hits = re.findall(r"TURN\s*(\d+)", V.decode(raw))
            require(
                len(hits) == 1 and int(hits[0]) == value, "Rendered counter disagrees"
            )
            if track == "assembly":
                require(
                    observation["native_state"]
                    == [
                        value,
                        step,
                        0
                        if observation["stage"] in ["initial", "idle", "ignored"]
                        else 1,
                    ],
                    "Native state disagrees",
                )
            image = out / observation["image"]
            require(
                image.name == f"{variant}-{observation['stage']}.png",
                "Wrong capture binding",
            )
            require(
                image.read_bytes().startswith(b"\x89PNG\r\n\x1a\n")
                and hashlib.sha256(image.read_bytes()).hexdigest()
                == observation["image_sha256"],
                "Changed image",
            )
        require(case["quit_ready"] is True, "Quit path missing")
    require(
        r["cases"]["wrong-reset"]["observations"][-1]["count"]
        != r["cases"]["working"]["observations"][-1]["count"],
        "Fault not distinguishable",
    )


if __name__ == "__main__":
    for s, t in V.ROUTES:
        check(s, t)
        print(s, t, "retained source/screen records checked; no fresh emulator run")
