"""Qualify AMOS deadlines in the original editor/runtime, not a host interpreter."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from types import ModuleType
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "commodore-amiga/patterns/amos/framework/turn-deadline"
PHASES = FOLDER / "verification/phases"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


T = load("transport", ROOT / "scripts/verify-game-loops.py")
C = load("pixels", ROOT / "scripts/check-amiga-command-loops.py")
DIGITS = {**C.DIGITS, "7": (252, 12, 12, 24, 48, 48, 48, 0)}
B = load("builder", FOLDER / "build.py")


def number(image: Path, x: int, y: int, maxdigits: int = 8) -> int:
    width, height, channels, pixels = C.png(image)
    T.require((width, height) == (1536, 576), "Unexpected AMOS capture geometry")
    found = ""
    for col in range(maxdigits):
        rows = []
        for yy in range(8):
            row = 0
            for xx in range(8):
                at = ((y + yy * 2) * width + x + col * 32 + xx * 4) * channels
                if min(pixels[at : at + 3]) > 180:
                    row |= 128 >> xx
            rows.append(row)
        mask = 0
        for row in rows:
            mask |= row
        if not mask:
            break
        glyph = tuple((row << (8 - mask.bit_length())) & 255 for row in rows)
        hits = [digit for digit, shape in DIGITS.items() if glyph == shape]
        T.require(
            len(hits) == 1, f"Unrecognised numeric glyph in {image.name}: {glyph}"
        )
        found += hits[0]
    T.require(bool(found), f"No numeric output in {image.name}")
    return int(found)


def command(args: argparse.Namespace) -> list[str]:
    return [
        str(args.emulator),
        "--model",
        "a1200",
        "--kickstart",
        str(args.kickstart),
        "--drives",
        "2",
        "--mcp",
    ]


def phase(
    machine: T.Machine, args: argparse.Namespace, name: str, variant: str | None = None
) -> None:
    steps = json.loads((PHASES / name).read_text())
    for original in steps:
        text = (
            json.dumps(original)
            .replace("${RUN}", str(args.private))
            .replace("${AMOS}", str(args.amos))
        )
        if variant:
            text = text.replace("working", variant)
        step = json.loads(text)
        action = step.pop("action")
        result = machine.call(action, **step)
        if action == "type_string":
            T.require(
                result["chars_typed"] == len(step["text"]),
                "Incomplete keyboard source selection",
            )
        if action == "run_frames":
            T.require(
                result["frames"] == step["frames"]
                and result["stop_reason"] == "ReachedTarget",
                "Incomplete native phase",
            )
        if variant and action == "save_screenshot":
            break


def fixture_identity(args: argparse.Namespace) -> dict[str, Any]:
    config = json.loads((FOLDER / "verification/configuration.json").read_text())
    return {
        "fixture_sha256": T.sha(args.private / "cases.adf"),
        "builder_sha256": config["builder_sha256"],
        "program_sha256": {
            variant: hashlib.sha256(B.program(variant).encode("ascii")).hexdigest()
            for variant in VARIANTS
        },
    }


def require_fixture(args: argparse.Namespace) -> None:
    expected = fixture_identity(args)
    actual = json.loads((args.private / "fixture.json").read_text())
    T.require(
        actual == expected,
        "Stale or unbound source fixture; prepare a fresh private run",
    )


def prepare(args: argparse.Namespace) -> None:
    if args.builder is None:
        raise ValueError("--prepare requires --builder")
    config = json.loads((FOLDER / "verification/configuration.json").read_text())
    T.require(
        T.sha(args.builder) == config["builder_sha256"],
        "Different named fixture builder",
    )
    subprocess.run(["make"], cwd=FOLDER, check=True, timeout=30)
    target = args.private / "cases.adf"
    if target.exists():
        raise ValueError(
            "Use a fresh private directory; refusing to replace fixture media"
        )
    create = [str(args.builder), "create", str(target), "--label", "Cases"]
    for variant in VARIANTS:
        create += ["--add", f"{FOLDER}/build/{variant}.asc={variant}.asc"]
    subprocess.run(create, check=True, timeout=30)
    subprocess.run([str(args.builder), "verify", str(target)], check=True, timeout=30)
    (args.private / "fixture.json").write_text(
        json.dumps(fixture_identity(args), indent=2) + "\n"
    )


def boot(args: argparse.Namespace) -> None:
    require_fixture(args)
    for name in ["amos-cases-cold.json", "amos-cases-blank.json"]:
        machine = T.Machine(command(args))
        try:
            phase(machine, args, name)
        finally:
            machine.close()
    print("Cold fixture/editor phases complete; case checks still required", flush=True)


def qualify(args: argparse.Namespace, variant: str) -> dict[str, Any]:
    machine = T.Machine(command(args))
    out = FOLDER / "verification"
    out.mkdir(exist_ok=True)
    samples = []
    total_frames = 0
    try:
        phase(machine, args, "working-case.json", variant)

        def frames(n: int) -> None:
            nonlocal total_frames
            while n:
                part = min(n, 200)
                result = machine.call("run_frames", frames=part)
                T.require(
                    result["frames"] == part
                    and result["stop_reason"] == "ReachedTarget",
                    "Incomplete behaviour window",
                )
                total_frames += part
                n -= part

        frames(2)
        first = out / f"{variant}-initial.png"
        machine.call("save_screenshot", path=str(first))
        base = number(first, 388, 98)
        T.require(0 < base < 2 * 1024 * 1024 - 160, "Invalid native work-bank address")

        def observe(stage: str) -> dict[str, Any]:
            for _ in range(20):
                raw = machine.call("memory_read", addr=base, len=32)["bytes"]
                T.require(
                    len(raw) == 32 and raw[28:30] == [165, 90],
                    "Wrong/missing bank guard",
                )
                if raw[31] == 239:
                    break
                frames(1)
            T.require(raw[31] == 239, "No completed observer snapshot")
            fields = {
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
            image = out / f"{variant}-{len(samples):02d}-{stage}.png"
            machine.call("save_screenshot", path=str(image))
            T.require(
                C.counter(image, "amos", 0) == fields["turn"],
                "Native pixels disagree with bank counter",
            )
            sample = {
                "stage": stage,
                "frames": total_frames,
                **fields,
                "bank": raw,
                "image": image.name,
                "image_sha256": T.sha(image),
            }
            samples.append(sample)
            print(variant, stage, fields, flush=True)
            return sample

        def key(name: str, hold: int = 4) -> None:
            machine.call("input", events=[{"Key": {"name": name, "pressed": True}}])
            frames(hold)
            machine.call("input", events=[{"Key": {"name": name, "pressed": False}}])
            frames(8)

        if variant in {"boundaries", "wrong-boundary"}:
            for _ in range(20):
                raw = machine.call("memory_read", addr=base, len=160)["bytes"]
                if len(raw) == 160 and raw[156:158] == [165, 90] and raw[159] == 239:
                    break
                frames(1)
            T.require(
                len(raw) == 160 and raw[156:158] == [165, 90] and raw[159] == 239,
                "Incomplete arithmetic caller",
            )
            T.require(
                number(first, 388, 66, 3) == 16 and number(first, 388, 114) == 160,
                "Arithmetic caller did not display completion/allocation",
            )
            cases = []
            lines = [
                line
                for line in (FOLDER / "boundaries.amos").read_text().splitlines()
                if line.startswith("Data ")
            ]
            for index, line in enumerate(lines):
                previous, now, duration = map(int, line[5:].split(","))
                elapsed = (now - previous) % 65536
                expired = int(duration > 0 and elapsed >= duration)
                actual = [
                    int.from_bytes(bytes(raw[index * 8 + j : index * 8 + j + 2]), "big")
                    for j in [0, 2, 4, 6]
                ]
                expected = [
                    expired,
                    max(0, duration - elapsed) if duration else 0,
                    elapsed,
                    int(duration > 0 and not expired),
                ]
                cases.append(
                    {
                        "index": index,
                        "previous": previous,
                        "now": now,
                        "duration": duration,
                        "actual": actual,
                        "expected": expected,
                        "oracle_matches": actual == expected,
                    }
                )
            T.require(len(cases) == 16, "Missing arithmetic cases")
            agrees = all(case["oracle_matches"] for case in cases)
            T.require(
                not agrees if variant == "wrong-boundary" else agrees,
                "Arithmetic control did not distinguish exact expiry",
            )
            return {
                "bank_address": base,
                "raw": raw,
                "cases": cases,
                "image": first.name,
                "image_sha256": T.sha(first),
                "bank_length": 160,
                "program_sha256": hashlib.sha256(
                    B.program(variant).encode()
                ).hexdigest(),
            }
        initial = observe("initial")
        frames(120)
        idle = observe("idle")
        T.require(
            initial["turn"] == idle["turn"] == 0 and idle["active"] == 0,
            "Untimed idle advanced",
        )
        key("a", 100)
        action = observe("action")
        T.require(
            action["turn"] == 1 and action["active"] == 0,
            "Held action repeated or armed timer",
        )
        key("t")
        enabled = observe("enabled")
        T.require(enabled["active"] == 1, "Timing did not enable")
        frames(30)
        progress = observe("progress")
        T.require(progress["clock"] != enabled["clock"], "Clock stopped")
        if variant == "wrong":
            frames(250)
            expiry = observe("wrong-no-expiry")
            T.require(
                expiry["turn"] == 1
                and expiry["remaining"] == 200
                and expiry["elapsed"] == 0,
                "Baseline fault absent",
            )
        else:
            T.require(
                progress["remaining"] < enabled["remaining"],
                "Deadline did not progress",
            )
            key("a")
            restart = observe("restart")
            T.require(
                restart["turn"] == 2 and restart["remaining"] > progress["remaining"],
                "Restart failed",
            )
            for _ in range(60):
                frames(5)
                expiry = observe("waiting")
                if expiry["expiries"]:
                    break
            T.require(
                expiry["turn"] == 3 and expiry["expiries"] == 1,
                "Automatic turn missing or duplicated",
            )
        key("t")
        disabled = observe("disabled")
        frames(250)
        stopped = observe("disabled-idle")
        T.require(
            disabled["active"] == stopped["active"] == 0
            and disabled["turn"] == stopped["turn"],
            "Disabled state advanced",
        )
        key("q")
        frames(30)
        quit_image = out / f"{variant}-quit.png"
        machine.call("save_screenshot", path=str(quit_image))
        return {
            "bank_address": base,
            "samples": samples,
            "program_sha256": hashlib.sha256(B.program(variant).encode()).hexdigest(),
            "quit_image": quit_image.name,
            "quit_image_sha256": T.sha(quit_image),
        }
    finally:
        machine.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--emulator", type=Path, required=True)
    parser.add_argument("--kickstart", type=Path, required=True)
    parser.add_argument("--amos", type=Path, required=True)
    parser.add_argument("--private", type=Path, required=True)
    parser.add_argument("--builder", type=Path)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--boot", action="store_true")
    parser.add_argument("--variants", default="")
    args = parser.parse_args()
    args.private = args.private.resolve()
    args.private.mkdir(parents=True, exist_ok=True)
    baseline = json.loads((FOLDER / "verification/configuration.json").read_text())
    for actual, expected in [
        (args.emulator, baseline["emulator_sha256"]),
        (args.kickstart, baseline["firmware_sha256"]),
        (args.amos, baseline["runtime_media_sha256"]),
    ]:
        T.require(
            T.sha(actual) == expected,
            "Different named tool/firmware/runtime configuration",
        )
    if args.prepare:
        prepare(args)
    if args.boot:
        boot(args)
    if args.variants:
        require_fixture(args)
        out = FOLDER / "verification"
        out.mkdir(exist_ok=True)
        target = out / "results.json"
        records = json.loads(target.read_text())["cases"] if target.exists() else {}
        for variant in args.variants.split(","):
            T.require(variant in VARIANTS, "Unknown native case")
            records[variant] = qualify(args, variant)
        record = {
            "fixture": fixture_identity(args),
            "status": "native-checked",
            "machine": "commodore-amiga",
            "language": "amos",
            "configuration": "PAL A1200, 2 MiB chip, no fast RAM",
            "emulator_sha256": T.sha(args.emulator),
            "firmware_sha256": T.sha(args.kickstart),
            "runtime_media_sha256": T.sha(args.amos),
            "cases": records,
        }
        target.write_text(json.dumps(record, indent=2) + "\n")
