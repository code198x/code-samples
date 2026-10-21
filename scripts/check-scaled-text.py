"""Replay all retained enlarged-glyph observations; never claim fresh execution."""

from __future__ import annotations

import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "scaled_observer", ROOT / "scripts/verify-scaled-text.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
S = V.S
M = V.M
require = V.require


def check(c: dict, folder: Path | None = None) -> int:
    folder = (
        folder
        or ROOT / c["folder"] / "patterns/assembly/rendering/scaled-text/verification"
    )
    result = json.loads((folder / "results.json").read_text())
    require(result["machine_id"] == c["machine_id"], "Wrong machine")
    require(
        result["sources"]
        == {str(f.relative_to(ROOT)): V.V.T.sha(f) for f in V.sources(c)},
        "Source binding differs",
    )
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    require(
        result["tools"]
        == {name: tools[name]["binary_sha256"] for name in [c["binary"], "asm198x"]},
        "Tool binding differs",
    )
    require(set(result["variants"]) == set(V.B.VARIANTS), "Missing variant")
    for name, digest in result["artifacts"].items():
        require(Path(name).name == name, "Escaped artifact")
        require(V.V.T.sha(folder / name) == digest, "Artifact checksum differs")
    used = set()
    total = 0

    def memory(o: dict) -> bytes:
        used.add(o["memory"])
        data = zlib.decompress((folder / o["memory"]).read_bytes())
        require(len(data) == c["length"], "Truncated bitmap")
        return data

    def capture(o: dict, grid: list[bytearray]) -> None:
        used.add(o["capture"])
        require(
            V.V.PNG.raster(folder / o["capture"]) == M.P.frame(c, grid),
            "Native frame differs",
        )

    for variant, value in result["variants"].items():
        fault = "advance" if variant == "advance-fault" else None
        r = V.startup(c, value["symbols"], variant)
        o = value["startup"]
        require(
            o["request"] == r and o["mailbox"] == "00ef", "Wrong/incomplete startup"
        )
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        expected = M.evaluate(c, grid, r, fault)
        V.status(c, bytes.fromhex(o["context"]), r, expected)
        require(memory(o) == M.P.packed(c, grid), "Startup bitmap differs")
        capture(o, grid)
        total += 1
        if variant == "customise":
            continue
        require(bytes.fromhex(value["rom_font"]) == M.DEFAULT, "Wrong caller font")
        guards = value["guards"]
        segments = V.segments(c)
        require(len(guards) == len(segments), "Missing guards")
        for i, (_, n) in enumerate(segments):
            expected_guard = (
                bytes((j * 19 + 71) & 255 for j in range(n)).hex()
                if i < 4
                else o["guards"][i]
            )
            require(
                guards[i] == expected_guard and len(bytes.fromhex(guards[i])) == n,
                "Guard baseline differs",
            )
        grid = [
            bytearray((x * 3 + y * 5) % (c["pen_max"] + 1) for x in range(c["width"]))
            for y in range(c["height"])
        ]
        cases = V.cases(c, variant)
        require(len(value["cases"]) == len(cases) > 0, "Missing executed cases")
        for i, (case, rec) in enumerate(zip(cases, value["cases"], strict=True)):
            request = V.normal(c, case, value["symbols"])
            require(rec["request"] == request, "Case identity differs")
            require(
                rec["mailbox"] == "00ef" and 0 < rec["observed_frames"] <= 1024,
                "Call incomplete",
            )
            require(rec["guards"] == guards, "Neighbour changed")
            require(
                rec["source"]
                == bytes(request.get("bytes", [])).ljust(256, b"\xa5").hex(),
                "Source changed",
            )
            require(
                rec["font"] == M.SYNTHETIC.hex()
                and rec["rom_font"] == value["rom_font"],
                "Font changed",
            )
            if request.get("scene"):
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
            expected = M.evaluate(c, grid, request, fault)
            V.status(c, bytes.fromhex(rec["context"]), request, expected)
            require(
                memory(rec)
                == M.P.packed(c, grid, 165 if c["machine_id"] == "amstrad-cpc" else 0),
                "Destination differs",
            )
            need = bool(request.get("scene") or variant != "positive" or i % 16 == 0)
            require(("capture" in rec) == need, "Missing required frame")
            if need:
                capture(rec, grid)
            if fault:
                good = [bytearray(c["width"]) for _ in range(c["height"])]
                good_result = M.evaluate(c, good, request)
                mismatches = sum(
                    a != b
                    for a, b in zip(
                        M.P.packed(c, grid), M.P.packed(c, good), strict=True
                    )
                )
                require(
                    good_result != expected
                    and mismatches == rec["good_memory_mismatches"]
                    and mismatches > 0,
                    "Fault passed as good",
                )
            total += 1
        costs = value["costs"]
        require(
            costs["text_bytes"] > 0 and costs["backend_bytes"] > 0, "Missing code costs"
        )
        require(
            (
                costs["font"],
                costs["text_context"],
                costs["backend_context"],
                costs["row_tables"],
            )
            == (512, 96, 48, 512 if c["cpu"] == "6502" else 0),
            "Wrong allocations",
        )
    require(
        result["variants"]["advance-fixed"]["fixture_sha256"]
        == result["variants"]["positive"]["fixture_sha256"],
        "Repair differs from original",
    )
    require(used == set(result["artifacts"]), "Incomplete or unused manifest")
    return total


if __name__ == "__main__":
    configs = json.loads((S / "systems.json").read_text())
    require(
        len(configs) == 4
        and {c["machine_id"] for c in configs}
        == {"spectrum", "acorn-bbc-micro", "dragon", "amstrad-cpc"},
        "Missing machine",
    )
    count = sum(check(c) for c in configs)
    require(count > 400, "Missing tranche")
    print(
        f"Validated {count} retained scaled-text observations; no fresh execution claimed"
    )
