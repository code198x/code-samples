"""Validate all six retained map-query records; empty or altered data fails."""

from __future__ import annotations

import json
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]


def load_verifier() -> ModuleType:
    import importlib.util

    spec = importlib.util.spec_from_file_location(
        "map_gaps", ROOT / "scripts/verify-remaining-assembly-maps.py"
    )
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


V = load_verifier()


def load_bytes() -> ModuleType:
    import importlib.util

    spec = importlib.util.spec_from_file_location(
        "map_bytes", ROOT / "scripts/evidence_bytes.py"
    )
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


E = load_bytes()


def fixture(system: str, assembler: str, variant: str) -> None:
    """Build one machine's variant through the recorder's build()."""
    config = next(c for c in json.loads(V.CONFIG.read_text()) if c["system"] == system)
    V.build(config, assembler, variant)


SYSTEMS = {
    "msx",
    "dragon-32",
    "mattel-aquarius",
    "spectravideo-svi-328",
    "amstrad-cpc",
    "atari-800xl",
}


def validate(c: dict, r: dict) -> None:
    V.T.require(
        r["status"] == "passed" and r["language"] == "assembly",
        "Wrong qualification or language",
    )
    V.T.require(
        r["machine"] == c["system"] and r["configuration"] == c,
        "Wrong machine or RAM layout",
    )
    observations = r["observations"]
    V.T.require(
        set(observations)
        == {"positive", "closed-exit", "wrong-stride", "write-without-valid"},
        "Missing variant",
    )
    V.T.require(set(r["fixtures"]) == set(observations), "Missing fixture hash")
    V.T.require(len(set(r["fixtures"].values())) == 4, "Fixtures were not distinct")
    # The record is stale when its programs' bytes change, not its sources' text.
    for variant, digest in r["fixtures"].items():
        E.require_program(
            E.function(
                Path(__file__),
                "fixture",
                (c["system"], E.ASSEMBLER, variant),
                V.folder(c),
                (f"build/{variant}/fixture.bin",),
            ),
            f"build/{variant}/fixture.bin",
            r["assembler_sha256"],
            recorded_sha256=digest,
        )
    for name, raw in observations.items():
        V.T.require(len(raw) == 44 and raw[-1] == 239, "Caller did not complete")
        expected = bytearray(V.V.expected())
        if name == "closed-exit":
            expected[40] = 5
        V.T.require(
            (bytes(raw) == bytes(expected)) == (name in ("positive", "closed-exit")),
            "Oracle outcome changed",
        )
    V.T.require(observations["wrong-stride"][7] == 2, "Wrong stride symptom")
    V.T.require(observations["write-without-valid"][37] == 0, "Wrong write symptom")
    V.T.require(
        r["customisation"]
        == {
            "changed_fixture_bytes": 1,
            "normal_property": 4,
            "closed_exit_property": 5,
            "property_table_bytes": 4,
        },
        "Customisation result or footprint changed",
    )
    for digest in [
        r["assembler_sha256"],
        r["emulator_sha256"],
        *r["fixtures"].values(),
    ]:
        V.T.require(
            len(digest) == 64 and all(c in "0123456789abcdef" for c in digest),
            "Invalid tool/fixture digest",
        )
    V.T.require("CPU/RAM evidence only" in r["limits"], "Missing evidence limits")


def main() -> None:
    configs = json.loads(V.CONFIG.read_text())
    V.T.require(
        len(configs) == 6 and {c["system"] for c in configs} == SYSTEMS,
        "Incomplete or duplicate inventory",
    )
    for c in configs:
        validate(c, json.loads((V.folder(c) / "verification/results.json").read_text()))
    print("PASS 6 assembly map ports; 24 completed native executions and program bytes")


if __name__ == "__main__":
    main()
