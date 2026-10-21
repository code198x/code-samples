"""Recompute every retained layout result; this does not perform fresh execution."""

from __future__ import annotations

import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "layout_observer", ROOT / "scripts/verify-proportional-text.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
S, M, C, B = V.S, V.M, V.C, V.B
require = V.require


def check(c: dict, folder: Path | None = None) -> int:
    folder = (
        folder
        or ROOT
        / c["folder"]
        / "patterns/assembly/rendering/proportional-text/verification"
    )
    result = json.loads((folder / "results.json").read_text())
    require(result["machine_id"] == c["machine_id"], "Wrong machine")
    require(
        result["sources"]
        == {str(p.relative_to(ROOT)): V.V.T.sha(p) for p in V.sources(c)},
        "Source binding differs",
    )
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    require(
        result["tools"]
        == {k: tools[k]["binary_sha256"] for k in [c["binary"], "asm198x"]},
        "Tool binding differs",
    )
    require(set(result["variants"]) == set(B.VARIANTS), "Missing execution variant")
    for name, digest in result["artifacts"].items():
        require(Path(name).name == name, "Escaped artifact path")
        require(V.V.T.sha(folder / name) == digest, "Artifact checksum differs")
    used = set()
    count = 0

    def memory(o: dict) -> bytes:
        used.add(o["memory"])
        data = zlib.decompress((folder / o["memory"]).read_bytes())
        require(len(data) == c["length"], "Truncated memory")
        return data

    def capture(o: dict, grid: list[bytearray]) -> None:
        used.add(o["capture"])
        actual = V.V.PNG.raster(folder / o["capture"])
        expected = M.TEXT.P.frame(c, grid)
        require(actual == expected, "Full native image differs")

    for name, value in result["variants"].items():
        fault = name.split("-")[0] if name.endswith("-fault") else None
        custom = name == "customise"
        syms = value["symbols"]
        startup = V.normal(
            c,
            {
                "id": "startup",
                "kind": "block",
                "source_ptr": syms["label_data"],
                "bytes": list(
                    b"A NARROW PANEL\nWRAPS THIS MESSAGE\nPRESS FIRE"
                    if custom
                    else b"READY TO PLAY\nPRESS FIRE TO BEGIN"
                ),
                "rect": [21, 37, 104 if custom else 176, 80],
                "align": 2 if custom else 1,
                "pitch": 16 if custom else 12,
                "mode": 1,
                "spacing": 2 if custom else 1,
            },
            syms,
        )
        o = value["startup"]
        require(
            o["request"] == startup and o["mailbox"] == "00ef",
            "Wrong/incomplete startup",
        )
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        exp = M.evaluate(c, grid, startup, fault)
        require(
            V.outputs(c, bytes.fromhex(o["context"])) == exp, "Startup output differs"
        )
        require(memory(o) == M.TEXT.P.packed(c, grid, 0), "Startup memory differs")
        capture(o, grid)
        count += 1
        if custom:
            continue
        require(bytes.fromhex(value["rom_font"]) == M.DEFAULT, "Wrong native font")
        require(bytes.fromhex(value["rom_metrics"]) == M.WIDTHS, "Wrong native metrics")
        base = value["guards"]
        segments = V.guard_segments(c)
        require(len(base) == len(segments), "Missing guards")
        for i, (_, n) in enumerate(segments):
            expect = (
                bytes((x * 19 + 71) & 255 for x in range(n)).hex()
                if i < 4 or i >= len(segments) - 2
                else o["guards"][i]
            )
            require(
                base[i] == expect and len(bytes.fromhex(base[i])) == n,
                "Guard baseline differs",
            )
        grid = [
            bytearray((x * 3 + y * 5) % (c["pen_max"] + 1) for x in range(c["width"]))
            for y in range(c["height"])
        ]
        cases = C.cases(c) if name == "positive" else C.diagnostic(name)
        require(len(value["cases"]) == len(cases) > 0, "Missing cases")
        for i, (case, rec) in enumerate(zip(cases, value["cases"], strict=True)):
            request = V.normal(c, case, syms)
            require(
                rec["ram_metrics"]
                == bytes(request.get("metric_values", M.WIDTHS)).hex(),
                "RAM metrics changed",
            )
            require(rec["request"] == request, "Case identity differs")
            require(
                rec["mailbox"] == "00ef" and 0 < rec["observed_frames"] <= 1024,
                "Call incomplete",
            )
            require(rec["guards"] == base, "Guard changed")
            require(
                rec["source"]
                == bytes(request.get("bytes", [])).ljust(256, b"\xa5").hex(),
                "Source changed",
            )
            require(rec["rom_font"] == value["rom_font"], "Font changed")
            require(rec["rom_metrics"] == value["rom_metrics"], "Metrics changed")
            if request.get("scene") or name != "positive":
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
            exp = M.evaluate(c, grid, request, fault)
            actual = bytes.fromhex(rec["context"])
            require(
                actual[:13] == V.inputs(c, request)[:13]
                and actual[64:67] == V.inputs(c, request)[64:67],
                "Public inputs changed",
            )
            require(V.outputs(c, actual) == exp, "Layout results differ")
            require(
                memory(rec)
                == M.TEXT.P.packed(
                    c, grid, 165 if c["machine_id"] == "amstrad-cpc" else 0
                ),
                "Full destination differs",
            )
            need = bool(request.get("scene") or name != "positive" or i % 12 == 0)
            require(("capture" in rec) == need, "Required capture missing")
            if need:
                capture(rec, grid)
            if fault:
                good = [bytearray(c["width"]) for _ in range(c["height"])]
                good_out = M.evaluate(c, good, request)
                require(exp != good_out, "Wrong results passed as good")
                n = sum(
                    a != b
                    for a, b in zip(
                        M.TEXT.P.packed(c, grid), M.TEXT.P.packed(c, good), strict=True
                    )
                )
                require(
                    n == rec["good_bitmap_mismatches"] and n > 0, "Fault is invisible"
                )
            count += 1
        costs = value["costs"]
        require(
            all(costs[k] > 0 for k in ["layout_bytes", "text_bytes", "backend_bytes"]),
            "Missing code size",
        )
        require(
            (
                costs["layout_context"],
                costs["text_context"],
                costs["backend_context"],
                costs["font"],
            )
            == (80, 96, 48, 512),
            "Allocation differs",
        )
    for fault in ["advance"]:
        require(
            result["variants"][fault + "-fixed"]["fixture_sha256"]
            == result["variants"]["positive"]["fixture_sha256"],
            "Repair differs from original",
        )
    require(used == set(result["artifacts"]), "Incomplete or unused artifact manifest")
    return count


if __name__ == "__main__":
    total = 0
    for c in json.loads((S / "systems.json").read_text()):
        total += check(c)
    require(total > 160, "Missing four-machine execution tranche")
    print(f"Validated {total} retained layout observations; no fresh execution claimed")
