"""Check selected recorded inputs; this does not execute machine fixtures."""

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SELECTION = Path(__file__).with_name("pattern-evidence.json")
# Keep the audited scope explicit: shrinking a selector must not silently go green.
REQUIRED_BINDINGS = {"c64": 5, "nes": 3, "amiga": 5, "spectrum": 3, "aabb": 2}


def inspect(root: Path, fixtures: Any) -> dict[str, Any]:
    if not isinstance(fixtures, list) or not all(isinstance(f, dict) for f in fixtures):
        raise ValueError("Selection must be a list of fixture objects")
    names = [f.get("name") for f in fixtures]
    if len(names) != len(REQUIRED_BINDINGS) or set(names) != set(REQUIRED_BINDINGS):
        raise ValueError(
            "Selection must contain c64, nes, amiga, spectrum and aabb once each"
        )
    observations = []
    failures = []
    for fixture in fixtures:
        name = fixture["name"]
        checks = []
        try:
            bindings = fixture["bindings"]
            if (
                not isinstance(bindings, list)
                or len(bindings) != REQUIRED_BINDINGS[name]
            ):
                raise ValueError(
                    f"Expected {REQUIRED_BINDINGS[name]} declared bindings"
                )
            paths = [binding["path"] for binding in bindings]
            if len(set(paths)) != len(paths):
                raise ValueError("Duplicate source binding")
            record_path = root / fixture["record"]
            raw = record_path.read_bytes()
            record = json.loads(raw)
            if not isinstance(record, dict) or not record:
                raise ValueError("Execution record must be a nonempty object")
            for binding in bindings:
                expected = record
                keys = binding["record_keys"]
                if not isinstance(keys, list) or not keys:
                    raise ValueError("Missing record hash selector")
                for key in keys:
                    expected = expected[key]
                if not isinstance(expected, str) or not re.fullmatch(
                    "[0-9a-f]{64}", expected
                ):
                    raise ValueError(f"Invalid recorded SHA-256 for {binding['path']}")
                actual = hashlib.sha256(
                    (root / binding["path"]).read_bytes()
                ).hexdigest()
                matches = actual == expected
                checks.append(
                    {
                        "path": binding["path"],
                        "recorded_sha256": expected,
                        "current_sha256": actual,
                        "matches": matches,
                    }
                )
                if not matches:
                    failures.append(f"{name}: stale recorded input: {binding['path']}")
            observations.append(
                {
                    "name": name,
                    "record": fixture["record"],
                    "record_sha256": hashlib.sha256(raw).hexdigest(),
                    "bindings": checks,
                }
            )
        except (OSError, KeyError, TypeError, ValueError) as error:
            failures.append(f"{name}: {error}")
            observations.append(
                {
                    "name": name,
                    "record": fixture.get("record"),
                    "bindings": checks,
                    "error": str(error),
                }
            )
    return {
        "status": "stale_or_missing_inputs" if failures else "recorded_inputs_match",
        "fixtures_checked": len(observations),
        "bindings_checked": sum(len(f["bindings"]) for f in observations),
        "fixtures": observations,
        "failures": failures,
        "runtime_execution": "not performed by this check",
        "limits": "Matching hashes do not revalidate behaviour, installed tools, "
        "firmware, other configurations or authenticity of a recorded run.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        type=Path,
        default=ROOT,
        help="Samples checkout to check (also used by isolated regression tests)",
    )
    parser.add_argument("--selection", type=Path, default=SELECTION)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.unlink(missing_ok=True)
    try:
        report = inspect(args.root, json.loads(args.selection.read_text()))
    except (OSError, KeyError, TypeError, ValueError) as error:
        report = {
            "status": "invalid_selection",
            "failures": [str(error)],
            "runtime_execution": "not performed by this check",
        }
    rendered = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.write_text(rendered)
    print(rendered, end="")
    if report["failures"]:
        print(
            "Pattern inputs need revalidation. Run the affected sample's documented "
            "verifier and select its new record; preserve the historical record. "
            "Do not refresh hashes without running the fixture.",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
