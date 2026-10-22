"""Replay one retained native Amiga phase; inspect output before claiming a pass.

No licensed media or running snapshots are distributed. Prepare source-only
fixture disks, then replay the boot/editor and case phases in the README order.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def substitute(value: Any, replacements: dict[str, str]) -> Any:
    if isinstance(value, str):
        for key, target in replacements.items():
            value = value.replace(key, target)
        return value
    if isinstance(value, list):
        return [substitute(item, replacements) for item in value]
    if isinstance(value, dict):
        return {key: substitute(item, replacements) for key, item in value.items()}
    return value


def prepare(builder: Path, output: Path) -> None:
    folder = ROOT / "commodore-amiga/patterns/amos/framework/command-loop"
    demo = (folder / "demo.amos").read_text()
    for name, initial in [
        ("wrap", "254 : PL_STEP=1"),
        ("nonzero", "100 : PL_STEP=255"),
    ]:
        (output / f"{name}.asc").write_text(
            demo.replace("PL_COUNT=0 : PL_STEP=1", f"PL_COUNT={initial}")
        )
    groups = {
        "cases": {
            "working": folder / "demo.amos",
            "custom": folder / "customise.amos",
            "wrong": folder / "mistakes/reset-each-command.amos",
            "fixed": folder / "demo.amos",
            "wrap": output / "wrap.asc",
            "nonzero": output / "nonzero.asc",
        },
    }
    for name, files in groups.items():
        target = output / f"{name}.adf"
        if target.exists():
            raise ValueError(f"Refusing to overwrite {target}")
        command = [str(builder), "create", str(target), "--label", name.capitalize()]
        for dest, source in files.items():
            command += ["--add", f"{source}={dest}.asc"]
        subprocess.run(command, capture_output=True, text=True, timeout=30, check=True)
        subprocess.run(
            [str(builder), "verify", str(target)],
            capture_output=True,
            text=True,
            timeout=30,
            check=True,
        )


def replay(args: argparse.Namespace) -> None:
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    if args.prepare:
        if args.builder is None:
            raise ValueError("--prepare requires --builder")
        prepare(args.builder.resolve(), output)
        return
    if not args.phase or Path(args.phase).name != args.phase:
        raise ValueError("Select one phase filename from verification/phases")
    phase = (
        ROOT
        / f"commodore-amiga/patterns/{args.language}/framework/command-loop/verification/phases/{args.phase}"
    )
    replacements = {"${RUN}": str(output)}
    for key in ["amos", "blitz", "blitz_libs"]:
        path = getattr(args, key)
        if path:
            replacements["${" + key.upper() + "}"] = str(path.resolve())
    record = json.loads((phase.parent.parent / "results.json").read_text())
    for path, expected, label in [
        (args.emulator, record["emulator_sha256"], "emulator"),
        (args.kickstart, record["firmware_sha256"], "firmware"),
    ]:
        if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise ValueError("Different qualified " + label)
    media = (
        [(args.amos, "system")]
        if args.language == "amos"
        else [(args.blitz, "system"), (args.blitz_libs, "libs")]
    )
    for path, name in media:
        if (
            path is None
            or hashlib.sha256(path.read_bytes()).hexdigest()
            != record["runtime_media_sha256"][name]
        ):
            raise ValueError("Different qualified runtime media: " + name)
    steps = substitute(json.loads(phase.read_text()), replacements)
    if not steps or "${" in json.dumps(steps):
        raise ValueError("Empty phase or missing media argument")
    machine = T.Machine(
        [
            str(args.emulator.resolve()),
            "--model",
            "a1200",
            "--kickstart",
            str(args.kickstart.resolve()),
            "--drives",
            "2",
            "--mcp",
        ]
    )
    observations = []
    try:
        for step in steps:
            fields = step.copy()
            action = fields.pop("action")
            result = machine.call(action, **fields)
            if action == "type_string":
                T.require(
                    result["chars_typed"] == len(fields["text"]),
                    "Incomplete keyboard entry",
                )
            if action == "run_frames":
                T.require(
                    result["frames"] == fields["frames"]
                    and result["stop_reason"] == "ReachedTarget",
                    "Incomplete native run",
                )
            observations.append({"action": action, "arguments": step, "result": result})
    finally:
        machine.close()
        # Retain transport failures too. This log does not assert visible results.
        (output / f"{phase.stem}-transport.json").write_text(
            json.dumps(observations, indent=2) + "\n"
        )
    print(f"{phase.name}: actions completed; inspect the native captures.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("phase", nargs="?")
    parser.add_argument("--language", choices=["amos", "blitz"], default="amos")
    parser.add_argument("--emulator", type=Path)
    parser.add_argument("--kickstart", type=Path)
    parser.add_argument("--amos", type=Path)
    parser.add_argument("--blitz", type=Path)
    parser.add_argument("--blitz-libs", type=Path)
    parser.add_argument("--builder", type=Path)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--output", type=Path, required=True)
    options = parser.parse_args()
    if not options.prepare and (not options.emulator or not options.kickstart):
        parser.error("Replay requires --emulator and --kickstart")
    replay(options)
