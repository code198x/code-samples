"""Verify retained native VDP region evidence, independently of guest execution."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(path: Path):
    s = importlib.util.spec_from_file_location("region_evidence", path)
    assert s and s.loader
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


def verify(root: Path) -> int:
    oracle = load(root / "scripts/verify-tile-regions.py")
    configs = json.loads(
        (
            root / "cross-platform/patterns/rendering/tile-region/systems.json"
        ).read_text()
    )
    inventory = json.loads((root / "docs/tilemaps/coverage.json").read_text())[
        "systems"
    ]
    registry = json.loads((root / "docs/capability-coverage.json").read_text())[
        "registry"
    ]["systems"]
    require = oracle.T.require
    require(
        {r["machine_id"] for r in inventory} == {r["machine_id"] for r in registry},
        "Incomplete registry",
    )
    ids = [c["machine_id"] for c in configs]
    require(
        bool(ids) and len(ids) == len(set(ids)), "Empty/duplicate region configuration"
    )
    qualified = {
        r["machine_id"]
        for r in inventory
        if r["region_drawing"]["status"] == "executed-native-vdp"
    }
    require(qualified == set(ids), "Region qualification inventory differs")
    for cfg in configs:
        row = next(r for r in inventory if r["machine_id"] == cfg["machine_id"])
        field = row["region_drawing"]
        folder = root / cfg["folder"] / "patterns/assembly/rendering/tile-region"
        v = folder / "verification"
        record = json.loads((v / "results.json").read_text())
        require(
            record["status"] == "passed" and record["machine_id"] == cfg["machine_id"],
            "Missing execution",
        )
        require(
            field["record"] == str((v / "results.json").relative_to(root))
            and field["mode"] == cfg["mode"],
            "Widened qualification",
        )
        require(
            record["case_count"] == 22
            and record["readback_bytes"] == cfg["dump_length"],
            "Missing executed cases",
        )
        require(
            set(record["completed_negative_controls"])
            == {"wrong-stride", "unsafe-destination"},
            "Missing controls",
        )
        expected_sources = {
            str((folder / "demo.asm").relative_to(root)),
            "cross-platform/patterns/rendering/tile-region/region.inc",
            "cross-platform/patterns/rendering/tile-region/systems.json",
            "cross-platform/patterns/rendering/tile-region/build.py",
            "cross-platform/patterns/rendering/tile-map/z80.inc",
            "scripts/verify-tile-regions.py",
            "scripts/verify-tilemaps.py",
            "scripts/verify-game-loops.py",
        }
        require(set(record["sources"]) == expected_sources, "Missing source identities")
        for path, digest in record["sources"].items():
            require(oracle.T.sha(root / path) == digest, "Changed source: " + path)
        for variant in ["positive", "wrong-stride", "unsafe-destination"]:
            d = json.loads((v / (variant + ".json")).read_text())
            png = v / (variant + ".png")
            require(d["capture_sha256"] == oracle.T.sha(png), "Changed capture")
            require(
                len(d["flags"]) == 23 and d["flags"][0] == 239, "Unfinished diagnostic"
            )
            require(len(d["vram"]) == cfg["dump_length"], "Incomplete VDP readback")
            if variant == "positive":
                require(d["flags"] == oracle.expected_flags(), "Wrong acceptance flags")
                require(
                    d["vram"] == oracle.expected_vram(cfg), "Wrong VDP readback/guard"
                )
                require(
                    oracle.PNG.raster(png) == oracle.expected_pixels(cfg),
                    "Wrong rendered pixels",
                )
            else:
                require(
                    d["vram"] != oracle.expected_vram(cfg),
                    "Negative control passed VDP oracle",
                )
                if variant == "wrong-stride":
                    require(
                        oracle.PNG.raster(png) != oracle.expected_pixels(cfg),
                        "Negative control passed pixel oracle",
                    )
    bitmap_ids = (
        {
            c["machine_id"]
            for c in json.loads(
                (
                    root
                    / "cross-platform/patterns/rendering/bitmap-regions/systems.json"
                ).read_text()
            )
        }
        if (
            root / "cross-platform/patterns/rendering/bitmap-regions/systems.json"
        ).exists()
        else set()
    )
    architecture_path = (
        root / "cross-platform/patterns/rendering/region-architectures/systems.json"
    )
    architecture_ids = (
        {c["machine_id"] for c in json.loads(architecture_path.read_text())}
        if architecture_path.exists()
        else set()
    )
    cell_path = (
        root / "cross-platform/patterns/rendering/character-regions/systems.json"
    )
    cell_ids = (
        {c["machine_id"] for c in json.loads(cell_path.read_text())}
        if cell_path.exists()
        else set()
    )
    for row in inventory:
        if row["machine_id"] not in ids:
            require(
                row["region_drawing"]["status"]
                == (
                    "executed-cpu-bitmap"
                    if row["machine_id"] in bitmap_ids
                    else "executed-native-adapter"
                    if row["machine_id"] in architecture_ids
                    else "executed-cell-region"
                    if row["machine_id"] in cell_ids
                    else "not-yet-qualified"
                ),
                "Unexecuted machine promoted",
            )
    return len(ids)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print("Verified native regions on", verify(a.root), "machines")


if __name__ == "__main__":
    main()
