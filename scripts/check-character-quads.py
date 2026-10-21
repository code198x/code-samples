"""Replay complete named observations; corruption cannot pass by rehashing."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "quads_verify", ROOT / "scripts/verify-character-quads.py"
)
if spec is None or spec.loader is None:
    raise ValueError("Cannot load verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)


def check(c: dict[str, Any], root: Path = ROOT) -> None:
    out = (
        root / c["folder"] / "patterns/assembly/rendering/character-quads/verification"
    )
    record = json.loads((out / "results.json").read_text())
    V.require(
        set(record) == {"machine_id", "sources", "variants", "artifacts"},
        "Incomplete record",
    )
    V.require(record["machine_id"] == c["machine_id"], "Wrong machine")
    V.require(
        set(record["sources"]) == {str(p.relative_to(ROOT)) for p in V.paths(c)},
        "Incomplete bound source set",
    )
    for name, digest in record["sources"].items():
        V.require(V.V.T.sha(root / name) == digest, "Changed source " + name)
    tools = {
        t["tool"]: t
        for t in json.loads(
            (root / V.S.relative_to(ROOT) / "toolchain.json").read_text()
        )
    }
    V.require(set(record["variants"]) == set(V.M.VARIANTS), "Missing completed variant")
    required = set()
    for variant in V.M.VARIANTS:
        r = record["variants"][variant]
        V.require(
            r["emulator_sha256"] == tools[c["binary"]]["binary_sha256"],
            "Wrong emulator",
        )
        V.require(
            r["assembler_sha256"] == tools["asm198x"]["binary_sha256"],
            "Wrong assembler",
        )
        V.require(
            r["glyph_bytes"] == 205 and r["quad_bytes"] > 0,
            "Missing reusable components",
        )
        name = variant + ".json.z"
        V.require(r["observations"] == name, "Wrong observation identity")
        required.add(name)
        observations = json.loads(zlib.decompress((out / name).read_bytes()))
        require_captures = {variant + "-startup.png"} | {
            f"{variant}-{i}.png"
            for i in [0, 734, len(V.cases(variant)) - 1]
            if i < len(V.cases(variant))
        }
        actual = {observations["startup"]["capture"]} | {
            c["capture"] for c in observations["cases"] if "capture" in c
        }
        V.require(actual == require_captures, "Missing native captures")
        for i, captured in enumerate(observations["cases"]):
            if i in [0, 734, len(V.cases(variant)) - 1]:
                V.require("vram" in captured, "Missing complete VRAM")
        required |= require_captures
        V.inspect(c, variant, observations, out)
    V.require(
        record["variants"]["positive"]["fixture_sha256"]
        == record["variants"]["stride-fixed"]["fixture_sha256"],
        "Repair differs from working executable",
    )
    V.require(set(record["artifacts"]) == required, "Incomplete observation set")
    for name, digest in record["artifacts"].items():
        V.require(Path(name).name == name, "Unsafe observation name")
        V.require(V.V.T.sha(out / name) == digest, "Changed observation " + name)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system")
    args = p.parse_args()
    selected = [
        c for c in V.configs() if args.system is None or c["machine_id"] == args.system
    ]
    V.require(bool(selected), "No matching system; nothing checked")
    for c in selected:
        check(c)
        print(c["machine_id"], "retained PASS")
