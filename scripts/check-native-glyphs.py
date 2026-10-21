"""Independently replay complete retained slot/plane/name evidence."""

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
    "native_verify", ROOT / "scripts/verify-native-glyphs.py"
)
if spec is None or spec.loader is None:
    raise ValueError("Cannot load verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
M = V.M
require = V.require


def check(c: dict[str, Any], root: Path = ROOT) -> None:
    out = root / c["folder"] / "patterns/assembly/rendering/custom-glyphs/verification"
    record = json.loads((out / "results.json").read_text())
    require(
        set(record) == {"machine_id", "variants", "sources", "artifacts"},
        "Incomplete evidence",
    )
    require(record["machine_id"] == c["machine_id"], "Wrong machine")
    require(
        set(record["sources"]) == {str(p.relative_to(ROOT)) for p in V.paths(c)},
        "Incomplete source binding",
    )
    for name, digest in record["sources"].items():
        require(V.T.sha(root / name) == digest, "Source changed: " + name)
    tools = {
        t["tool"]: t
        for t in json.loads(
            (root / V.S.relative_to(ROOT) / "toolchain.json").read_text()
        )
    }
    require(
        set(record["variants"]) == set(M.VARIANTS), "Missing completed native variant"
    )
    artifacts = set()
    for variant in M.VARIANTS:
        r = record["variants"][variant]
        require(
            r["emulator_sha256"] == tools[c["binary"]]["binary_sha256"]
            and r["assembler_sha256"] == tools["asm198x"]["binary_sha256"],
            "Wrong released tools",
        )
        require(0 < r["kernel_bytes"] < 2048, "Invalid component extent")
        require(
            c["origin"] <= r["bulk_address"] < c["origin"] + c["size"] - len(M.bulk(c)),
            "Invalid ROM asset extent",
        )
        initial = f"{variant}-initial.dat.z"
        artifacts.add(initial)
        observed = zlib.decompress((out / initial).read_bytes())
        expected = M.initial(c)
        require(len(observed) == len(expected), "Incomplete initial allocation")
        require(
            variant != "positive" or observed == expected,
            "Initial native memory differs",
        )
        require(len(r["cases"]) == len(M.cases(c)), "Missing native calls")
        memory_faults = pixel_faults = 0
        for index, (actual, call) in enumerate(
            zip(r["cases"], M.cases(c), strict=True)
        ):
            require(actual["call"] == call, "Calls changed/reordered")
            args = V.arguments(c, call, r["bulk_address"])
            context = bytes.fromhex(actual["context"])
            require(
                len(context) == (32 if c["cpu"] == "z80" else 24), "Incomplete context"
            )
            require(context[: len(args)] == args, "Changed input")
            accepted, writes = M.apply(c, expected, call)
            status = 11 if c["cpu"] == "z80" else 7
            require(
                context[status] == int(accepted)
                and int.from_bytes(context[status + 1 : status + 3], "little")
                == writes,
                "Status/write count differs",
            )
            if c["cpu"] == "z80":
                require(context[14:16] == bytes([190, 191]), "Ports changed")
            require(
                actual["source_ram"] == M.source(c).hex()
                and actual["source_rom_sha256"]
                == hashlib.sha256(M.bulk(c)).hexdigest(),
                "Input assets changed",
            )
            require(
                actual["cpu_guards"]
                == [(bytes([v]) * 8).hex() for v in [165, 90, 166, 91]],
                "CPU/source guard changed",
            )
            name = f"{variant}-{index}.dat.z"
            require(actual["memory"] == name, "Wrong observation identity")
            artifacts.add(name)
            memory = zlib.decompress((out / name).read_bytes())
            require(len(memory) == len(expected), "Incomplete allocation")
            mismatch = memory != expected
            require(actual["mismatch"] == mismatch, "Reported comparison differs")
            require(
                variant != "positive" or not mismatch,
                "Independent memory expectation failed",
            )
            memory_faults += int(mismatch)
            if index in V.captures(c):
                capture = f"{variant}-{index}.png"
                require(actual.get("capture") == capture, "Missing native frame")
                artifacts.add(capture)
                mismatch = V.PNG.raster(out / capture) != M.rgba(c, expected)
                require(
                    variant != "positive" or not mismatch,
                    "Independent native picture differs",
                )
                pixel_faults += int(mismatch)
        require(
            r["memory_faults"] == memory_faults and r["pixel_faults"] == pixel_faults,
            "Failure counts differ",
        )
        require(
            variant == "positive" or (memory_faults > 0 and pixel_faults > 0),
            "Faulty build escaped independent expectations",
        )
    require(set(record["artifacts"]) == artifacts, "Incomplete/extra observation set")
    for name, digest in record["artifacts"].items():
        require(Path(name).name == name, "Unsafe observation path")
        require(V.T.sha(out / name) == digest, "Observation hash differs")


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system")
    a = p.parse_args()
    selected = [
        c for c in V.configs() if a.system is None or c["machine_id"] == a.system
    ]
    require(bool(selected), "No matching system; nothing checked")
    for c in selected:
        check(c)
        print(c["machine_id"], "retained evidence PASS")
