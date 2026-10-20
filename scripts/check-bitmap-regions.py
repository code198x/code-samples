"""Validate retained bitmap-region evidence, including isolated rejected calls."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def verify(root: Path) -> int:
    root = root.resolve()
    spec = importlib.util.spec_from_file_location(
        "bitmap_oracle", root / "scripts/verify-bitmap-regions.py"
    )
    assert spec and spec.loader
    oracle = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(oracle)
    require = oracle.T.require
    shared = root / "cross-platform/patterns/rendering/bitmap-regions"
    configs = json.loads((shared / "systems.json").read_text())
    ids = [c["machine_id"] for c in configs]
    require(
        bool(ids) and len(ids) == len(set(ids)), "Empty or duplicate bitmap inventory"
    )
    inventory = json.loads((root / "docs/tilemaps/coverage.json").read_text())[
        "systems"
    ]
    registry = json.loads((root / "docs/capability-coverage.json").read_text())[
        "registry"
    ]["systems"]
    require(
        {r["machine_id"] for r in inventory} == {r["machine_id"] for r in registry},
        "Incomplete system inventory",
    )
    require(
        {
            r["machine_id"]
            for r in inventory
            if r["region_drawing"]["status"] == "executed-cpu-bitmap"
        }
        == set(ids),
        "Bitmap qualification differs from implementations",
    )
    variants = (
        ["positive"]
        + [f"reject-{i}" for i in range(3, 18)]
        + ["wrong-layout", "unsafe-destination"]
    )
    files = {v + ext for v in variants for ext in [".bin", ".json"]} | {
        v + ".png" for v in ["positive", "wrong-layout", "unsafe-destination"]
    }
    for cfg in configs:
        folder = root / cfg["folder"] / "patterns/assembly/rendering/tile-region"
        v = folder / "verification"
        record = json.loads((v / "results.json").read_text())
        require(
            record["status"] == "passed" and record["machine_id"] == cfg["machine_id"],
            "Wrong completion identity",
        )
        require(
            record["calls"] == 18 and record["isolated_rejections"] == 15,
            "Incomplete case counts",
        )
        required = {str(p.relative_to(root)) for p in oracle.sources(cfg)}
        require(set(record["sources"]) == required, "Missing source identity")
        for path, digest in record["sources"].items():
            require(oracle.T.sha(root / path) == digest, "Changed source: " + path)
        require(set(record["files"]) == files, "Missing evidence file")
        for path, digest in record["files"].items():
            require(oracle.T.sha(v / path) == digest, "Changed evidence: " + path)
        expected = oracle.expected_memory(cfg)
        for variant in variants:
            item = json.loads((v / (variant + ".json")).read_text())
            raw = (v / (variant + ".bin")).read_bytes()
            require(
                len(item["flags"]) == 19 and item["flags"][0] == 239,
                "Unfinished execution",
            )
            require(
                len(raw) == cfg["length"] + 16
                and oracle.hashlib.sha256(raw).hexdigest() == item["memory_sha256"],
                "Invalid memory dump",
            )
            if variant == "positive":
                require(item["flags"] == [239] + cfg["flags"], "Wrong call acceptance")
                require(raw == expected, "Wrong complete bitmap or guard")
                require(
                    oracle.PNG.raster(v / "positive.png")
                    == oracle.expected_pixels(cfg),
                    "Wrong native pixels",
                )
            elif variant.startswith("reject-"):
                n = int(variant.split("-")[1])
                flags = [239] + [129] * 3 + [0] * 15
                flags[n + 1] = 128
                require(item["flags"] == flags, "Isolated rejection did not complete")
                require(raw == expected, "Rejected call changed bitmap or guard")
            else:
                require(
                    all(x in (128, 129) for x in item["flags"][1:]),
                    "Unexecuted negative control",
                )
                require(raw != expected, "Broken control passed memory oracle")
                if variant == "wrong-layout":
                    require(
                        oracle.PNG.raster(v / (variant + ".png"))
                        != oracle.expected_pixels(cfg),
                        "Wrong layout passed pixels",
                    )
        for variant in ["positive", "wrong-layout", "unsafe-destination"]:
            item = json.loads((v / (variant + ".json")).read_text())
            require(
                item["capture_sha256"] == oracle.T.sha(v / (variant + ".png")),
                "Capture identity differs",
            )
    return len(ids)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print("Verified bitmap regions on", verify(a.root), "machines")
