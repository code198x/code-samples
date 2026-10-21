"""Validate retained execution, guards, raster captures and source identities."""

from __future__ import annotations

import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "glyph_verify", ROOT / "scripts/verify-glyph-transform.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
require = V.require


def check(c: dict[str, Any], folder: Path | None = None) -> int:
    folder = (
        folder
        or ROOT
        / c["folder"]
        / "patterns/assembly/rendering/glyph-transform/verification"
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
        fault = variant == "rotation-fault"
        startup = value["startup"]
        flags = 4 if variant == "customise" else 1
        rows = V.BASE.M.DEFAULT[304:312]
        expected = V.M.transform(rows, flags, transpose_fault=fault)
        require(
            startup["rows"] == rows.hex()
            and startup["flags"] == flags
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
            else [{"id": "rotation", "flags": 1, "rows": rows.hex(), "overlap": 0}]
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
            request = V.input_bytes(c, source, dest, case["flags"])
            context = bytes.fromhex(rec["context"])
            accepted = case["flags"] <= 7 and source <= 65528 and dest <= 65528
            require(
                context[:5] == request[:5] and context[5] == int(accepted),
                "Transform status differs",
            )
            ram = bytearray((j * 19 + 71) & 255 for j in range(192))
            if source < 65529:
                ram[source - c["data"] : source - c["data"] + 8] = bytes.fromhex(
                    case["rows"]
                )
            require(rec["before"] == ram.hex(), "Guard baseline differs")
            transformed = (
                V.M.transform(
                    bytes.fromhex(case["rows"]), case["flags"], transpose_fault=fault
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
                good = V.M.transform(bytes.fromhex(case["rows"]), case["flags"])
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
        == result["variants"]["rotation-fixed"]["fixture_sha256"],
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
