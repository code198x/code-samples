"""Reject omitted machines, wrong crate joins and unsupported probe claims."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import tomllib

ROOT = Path(__file__).resolve().parents[1]


def check(manifest: Path, registry: Path) -> tuple[int, int]:
    data = json.loads(manifest.read_text())
    systems = tomllib.loads(registry.read_text())["system"]
    expected = {row["machine_id"]: row["crate"] for row in systems}
    rows = data["systems"]
    actual = {row["machine_id"]: row["crate"] for row in rows}
    if not expected or len(actual) != len(rows) or actual != expected:
        raise ValueError(
            "Probe inventory must match every registry machine/crate exactly"
        )
    if hashlib.sha256(registry.read_bytes()).hexdigest() != data["registry"]["sha256"]:
        raise ValueError("Registry changed: review coverage and update its provenance")
    qualified = 0
    for row in rows:
        if row["status"] == "planned":
            if not row.get("next_check") or row.get("record"):
                raise ValueError(
                    "Planned machine needs a next check, not a passing record"
                )
            continue
        if row["status"] != "qualified":
            raise ValueError(f"Unknown status: {row['status']}")
        proof = json.loads((ROOT / row["record"]).read_text())
        if proof["status"] != "passed" or proof["server"]["name"] != row["crate"]:
            raise ValueError(f"Proof does not qualify {row['machine_id']}")
        sources = proof.get("sources_sha256", proof.get("sources", {}))
        if not sources:
            raise ValueError("Qualified record has no identified sources")
        for name, digest in sources.items():
            if "build" in Path(name).parts:
                continue  # Generated loader/binaries are separately retained hashes.
            path = ROOT / name
            if (
                not path.is_file()
                or hashlib.sha256(path.read_bytes()).hexdigest() != digest
            ):
                raise ValueError(
                    f"Source missing or changed since qualification: {name}"
                )
        if "observer_sha256" in proof:
            observer = ROOT / "scripts/verify-game-loops.py"
            if (
                hashlib.sha256(observer.read_bytes()).hexdigest()
                != proof["observer_sha256"]
            ):
                raise ValueError("Frame observer changed since qualification")
        if "negative_controls" in proof:
            controls = proof["negative_controls"]
            if set(controls) != {"no-wait", "no-edge"} or not all(
                c["rejected"] is True for c in controls.values()
            ):
                raise ValueError("Turn probe lacks rejected timing/input controls")
        elif (
            proof.get("negative_control", {}).get("same_rate_guard_rejected")
            is not True
        ):
            raise ValueError("Frame probe lacks rejected negative control")
        qualified += 1
    return len(rows), qualified


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--registry", type=Path, required=True)
    parser.add_argument(
        "--manifest", type=Path, default=ROOT / "docs/probe-coverage.json"
    )
    args = parser.parse_args()
    total, qualified = check(args.manifest, args.registry)
    print(
        f"{total} registry machines; {qualified} qualified; {total - qualified} planned"
    )


if __name__ == "__main__":
    main()
