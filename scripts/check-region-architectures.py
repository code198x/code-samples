"""Validate source-locked adapters against independent memory and pixel models."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def verify(root: Path) -> int:
    root = root.resolve()
    s = importlib.util.spec_from_file_location(
        "adapter_oracle", root / "scripts/verify-region-architectures.py"
    )
    assert s and s.loader
    o = importlib.util.module_from_spec(s)
    s.loader.exec_module(o)
    need = o.T.require
    cs = json.loads(
        (
            root / "cross-platform/patterns/rendering/region-architectures/systems.json"
        ).read_text()
    )
    ids = [c["machine_id"] for c in cs]
    need(bool(ids) and len(ids) == len(set(ids)), "Empty/duplicate adapter inventory")
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
            if r["region_drawing"]["status"] == "executed-native-adapter"
        }
        == set(ids),
        "Adapter qualification differs from evidence",
    )
    for c in cs:
        v = root / c["folder"] / "patterns/assembly/rendering/tile-region/verification"
        r = json.loads((v / "results.json").read_text())
        policy = 4 if c["cpu"] == "m68000" else 1 if c["cpu"] == "sm83" else 0
        need(
            c["flags"] == [129] * 3 + [128] * (15 + policy),
            "Wrong declared call contract",
        )
        need(
            r["status"] == "passed" and r["machine_id"] == c["machine_id"],
            "Wrong execution identity",
        )
        need(r["calls_per_pass"] == 18 + policy, "Wrong call count")
        need(
            r["isolated_rejections"] == (30 if c["cpu"] == "m68000" else 15),
            "Missing isolated rejection runs",
        )
        need(
            r["backends"]
            == (["cpu", "blitter"] if c["cpu"] == "m68000" else ["native"]),
            "Missing backend qualification",
        )
        need(
            set(r["sources"]) == {str(p.relative_to(root)) for p in o.source_paths(c)},
            "Missing source identity",
        )
        for path, h in r["sources"].items():
            need(o.T.sha(root / path) == h, "Changed source: " + path)
        variants = o.variants(c)
        files = {v + ext for v in variants for ext in [".bin", ".json"]} | {
            v + ".png" for v in variants if "reject-" not in v
        }
        need(set(r["files"]) == files, "Missing retained evidence")
        for path, h in r["files"].items():
            need(o.T.sha(v / path) == h, "Changed evidence: " + path)
        expected = o.expected_memory(c)
        pixels = o.expected_pixels(c)
        for label in variants:
            d = json.loads((v / (label + ".json")).read_text())
            raw = (v / (label + ".bin")).read_bytes()
            need(
                len(raw) == c["length"] + 32
                and o.hashlib.sha256(raw).hexdigest() == d["memory_sha256"],
                "Wrong memory identity/length",
            )
            flags = o.expected_flags(c, label)
            if "unsafe-destination" in label:
                flags[12] = 129
            need(d["flags"] == flags, "Unfinished or wrong call acceptance")
            broken = any(
                x in label for x in ["wrong-layout", "unsafe-destination", "short"]
            )
            if broken:
                need(raw != expected, "Broken control passed memory oracle")
                if "unsafe-destination" not in label:
                    need(
                        o.PNG.raster(v / (label + ".png")) != pixels,
                        "Broken control passed pixel oracle",
                    )
            else:
                need(raw == expected, "Wrong complete memory/guards")
                if "reject-" not in label:
                    need(
                        d["context"][:6] == [0, 1, 0, 0, 2, 1], "Request bytes changed"
                    )
                    need(
                        o.PNG.raster(v / (label + ".png")) == pixels,
                        "Wrong independent native pixels",
                    )
            if "reject-" not in label:
                need(
                    d["capture_sha256"] == o.T.sha(v / (label + ".png")),
                    "Wrong capture identity",
                )
        if c["cpu"] == "m68000":
            need(
                (v / "positive.bin").read_bytes() == (v / "blitter.bin").read_bytes(),
                "CPU/blitter output differs",
            )
    return len(ids)


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print("Verified native region adapters on", verify(a.root), "systems")
