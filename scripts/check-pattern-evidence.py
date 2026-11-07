"""Check selected recorded inputs; this does not execute machine fixtures.

A fixture that names its recorder is judged by the programs the machine was
given: the checker rebuilds each one with the tools the record pins and
compares its bytes with the record. Recorder and source digests are then
provenance. Other fixtures still compare their declared source digests.
"""

import argparse
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SELECTION = Path(__file__).with_name("pattern-evidence.json")
# Keep the audited scope explicit: shrinking a selector must not silently go green.
REQUIRED_BINDINGS = {"c64": 0, "nes": 0, "amiga": 0, "spectrum": 0, "aabb": 2}


AUDIT_SELECTION = Path(__file__).with_name("routine-audit-evidence.json")
AUDIT_BINDINGS = {
    "z80": 0,
    "basic": 0,
    "amiga-lines": 0,
    "amiga-edges": 0,
    "amiga-music": 0,
    "nes-movement": 0,
    "c64-scroll": 0,
    "spectrum-states": 0,
}

PARSER_SELECTION = Path(__file__).with_name("adventure-parser-evidence.json")
PARSER_BINDINGS = {"parser-basic": 0, "parser-z80": 0, "parser-callers": 0}


def _load_evidence_bytes():
    found = importlib.util.spec_from_file_location(
        "pattern_evidence_bytes", ROOT / "scripts/evidence_bytes.py"
    )
    assert found and found.loader
    value = importlib.util.module_from_spec(found)
    found.loader.exec_module(value)
    return value


E = _load_evidence_bytes()


def require_programs(name: str, recorder: dict, record: dict) -> int:
    """Rebuild every program the record names and compare it byte for byte."""
    programs = record.get("programs")
    if not isinstance(programs, dict) or not programs:
        raise ValueError("Record names no programs to rebuild")
    out = f"build/evidence/{name}"
    args = tuple(str(a).replace("{output}", out) for a in recorder["args"])
    build = E.function(
        ROOT / recorder["script"],
        recorder.get("function", "build_programs"),
        args,
        ROOT,
        tuple(f"{out}/{program}" for program in programs),
    )
    builder = record["build198x_sha256"] if E.BUILDER in args else None
    assembler = record["assembler_sha256"] if E.ASSEMBLER in args else None
    for program, digest in programs.items():
        E.require_program(
            build,
            f"{out}/{program}",
            assembler,
            recorded_sha256=digest,
            build198x=builder,
        )
    return len(programs)


def inspect(
    root: Path, fixtures: Any, required_bindings: dict[str, int] | None = None
) -> dict[str, Any]:
    required = REQUIRED_BINDINGS if required_bindings is None else required_bindings
    if not isinstance(fixtures, list) or not all(isinstance(f, dict) for f in fixtures):
        raise ValueError("Selection must be a list of fixture objects")
    names = [f.get("name") for f in fixtures]
    if len(names) != len(required) or set(names) != set(required):
        raise ValueError("Selection must contain " + ", ".join(required) + " once each")
    observations = []
    failures = []
    for fixture in fixtures:
        name = fixture["name"]
        checks = []
        try:
            bindings = fixture["bindings"]
            if not isinstance(bindings, list) or len(bindings) != required[name]:
                raise ValueError(f"Expected {required[name]} declared bindings")
            paths = [binding["path"] for binding in bindings]
            if len(set(paths)) != len(paths):
                raise ValueError("Duplicate source binding")
            record_path = root / fixture["record"]
            raw = record_path.read_bytes()
            record = json.loads(raw)
            if not isinstance(record, dict) or not record:
                raise ValueError("Execution record must be a nonempty object")
            if required_bindings is not None and record.get("status") != "passed":
                raise ValueError("Audit record must describe a passing execution")
            if "recorder" in fixture:
                rebuilt = require_programs(name, fixture["recorder"], record)
            elif not bindings:
                raise ValueError("Fixture names no recorder and binds no input")
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
                    **({"programs_rebuilt": rebuilt} if "recorder" in fixture else {}),
                }
            )
        except (OSError, KeyError, TypeError, ValueError, AssertionError) as error:
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
    parser.add_argument(
        "--audit", action="store_true", help="Check all eight routine-audit records"
    )
    parser.add_argument(
        "--parser", action="store_true", help="Check the three adventure-parser records"
    )
    args = parser.parse_args()
    if args.parser and args.audit:
        parser.error("Choose either --parser or --audit")
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.unlink(missing_ok=True)
    try:
        report = inspect(
            args.root,
            json.loads(
                (
                    PARSER_SELECTION
                    if args.parser
                    else AUDIT_SELECTION
                    if args.audit
                    else args.selection
                ).read_text()
            ),
            PARSER_BINDINGS if args.parser else AUDIT_BINDINGS if args.audit else None,
        )
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
