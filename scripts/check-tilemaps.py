"""Validate retained map evidence; this does not rerun the guest machines.

Native routes rebuild each diagnostic fixture with the pinned Asm198x release
and compare its bytes with the record. BASIC routes compare the typed demo with
the record. Recorder scripts are provenance; editing them does not make the
evidence stale.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


E = module("tilemap_bytes", ROOT / "scripts/evidence_bytes.py")
BUILD = ROOT / "cross-platform/patterns/rendering/tile-map/build.py"


def require_program(row: dict, record: dict, folder: Path) -> None:
    """Rebuild or re-read the recorded program and compare it with the record."""
    if row["kind"] == "native-byte-map":
        output = "build/fixture.bin"
        E.require_program(
            E.function(
                BUILD,
                "build",
                (row["machine_id"], E.ASSEMBLER),
                # build.py always writes beside the committed sources.
                ROOT / row["implementation"],
                (output,),
            ),
            output,
            record["assembler_sha256"],
            recorded_sha256=record["fixture_sha256"],
        )
        return
    # The recorder types demo.bas, wrapped in its own completion and hold lines.
    demo = f"{row['implementation']}/demo.bas"
    require(demo in record["sources"], f"{row['machine_id']}: missing typed program")
    source = (folder / "demo.bas").read_text()
    E.require_typed(source, record["sources"][demo], demo)
    require(
        source[source.index("1000 E=") :] == (folder / "routines.bas").read_text(),
        f"{row['machine_id']}: distributed routines differ from the typed caller",
    )


def verify(root: Path) -> dict:
    inventory = json.loads((root / "docs/tilemaps/coverage.json").read_text())
    registry = json.loads((root / "docs/capability-coverage.json").read_text())[
        "registry"
    ]["systems"]
    expected_ids = [s["machine_id"] for s in registry]
    ids = [s["machine_id"] for s in inventory["systems"]]
    require(
        bool(ids) and len(ids) == len(set(ids)), "Empty/duplicate tile-map inventory"
    )
    require(
        set(ids) == set(expected_ids),
        "Tile-map inventory differs from complete registry",
    )
    natives = json.loads(
        (root / "cross-platform/patterns/rendering/tile-map/native.json").read_text()
    )
    native_ids = [s["machine_id"] for s in natives]
    require(len(native_ids) == len(set(native_ids)), "Duplicate native configuration")
    basic = module("basic_map_oracle", root / "scripts/verify-tilemaps.py")
    native = module("native_map_oracle", root / "scripts/verify-native-tilemaps.py")
    counts = {"basic": 0, "native": 0}
    for row in inventory["systems"]:
        name = row["machine_id"]
        folder = root / row["implementation"]
        record = json.loads((root / row["record"]).read_text())
        require(record["status"] == "passed", f"{name}: execution did not pass")
        require(bool(record["sources"]), f"{name}: missing source identities")
        if row["kind"] == "native-byte-map":
            counts["native"] += 1
            require(name in native_ids, f"{name}: missing native configuration")
            require(
                row["status"] == "executed-cpu-ram"
                and row["stock_loader"] == "not-qualified-by-synthetic-reset-fixture",
                f"{name}: widened native claim",
            )
            require(record["machine_id"] == name, f"{name}: wrong machine record")
            expected = list(native.expected())
            require(
                record["actual"] == record["expected"] == expected,
                f"{name}: wrong positive output",
            )
            positive = json.loads((folder / "verification/positive.json").read_text())[
                "bytes"
            ]
            wrong = json.loads((folder / "verification/wrong-stride.json").read_text())[
                "bytes"
            ]
            require(positive == expected, f"{name}: missing positive observations")
            require(
                len(wrong) == 44 and wrong[-1] == 239 and wrong != expected,
                f"{name}: negative control did not finish and fail",
            )
            require(
                record["wrong_stride_rejected"]
                and record["completed_negative_control"],
                f"{name}: missing failure control",
            )
            write_wrong = json.loads(
                (folder / "verification/write-without-valid.json").read_text()
            )["bytes"]
            require(
                len(write_wrong) == 44
                and write_wrong[-1] == 239
                and write_wrong != expected,
                f"{name}: write failure control did not finish and fail",
            )
            require(
                record["write_without_valid_rejected"],
                f"{name}: missing write failure control",
            )
        elif row["kind"] == "basic-numeric-map":
            counts["basic"] += 1
            require(
                row["status"] == "executed-basic"
                and row["stock_loader"] == "stock-interpreter-keyboard",
                f"{name}: widened BASIC claim",
            )
            require(
                record["system"] == row["implementation"].split("/")[0],
                f"{name}: wrong dialect record",
            )
            require(
                set(record["case_counts"]) == {"queries", "writes", "pixels", "region"}
                and all(n > 0 for n in record["case_counts"].values()),
                f"{name}: empty case group",
            )
            require(
                record["demo_matches_independent_text_reference"]
                and record["wrong_stride_rejected"],
                f"{name}: missing output/negative evidence",
            )
            required = {
                f"{label}.png"
                for label in [
                    "demo",
                    "reference",
                    "wrong-stride",
                    "queries",
                    "queries-reference",
                    "writes",
                    "writes-reference",
                    "pixels",
                    "pixels-reference",
                    "region",
                    "region-reference",
                ]
            }
            require(
                set(record["captures"]) == required, f"{name}: missing capture group"
            )
            for file, digest in record["captures"].items():
                require(
                    sha(folder / "verification" / file) == digest,
                    f"{name}: changed capture {file}",
                )
            for actual, reference in [("demo", "reference")] + [
                (v, v + "-reference") for v in ["queries", "writes", "pixels", "region"]
            ]:
                require(
                    basic.raster(folder / "verification" / f"{actual}.png")
                    == basic.raster(folder / "verification" / f"{reference}.png"),
                    f"{name}: retained output mismatch",
                )
            require(
                basic.raster(folder / "verification/wrong-stride.png")
                != basic.raster(folder / "verification/reference.png"),
                f"{name}: negative picture passed",
            )
        else:
            raise ValueError(f"{name}: unknown evidence kind")
        require_program(row, record, folder)
        require(
            row["native_graphics"] == "not-qualified-by-map-query-evidence",
            f"{name}: unproved graphics claim",
        )
    require(counts["basic"] > 0 and counts["native"] > 0, "Empty implementation branch")
    require(
        set(native_ids)
        == {
            r["machine_id"]
            for r in inventory["systems"]
            if r["kind"] == "native-byte-map"
        },
        "Missing/extra native machine",
    )
    return counts


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    args = p.parse_args()
    print(verify(args.root))


if __name__ == "__main__":
    main()
