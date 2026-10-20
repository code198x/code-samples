"""Check source-locked native cell-region execution, complete memory and pixels."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def verify(root: Path) -> int:
    root = root.resolve()
    spec = importlib.util.spec_from_file_location(
        "cell_oracle", root / "scripts/verify-character-regions.py"
    )
    assert spec and spec.loader
    oracle = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(oracle)
    need = oracle.T.require
    configs = json.loads(
        (
            root / "cross-platform/patterns/rendering/character-regions/systems.json"
        ).read_text()
    )
    ids = [c["machine_id"] for c in configs]
    need(bool(ids) and len(ids) == len(set(ids)), "Empty/duplicate cell inventory")
    inventory = json.loads((root / "docs/tilemaps/coverage.json").read_text())[
        "systems"
    ]
    registry = json.loads((root / "docs/capability-coverage.json").read_text())[
        "registry"
    ]["systems"]
    need(
        {r["machine_id"] for r in inventory} == {r["machine_id"] for r in registry},
        "Incomplete registry",
    )
    need(
        {
            r["machine_id"]
            for r in inventory
            if r["region_drawing"]["status"] == "executed-cell-region"
        }
        == set(ids),
        "Cell qualification differs from evidence",
    )
    for c in configs:
        out = (
            root / c["folder"] / "patterns/assembly/rendering/tile-region/verification"
        )
        r = json.loads((out / "results.json").read_text())
        need(
            r["status"] == "passed" and r["machine_id"] == c["machine_id"],
            "Wrong execution identity",
        )
        need(r["calls"] == 18 and r["isolated_rejections"] == 15, "Wrong case count")
        need(
            set(r["sources"]) == {str(p.relative_to(root)) for p in oracle.sources(c)},
            "Missing source identity",
        )
        for path, digest in r["sources"].items():
            need(oracle.T.sha(root / path) == digest, "Changed source: " + path)
        files = {v + ext for v in oracle.variants() for ext in [".bin", ".json"]} | {
            v + ".png" for v in ["positive", "wrong-layout", "unsafe-destination"]
        }
        need(set(r["files"]) == files, "Missing retained evidence")
        for path, digest in r["files"].items():
            need(oracle.T.sha(out / path) == digest, "Changed evidence: " + path)
        oracle.validate(c, out)
    return len(ids)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print("Verified native cell regions on", verify(a.root), "systems")
