"""Validate every retained BASIC map, region and pixel/box evidence route."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OLD = {
    "acorn-atom",
    "amstrad-cpc",
    "atari-800xl",
    "commodore-pet",
    "commodore-vic-20",
    "dragon-32",
    "mattel-aquarius",
    "msx",
    "oric-atmos",
    "spectravideo-svi-328",
}
NEW = {
    "acorn-bbc-micro",
    "acorn-electron",
    "commodore-64",
    "memotech-mtx",
    "sinclair-zx-spectrum",
}
PIXELS = {"acorn-bbc-micro", "acorn-electron", "amstrad-cpc", "sinclair-zx-spectrum"}
EXPECTED = (
    {(s, "tile-map") for s in NEW}
    | {(s, "text-region") for s in OLD | NEW}
    | {(s, "pixel-box") for s in PIXELS}
)


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check_record(root: Path, route: dict) -> None:
    folder = root / route["folder"]
    record = json.loads((root / route["record"]).read_text())
    require(record["status"] == "passed", "Native run did not pass")
    require(
        (record["system"], record["kind"]) == (route["system"], route["kind"]),
        "Record route mismatch",
    )
    require(
        record["independent_full_raster_match"] is True,
        "Missing independent raster match",
    )
    require(bool(record["firmware"]), "Missing firmware identity")
    require(
        record["emulator_sha256"] == record["producer"]["executable_sha256"],
        "Producer mismatch",
    )
    require(record["producer"]["version"] == "0.44.1", "Unexpected emulator version")
    require(
        record["producer"]["before_lock_sha256"]
        == record["producer"]["after_lock_sha256"]
        == record["producer"]["committed_lock_sha256"],
        "Producer lock changed",
    )
    expected_sources = {str(p.relative_to(root)) for p in folder.glob("*.bas")}
    require(
        set(record["sources"]) == expected_sources,
        "Incomplete maintained source coverage",
    )
    for path, sha in record["sources"].items():
        require(digest(root / path) == sha, "Changed source: " + path)
    require(bool(record["callers"]), "Missing executed caller inputs")
    for path, sha in record["callers"].items():
        require(digest(root / path) == sha, "Changed executed caller: " + path)
    observer = (
        "verify-basic-pixel-boxes.py"
        if route["kind"] == "pixel-box"
        else "verify-basic-map-regions.py"
    )
    for file, key in [
        (observer, "observer_sha256"),
        ("basic_rendering_transport.py", "transport_sha256"),
        ("verify-game-loops.py", "native_transport_sha256"),
    ]:
        require(
            digest(root / "scripts" / file) == record[key],
            "Changed observer/transport: " + file,
        )
    if route["kind"] != "pixel-box":
        require(
            digest(root / "scripts/verify-tilemaps.py") == record["generator_sha256"],
            "Changed map oracle generator",
        )
        require(record["wrong_stride_rejected"] is True, "Wrong stride not rejected")
        if route["kind"] == "tile-map":
            require(
                set(record["case_counts"]) == {"queries", "writes", "pixels"}
                and all(n >= 10 for n in record["case_counts"].values()),
                "Incomplete map cases",
            )
        else:
            require(record["case_counts"] >= 9, "Incomplete region cases")
        labels = (
            {"checked", "reference", "wrong-stride"}
            if route["kind"] == "text-region"
            else {
                "demo",
                "wrong-stride",
                "queries",
                "queries-reference",
                "writes",
                "writes-reference",
                "pixels",
                "pixels-reference",
            }
        )
    else:
        require(record["bounds_cases"] >= 10, "Incomplete bounds cases")
        for key in [
            "wrong_units_rejected",
            "omitted_draw_rejected",
            "edge_and_one_cell_boxes",
        ]:
            require(record[key] is True, "Missing failure/edge control: " + key)
        labels = {
            "demo",
            "reference",
            "omitted-draw",
            "wrong-units",
            "bounds",
            "bounds-reference",
            "edges",
            "edges-reference",
        }
    require(
        {n + ".png" for n in labels} <= set(record["captures"]),
        "Missing native captures",
    )
    for name, sha in record["captures"].items():
        path = folder / "verification" / name
        require(
            path.read_bytes().startswith(b"\x89PNG\r\n\x1a\n") and digest(path) == sha,
            "Changed native capture: " + name,
        )
    for a, b in (
        [("checked", "reference")]
        if route["kind"] == "text-region"
        else [
            ("demo", "reference"),
            ("bounds", "bounds-reference"),
            ("edges", "edges-reference"),
        ]
        if route["kind"] == "pixel-box"
        else [
            ("queries", "queries-reference"),
            ("writes", "writes-reference"),
            ("pixels", "pixels-reference"),
        ]
    ):
        require(
            record["captures"][a + ".png"] == record["captures"][b + ".png"],
            "Retained positive captures differ",
        )
    good = "demo.png" if route["kind"] != "text-region" else "reference.png"
    bad = (
        ["omitted-draw.png", "wrong-units.png"]
        if route["kind"] == "pixel-box"
        else ["wrong-stride.png"]
    )
    require(
        all(record["captures"][good] != record["captures"][b] for b in bad),
        "Negative capture passed",
    )
    if route["system"] == "sinclair-zx-spectrum":
        require(
            record["builder_producer"]["version"] == "0.2.13",
            "Wrong BASIC tape builder",
        )


def check(root: Path = ROOT) -> int:
    manifest = json.loads((root / "docs/basic-rendering.json").read_text())
    routes = manifest["routes"]
    require(
        len(routes) == len(EXPECTED)
        and {(r["system"], r["kind"]) for r in routes} == EXPECTED,
        "Incomplete or duplicate route inventory",
    )
    for route in routes:
        check_record(root, route)
    return len(routes)


if __name__ == "__main__":
    print(
        f"PASS {check()} BASIC rendering routes; source, caller, observer, producer, firmware and capture bindings intact"
    )
