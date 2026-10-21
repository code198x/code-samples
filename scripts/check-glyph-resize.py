"""Validate retained execution, guards, raster captures and source identities."""

from __future__ import annotations

import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "glyph_verify", ROOT / "scripts/verify-glyph-resize.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
require = V.require


def check(c: dict[str, Any], folder: Path | None = None) -> int:
    folder = (
        folder
        or ROOT / c["folder"] / "patterns/assembly/rendering/glyph-resize/verification"
    )
    result = json.loads((folder / "results.json").read_text())
    require(result["machine_id"] == c["machine_id"], "Wrong machine")
    require(
        result["sources"]
        == {str(f.relative_to(ROOT)): V.V.T.sha(f) for f in V.sources(c)},
        "Source binding differs",
    )
    tools = {t["tool"]: t for t in json.loads((V.S / "toolchain.json").read_text())}
    require(
        result["tools"]
        == {n: tools[n]["binary_sha256"] for n in [c["binary"], "asm198x"]},
        "Tool binding differs",
    )
    require(set(result["variants"]) == set(V.B.VARIANTS), "Missing variant")
    for name, digest in result["artifacts"].items():
        require(Path(name).name == name, "Escaped artifact")
        require(V.V.T.sha(folder / name) == digest, "Artifact checksum differs")
    used = set()
    total = 0

    def frame(rec: dict[str, Any], rows: bytes) -> None:
        used.update([rec["memory"], rec["capture"]])
        grid = V.grid_for(c, rows)
        require(
            zlib.decompress((folder / rec["memory"]).read_bytes())
            == V.BASE.M.P.packed(c, grid),
            "Retained bitmap differs",
        )
        require(
            V.V.PNG.raster(folder / rec["capture"]) == V.BASE.M.P.frame(c, grid),
            "Native frame differs",
        )

    for variant, value in result["variants"].items():
        fault = variant == "sampling-fault"
        startup = value["startup"]
        width, height = (8, 4) if variant == "customise" else (5, 7)
        rows = V.BASE.M.DEFAULT[304:312]
        expected = V.M.resize(rows, width, height, crop_fault=fault)
        require(
            startup["rows"] == rows.hex()
            and startup["width"] == width
            and startup["height"] == height
            and startup["output"] == expected.hex()
            and startup["mailbox"] == "00ef",
            "Wrong startup",
        )
        frame(startup, expected)
        total += 1
        if variant == "customise":
            continue
        cases = (
            V.M.cases()
            if variant == "positive"
            else [
                {
                    "id": "sampling",
                    "width": 5,
                    "height": 7,
                    "rows": rows.hex(),
                    "overlap": 0,
                }
            ]
        )
        require(len(value["cases"]) == len(cases) > 0, "Missing cases")
        for i, (case, rec) in enumerate(zip(cases, value["cases"], strict=True)):
            require(rec["case"] == case, "Wrong case")
            source = c["data"] + 64
            dest = source + case["overlap"] if case["overlap"] else c["data"] + 128
            if case["overlap"] == 8:
                dest = source
            if case.get("invalid_side") == "source":
                source = case["invalid_address"]
            if case.get("invalid_side") == "dest":
                dest = case["invalid_address"]
            require((rec["source"], rec["dest"]) == (source, dest), "Wrong allocations")
            request = V.input_bytes(c, source, dest, case["width"], case["height"])
            context = bytes.fromhex(rec["context"])
            accepted = (
                1 <= case["width"] <= 8
                and 1 <= case["height"] <= 8
                and source <= 65528
                and dest <= 65528
            )
            require(
                context[:6] == request[:6] and context[6] == int(accepted),
                "Transform status differs",
            )
            ram = bytearray((j * 19 + 71) & 255 for j in range(192))
            if source < 65529:
                ram[source - c["data"] : source - c["data"] + 8] = bytes.fromhex(
                    case["rows"]
                )
            require(rec["before"] == ram.hex(), "Guard baseline differs")
            transformed = (
                V.M.resize(
                    bytes.fromhex(case["rows"]),
                    case["width"],
                    case["height"],
                    crop_fault=fault,
                )
                if accepted
                else None
            )
            if accepted:
                ram[dest - c["data"] : dest - c["data"] + 8] = transformed
            require(rec["after"] == ram.hex(), "Glyph/guard/source memory differs")
            require(
                rec["guards"]
                == ["5a" * 8, "5a" * 8]
                + (["5a" * 2] * 2 if c["cpu"] == "6502" else []),
                "Scratch neighbour changed",
            )
            require(
                rec["mailbox"] == "00ef" and 0 < rec["observed_frames"] <= 1024,
                "Call incomplete",
            )
            need = accepted and (
                i < 8 or (i < 32 and i % 4 == 1) or variant != "positive"
            )
            require(
                ("capture" in rec) == need and ("memory" in rec) == need,
                "Missing required frame",
            )
            if need:
                frame(rec, transformed)
            if fault:
                good = V.M.resize(
                    bytes.fromhex(case["rows"]), case["width"], case["height"]
                )
                require(
                    good != transformed and rec["correct_output"] == good.hex(),
                    "Fault passed as good",
                )
            total += 1
        costs = value["costs"]
        require(
            costs["component_bytes"] > 0
            and costs["context_bytes"] == 32
            and costs["output_bytes"] == 8
            and costs["input_reads"] == 8
            and costs["clear_writes"] == 8,
            "Missing costs",
        )
    require(used == set(result["artifacts"]), "Missing or unreferenced artifact")
    require(
        result["variants"]["positive"]["fixture_sha256"]
        == result["variants"]["sampling-fixed"]["fixture_sha256"],
        "Repair differs",
    )
    return total


def main() -> None:
    total = 0
    for c in json.loads((V.S / "systems.json").read_text()):
        n = check(c)
        total += n
        print(c["machine_id"], n, "retained observations replayed")
    require(total > 0, "No observations")
    print(total, "retained observations PASS")


if __name__ == "__main__":
    main()
