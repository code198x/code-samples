"""Recompute expectations from logical glyphs, not hashes or recorded pass flags."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "tms_verify", ROOT / "scripts/verify-tms-glyphs.py"
)
if spec is None or spec.loader is None:
    raise ValueError("Cannot load maintained verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
M = V.M
require = V.require


def check(c: dict[str, Any], root: Path = ROOT) -> None:
    out = root / c["folder"] / "patterns/assembly/rendering/custom-glyphs/verification"
    record = json.loads((out / "results.json").read_text())
    require(
        set(record) == {"machine_id", "variants", "sources", "artifacts"},
        "Incomplete evidence record",
    )
    require(record["machine_id"] == c["machine_id"], "Wrong machine")
    required = {str(p.relative_to(ROOT)) for p in V.paths(c)}
    require(set(record["sources"]) == required, "Source set incomplete")
    for name, digest in record["sources"].items():
        require(V.T.sha(root / name) == digest, "Source changed: " + name)
    tools = {
        t["tool"]: t
        for t in json.loads(
            (root / V.S.relative_to(ROOT) / "toolchain.json").read_text()
        )
    }
    require(
        set(record["variants"]) == set(M.VARIANTS), "Missing completed build variant"
    )
    required_artifacts = set()
    for variant in M.VARIANTS:
        result = record["variants"][variant]
        require(
            result["emulator_sha256"] == tools[c["binary"]]["binary_sha256"],
            "Wrong emulator",
        )
        require(
            result["assembler_sha256"] == tools["asm198x"]["binary_sha256"],
            "Wrong assembler",
        )
        require(
            result["kernel_bytes"] == (205 if variant != "wrong-slot" else 206),
            "Unexpected kernel storage size",
        )
        require(result["source_address"] == c["ram"] + 640, "Wrong source allocation")
        require(
            0 < result["bulk_address"] < c["size"] - 2040,
            "Bulk source outside original ROM",
        )
        initial = f"{variant}-initial.dat.z"
        required_artifacts.add(initial)
        observed = zlib.decompress((out / initial).read_bytes())
        require(len(observed) == 16384, "Incomplete initial VRAM")
        require(
            variant != "positive" or observed == M.initial(), "Startup picture differs"
        )
        require(len(result["cases"]) == len(M.cases()), "Missing native calls")
        expected = M.initial()
        memory_faults = pixel_faults = 0
        for index, (actual, call) in enumerate(
            zip(result["cases"], M.cases(), strict=True)
        ):
            require(actual["call"] == call, "Native calls changed/reordered")
            context = bytes.fromhex(actual["context"])
            require(len(context) == 24, "Incomplete context")
            require(
                context[:7]
                == V.arguments(call, result["source_address"], result["bulk_address"]),
                "Public inputs differ",
            )
            accepted, writes = M.apply(expected, call)
            require(
                context[7] == int(accepted)
                and int.from_bytes(context[8:10], "little") == writes,
                "Status/count differs",
            )
            require(
                context[10:12] == bytes([c["data_port"], c["control_port"]]),
                "Port ownership changed",
            )
            require(
                actual["source_ram"] == M.SOURCE.hex()
                and actual["source_rom_sha256"] == hashlib.sha256(M.BULK).hexdigest(),
                "Source changed",
            )
            require(
                actual["cpu_guards"]
                == [(bytes([165]) * 8).hex(), (bytes([90]) * 8).hex()],
                "CPU guard differs",
            )
            name = f"{variant}-{index}.dat.z"
            require(actual["memory"] == name, "Readback identity differs")
            required_artifacts.add(name)
            memory = zlib.decompress((out / name).read_bytes())
            require(len(memory) == 16384, "Incomplete VRAM")
            mismatch = memory != expected
            require(
                actual["mismatch"] == mismatch,
                "Recorded outcome differs from independent bytes",
            )
            require(
                variant != "positive" or not mismatch,
                "Independent VRAM comparison failed",
            )
            memory_faults += int(mismatch)
            if index in [0, 1, 5, 16, 19, 23]:
                capture = f"{variant}-{index}.png"
                require(actual.get("capture") == capture, "Missing native capture")
                required_artifacts.add(capture)
                mismatch = V.PNG.raster(out / capture) != M.pixels(c, expected)
                require(
                    variant != "positive" or not mismatch,
                    "Independent native pixels differ",
                )
                pixel_faults += int(mismatch)
        require(
            result["memory_faults"] == memory_faults
            and result["pixel_faults"] == pixel_faults,
            "Failure count differs",
        )
        require(
            variant == "positive" or (memory_faults > 0 and pixel_faults > 0),
            "Faulty code escaped independent checks",
        )
    require(set(record["artifacts"]) == required_artifacts, "Observation set differs")
    for name, digest in record["artifacts"].items():
        require(Path(name).name == name, "Unsafe observation name")
        require(V.T.sha(out / name) == digest, "Observation hash differs: " + name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--system")
    args = parser.parse_args()
    selected = [
        c for c in V.configs() if args.system is None or c["machine_id"] == args.system
    ]
    require(bool(selected), "No matching system; nothing checked")
    for cfg in selected:
        check(cfg)
        print(cfg["machine_id"], "retained evidence PASS")
