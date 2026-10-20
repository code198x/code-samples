"""Recheck retained six-machine drawing evidence without emulators or firmware."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/drawing-foundations"
spec = importlib.util.spec_from_file_location(
    "drawing_oracle", ROOT / "scripts/verify-drawing-foundations.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
require = V.require


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def check(c: dict, root: Path = ROOT) -> None:
    folder = root / c["folder"] / "patterns/assembly/rendering" / c["family"]
    out = folder / "verification"
    record = json.loads((out / "results.json").read_text())
    require(
        set(record) == {"positive", "fault", "sources", "artifacts"},
        "Incomplete result record",
    )
    required = {
        str(p.relative_to(ROOT))
        for p in [
            S / "build.py",
            S / "systems.json",
            S / "toolchain.json",
            Path(__file__),
            ROOT / "scripts/verify-drawing-foundations.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-tilemaps.py",
        ]
    }
    required.add(str((folder / "demo.asm").relative_to(root)))
    required.add(
        str((S / (c["cpu"] + ".inc")).relative_to(ROOT))
        if c["family"] == "pixels-and-boxes"
        else str((folder / "glyphs.inc").relative_to(root))
    )
    if c["machine_id"] == "spectrum":
        required.add(
            "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc"
        )
    require(set(record["sources"]) == required, "Source set incomplete")
    for name, digest in record["sources"].items():
        require(sha(root / name) == digest, "Source changed: " + name)
    require(bool(record["artifacts"]), "No retained observations")
    for name, digest in record["artifacts"].items():
        require(Path(name).name == name, "Unsafe evidence name")
        require(sha(out / name) == digest, "Observation changed: " + name)
    tools = json.loads((root / S.relative_to(ROOT) / "toolchain.json").read_text())
    tool = next(t for t in tools if t["tool"] == c["binary"])
    for variant in ["positive", "fault"]:
        r = record[variant]
        require(
            r["emulator_sha256"] == tool["binary_sha256"], "Wrong released emulator"
        )
        require(
            r["fault_mismatches"] == 0
            if variant == "positive"
            else r["fault_mismatches"] > 0,
            "Missing completed failure control",
        )
        require(
            r["pixel_faults"] == 0 if variant == "positive" else r["pixel_faults"] > 0,
            "Missing visible failure control",
        )
        count = (
            94
            if c["family"] == "pixels-and-boxes"
            else 16
            if c["machine_id"] == "msx"
            else 17
        )
        require(len(r["cases"]) == count, "Missing native calls")
        for i, case in enumerate(r["cases"]):
            if "index" not in case:
                continue
            require(case["index"] == i, "Native calls reordered")
            name = f"{variant}-{i}.dat"
            require(name in record["artifacts"], "Missing destination readback")
            require(
                sha(out / name) == case["memory_sha256"], "Destination hash differs"
            )
    if c["family"] == "pixels-and-boxes":
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        grid[0][0] = 1
        require(
            (out / "positive-initial.dat").read_bytes() == V.pixel_memory(c, grid),
            "Startup differs",
        )
        cases = V.pixel_cases(c["width"], c["height"])
        for i, case in enumerate(cases):
            accepted, value, touched = V.apply_pixel(c, grid, case)
            r = record["positive"]["cases"][i]
            require(
                [r[k] for k in ["kind", "x", "y", "right", "bottom", "op"]]
                == list(case),
                "Request differs",
            )
            require(
                [r["accepted"], r["read"], r["writes"]]
                == [accepted, value, len(touched)],
                "Call results differ",
            )
            require(
                (out / f"positive-{i}.dat").read_bytes() == V.pixel_memory(c, grid),
                "Independent bitmap differs",
            )
            capture = out / f"positive-{i}.png"
            if capture.name in record["artifacts"]:
                require(
                    V.PNG.raster(capture) == V.pixels(c, grid),
                    "Independent native pixels differ",
                )
    else:
        slots, bpg, base, screen, cells, cols = V.glyph_spec(c)
        initial = (out / "positive-initial.dat").read_bytes()
        font = bytearray(slots * bpg)
        names = bytearray(cells)
        encoded = (
            bytes(V.ORIGINAL)
            if bpg == 8
            else bytes(
                v
                for i, b in enumerate(V.ORIGINAL)
                for v in [b, b if i in [8, 15] else 0]
            )
        )
        font[bpg : 3 * bpg] = encoded
        names[2 * cols + 2 : 2 * cols + 4] = bytes([1, 1])
        source = bytes(((i * 37 + 11) ^ (i // 8) * 19) & 255 for i in range(bpg * 3))
        bulk = bytes(
            (i * 17 + 3) & 255 for i in range((128 if slots == 128 else 255) * bpg)
        )

        def expected() -> bytes:
            data = bytearray(initial)
            foff = 0
            noff = 0x420 if slots == 128 else screen - base
            data[foff : foff + len(font)] = font
            data[noff : noff + len(names)] = names
            return bytes(data)

        require(initial == expected(), "Initial glyph encoding differs")
        # Sentinels live outside owned font/map ranges and must remain stable.
        goff = 0x400 if slots == 128 else 0x800 if bpg == 8 else 0x1000
        require(
            initial[goff : goff + 16] == bytes([165] * 16),
            "Missing nonzero glyph guard",
        )
        for i, r in enumerate(record["positive"]["cases"]):
            kind = r["kind"]
            if kind == "init":
                font[:] = bytes(len(font))
                names[:] = bytes(len(names))
                require(
                    (out / "positive-init.dat").read_bytes() == expected(),
                    "Init differs",
                )
                continue
            if kind == "live-rejection":
                require(
                    r["accepted"] is False and r["writes"] == 0,
                    "Live upload did not reject",
                )
                continue
            n = 1 if kind == "replace" else r["count"]
            accepted = (
                (r["cell"] < cells and r["code"] < slots)
                if kind == "select"
                else n > 0 and r["first"] + n <= slots
            )
            writes = (1 if kind == "select" else n * bpg) if accepted else 0
            require(
                r["accepted"] == accepted and r["writes"] == writes,
                "Glyph call status/cost differs",
            )
            if accepted:
                if kind == "select":
                    names[r["cell"]] = r["code"]
                else:
                    font[r["first"] * bpg : (r["first"] + n) * bpg] = (
                        bulk if kind == "bulk" else source
                    )[: n * bpg]
            require(
                (out / f"positive-{i}.dat").read_bytes() == expected(),
                "Independent glyph memory differs",
            )
            capture = out / f"positive-{i}.png"
            if capture.name in record["artifacts"]:
                require(
                    V.PNG.raster(capture) == V.glyph_pixels(c, font, names),
                    "Independent glyph pixels differ",
                )
    print(
        c["machine_id"],
        "retained memory, pixels, costs, source identities and controls PASS",
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--system")
    a = p.parse_args()
    configs = json.loads((S / "systems.json").read_text())
    require(
        len(configs) == 6 and len({c["machine_id"] for c in configs}) == 6,
        "Expected six distinct systems",
    )
    selected = [c for c in configs if not a.system or c["machine_id"] == a.system]
    require(bool(selected), "No matching system")
    for c in selected:
        check(c)
