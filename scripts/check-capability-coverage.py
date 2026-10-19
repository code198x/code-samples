"""Validate retained capability claims against exact registry membership and files.

This checks retained evidence, not a fresh emulator run. Empty inventories,
changed sources, missing captures and missing negative controls are errors.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import wave
from pathlib import Path

import tomllib

ROOT = Path(__file__).resolve().parents[1]
CORE = {
    "commodore-c64",
    "sinclair-zx-spectrum",
    "commodore-amiga",
    "nintendo-nes",
    "acorn-bbc-micro",
}
NO_SPEAKER = {"sinclair-zx80", "sinclair-zx81"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked_file(root: Path, name: str, expected: str) -> Path:
    path = (root / name).resolve()
    require(path.is_relative_to(root.resolve()), f"Outside repository: {name}")
    require(path.is_file() and path.stat().st_size > 0, f"Missing/empty file: {name}")
    require(sha(path) == expected, f"Changed file: {name}")
    return path


def validate(root: Path, manifest: dict, registry: dict | None = None) -> dict:
    require(manifest.get("version") == 1, "Unknown capability manifest version")
    pin = manifest.get("registry", {})
    snapshot = checked_file(root, pin["snapshot"], pin["sha256"])
    pinned = tomllib.loads(snapshot.read_text())
    declared = pin.get("systems", [])
    require(bool(declared), "Empty registry inventory")
    expected = {row["machine_id"]: row["crate"] for row in declared}
    require(len(expected) == len(declared), "Duplicate registry machine")
    pinned_joins = {row["machine_id"]: row["crate"] for row in pinned["system"]}
    require(pinned_joins == expected, "Pinned registry membership/crate joins changed")
    if registry is not None:
        actual = {row["machine_id"]: row["crate"] for row in registry["system"]}
        require(actual == expected, "Registry membership/crate joins changed")
    rows = manifest.get("systems", [])
    require(bool(rows), "Empty capability inventory")
    require(
        len({row["machine_id"] for row in rows}) == len(rows),
        "Duplicate capability machine",
    )
    require(
        {row["machine_id"] for row in rows} == set(expected),
        "Capability inventory does not cover exact registry membership",
    )
    require(
        {row["machine_id"] for row in rows if row["role"] == "composition"} == CORE,
        "Five commissioned compositions must remain present",
    )
    for name, digest in manifest.get("verification_tools", {}).items():
        checked_file(root, name, digest)
    require(bool(manifest.get("verification_tools")), "Missing verifier identities")
    sound_count = 0
    for row in rows:
        name = row["machine_id"]
        require(row["crate"] == expected[name], f"Wrong crate join: {name}")
        record_path = checked_file(root, row["record"], row["record_sha256"])
        record = json.loads(record_path.read_text())
        require(record.get("status") == "passed", f"No passing record: {name}")
        sources = record.get("sources", {})
        require(bool(sources), f"No identified sources: {name}")
        for path, digest in sources.items():
            checked_file(root, path, digest)
        for capability in ("input", "drawing"):
            require(
                row[capability]["status"] == "executed"
                and bool(row[capability]["contract"]),
                f"Unqualified {capability}: {name}",
            )
        if row["role"] == "composition" or name == "acorn-electron":
            require(
                record.get("negative_collection_rejected") is True,
                f"Missing collection negative: {name}",
            )
        elif row["kind"] == "hardware":
            controls = record.get("negative_controls", {})
            require(
                all(
                    controls.get(c, {}).get("same_guard_rejected") is True
                    for c in ("drawing", "sound")
                ),
                f"Missing independent negatives: {name}",
            )
        elif name == "jupiter-ace":
            require(
                record.get("sound_negative_rejected") is True,
                "Missing Ace sound negative",
            )
            require(
                record.get("negative_control", {}).get("idle_guard_rejected") is True,
                "Missing Ace input negative",
            )
        elif name not in NO_SPEAKER:
            require(
                record.get("sound_negative_rejected") is True,
                f"Missing BASIC sound negative: {name}",
            )
            require(
                bool(record.get("keyboard_baseline")),
                f"Missing keyboard sound baseline: {name}",
            )
        else:
            require(
                record.get("negative_control", {}).get("accepted_turn_guard_rejected")
                is True,
                f"Missing numeric input negative: {name}",
            )
        captures = row.get("captures", {})
        require(bool(captures), f"No captures: {name}")
        for path, digest in captures.items():
            image = checked_file(root, path, digest)
            require(
                image.read_bytes().startswith(b"\x89PNG\r\n\x1a\n"), f"Not PNG: {path}"
            )
        sound = row["sound"]
        if name in NO_SPEAKER:
            require(
                sound["status"] == "hardware-absent" and bool(sound["contract"]),
                f"Invented stock sound: {name}",
            )
        else:
            require(sound["status"] == "executed", f"Unqualified sound: {name}")
            clip = checked_file(root, sound["excerpt"], sound["excerpt_sha256"])
            with wave.open(str(clip)) as stream:
                require(
                    stream.getnframes() > 0 and stream.getsampwidth() == 2,
                    f"Empty/unsupported PCM: {name}",
                )
            require(
                bool(sound.get("full_capture_sha256")),
                f"Missing full capture identity: {name}",
            )
            sound_count += 1
        build = manifest["emulator_builds"].get(name, {})
        require(
            build.get("sha256") == record.get("emulator_sha256"),
            f"Wrong executable identity: {name}",
        )
        require(bool(build.get("commit")), f"No executable source revision: {name}")
    return {
        "machines": len(rows),
        "compositions": len(CORE),
        "additional_probes": len(rows) - len(CORE),
        "sound_executed": sound_count,
        "stock_sound_absent": len(NO_SPEAKER),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest", type=Path, default=ROOT / "docs/capability-coverage.json"
    )
    parser.add_argument("--registry", type=Path)
    args = parser.parse_args()
    registry = tomllib.loads(args.registry.read_text()) if args.registry else None
    result = validate(ROOT, json.loads(args.manifest.read_text()), registry)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
