"""Execute enlarged glyphs using released native emulators and independent pixels."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/scaled-text"


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


BASE = load("scaled_transport", ROOT / "scripts/verify-bitmap-text.py")
V = BASE.V
M = load("scaled_oracle", S / "model.py")
C = load("scaled_cases", S / "cases.py")
B = load("scaled_build", S / "build.py")
require = V.require
normal = BASE.normal
segments = BASE.segments


def inputs(c: dict, r: dict) -> bytes:
    data = bytearray(BASE.inputs(c, r))
    data[68:70] = bytes(r.get("scale", [2, 2]))
    return bytes(data)


def status(c: dict, actual: bytes, r: dict, expected: dict) -> None:
    submitted = inputs(c, r)
    BASE.status(c, actual, submitted, expected)
    require(actual[68:70] == submitted[68:70], "Scale inputs changed")


def startup(c: dict, syms: dict, variant: str) -> dict:
    custom = variant == "customise"
    return normal(
        c,
        {
            "id": "startup",
            "kind": "string",
            "xy": [21, 37],
            "bytes": list(b"BIG!" if custom else b"PIXEL TEXT"),
            "scale": [3, 2] if custom else [2, 2],
            "mode": 1,
            "source_ptr": syms["label_data"],
        },
        syms,
    )


def cases(c: dict, variant: str) -> list[dict]:
    return (
        C.cases(c)
        if variant == "positive"
        else [
            {
                "id": variant,
                "kind": "string",
                "xy": [21, 37],
                "bytes": list(b"WAVE"),
                "scale": [2, 2],
                "mode": 1,
                "scene": True,
            }
        ]
    )


def sources(c: dict) -> list[Path]:
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/scaled-text"
    files = (
        list(S.glob("*.py"))
        + list(S.glob("*.json"))
        + [S / (c["cpu"] + ".inc"), S / "mistakes" / (c["cpu"] + "-advance.inc")]
    )
    files += (
        list(folder.glob("*.asm")) + list(folder.glob("*.inc")) + [folder / "Makefile"]
    )
    files += [
        ROOT / "scripts" / n
        for n in [
            "verify-scaled-text.py",
            "check-scaled-text.py",
            "test_scaled_text.py",
            "verify-bitmap-text.py",
            "verify-geometry.py",
            "verify-game-loops.py",
            "verify-tilemaps.py",
        ]
    ]
    files += [
        S.with_name("bitmap-text") / n
        for n in [
            "font.json",
            "font-" + c["cpu"] + ".inc",
            "model.py",
            "build.py",
            "cases.py",
            "systems.json",
        ]
    ]
    files += [
        S.parent / "geometry/model.py",
        S.parent / "geometry/cpc.inc"
        if c["machine_id"] == "amstrad-cpc"
        else S.parent / "drawing-foundations" / (c["cpu"] + ".inc"),
    ]
    if c["machine_id"] == "spectrum":
        files.append(folder.parent / "bitmap-addressing/bitmap-addressing.inc")
    return files


def execute(c: dict, args: argparse.Namespace, variant: str, out: Path) -> dict:
    _, image = B.build(c["machine_id"], args.assembler, variant)
    syms = V.T.symbols(image.with_name("selected.sym"))
    machine = V.T.Machine(
        [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    try:
        machine.call("run_frames", frames=120)
        require(V.read(machine, c["command"], 2) == b"\x00\xef", "Startup incomplete")
        fault = "advance" if variant == "advance-fault" else None
        r = startup(c, syms, variant)
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        expected = M.evaluate(c, grid, r, fault)
        o = BASE.observe(machine, c, out, variant + "-startup")
        status(c, bytes.fromhex(o["context"]), r, expected)
        require(
            zlib.decompress((out / o["memory"]).read_bytes()) == M.P.packed(c, grid),
            "Startup memory differs",
        )
        V.capture(machine, c, out, variant + "-startup", grid)
        o.update(request=r, capture=variant + "-startup.png")
        if variant == "customise":
            return {
                "startup": o,
                "fixture_sha256": V.T.sha(image),
                "symbols": {k: syms[k] for k in ["font_data", "label_data"]},
            }
        for address, n in segments(c)[:4]:
            V.write(machine, address, bytes((i * 19 + 71) & 255 for i in range(n)))
        guards = BASE.guards(machine, c)
        V.write(machine, c["data"] + 512, M.SYNTHETIC)
        rom = V.read(machine, syms["font_data"], 512).hex()
        require(bytes.fromhex(rom) == M.DEFAULT, "Caller font differs")
        grid = [
            bytearray((x * 3 + y * 5) % (c["pen_max"] + 1) for x in range(c["width"]))
            for y in range(c["height"])
        ]
        padding = 165 if c["machine_id"] == "amstrad-cpc" else 0
        V.write(machine, c["base"], M.P.packed(c, grid, padding))
        records = []
        for i, case in enumerate(cases(c, variant)):
            r = normal(c, case, syms)
            if r.get("scene"):
                V.request(machine, c, 3)
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
            payload = bytes(r.get("bytes", [])).ljust(256, b"\xa5")
            V.write(machine, c["data"], payload)
            V.write(machine, c["t"], inputs(c, r))
            frames = V.request(machine, c, 1 if r["kind"] == "char" else 2)
            expected = M.evaluate(c, grid, r, fault)
            rec = BASE.observe(machine, c, out, variant + "-" + r["id"])
            status(c, bytes.fromhex(rec["context"]), r, expected)
            require(
                zlib.decompress((out / rec["memory"]).read_bytes())
                == M.P.packed(c, grid, padding),
                r["id"] + ": destination differs",
            )
            require(rec["guards"] == guards, "Neighbour changed")
            source = V.read(machine, c["data"], 256).hex()
            font = V.read(machine, c["data"] + 512, len(M.SYNTHETIC)).hex()
            rom_after = V.read(machine, syms["font_data"], 512).hex()
            require(
                source == payload.hex()
                and font == M.SYNTHETIC.hex()
                and rom_after == rom,
                "Source/font changed",
            )
            rec.update(
                request=r,
                observed_frames=frames,
                source=source,
                font=font,
                rom_font=rom_after,
            )
            if r.get("scene") or variant != "positive" or i % 16 == 0:
                V.capture(machine, c, out, variant + "-" + r["id"], grid)
                rec["capture"] = variant + "-" + r["id"] + ".png"
            if fault:
                good = [bytearray(c["width"]) for _ in range(c["height"])]
                good_result = M.evaluate(c, good, r)
                mismatch = sum(
                    a != b
                    for a, b in zip(
                        M.P.packed(c, grid), M.P.packed(c, good), strict=True
                    )
                )
                require(
                    expected != good_result and mismatch > 0,
                    "Wrong advance is invisible",
                )
                rec["good_memory_mismatches"] = mismatch
            records.append(rec)
            if i % 16 == 0:
                print(c["machine_id"], variant, i + 1, "calls checked", flush=True)
        return {
            "startup": o,
            "cases": records,
            "guards": guards,
            "rom_font": rom,
            "symbols": {k: syms[k] for k in ["font_data", "label_data"]},
            "fixture_sha256": V.T.sha(image),
            "costs": {
                "text_bytes": syms["text_end"] - syms["text_char"],
                "backend_bytes": syms["text_backend_end"] - syms["text_backend_start"],
                "font": 512,
                "text_context": 96,
                "backend_context": 48,
                "row_tables": 512 if c["cpu"] == "6502" else 0,
            },
        }
    finally:
        machine.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--only")
    args = p.parse_args()
    configs = json.loads((S / "systems.json").read_text())
    selected = [c for c in configs if not args.only or c["machine_id"] == args.only]
    require(bool(selected), "No selected system")
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    for c in selected:
        for name, path in [
            (c["binary"], args.native / c["binary"]),
            ("asm198x", Path(args.assembler)),
        ]:
            require(
                V.T.sha(path) == tools[name]["binary_sha256"],
                "Unqualified tool " + name,
            )
        out = (
            ROOT
            / c["folder"]
            / "patterns/assembly/rendering/scaled-text/build/verification"
        )
        out.mkdir(parents=True, exist_ok=True)
        for item in out.iterdir():
            if item.suffix in [".json", ".png", ".z"]:
                item.unlink()
        result = {
            "machine_id": c["machine_id"],
            "variants": {v: execute(c, args, v, out) for v in B.VARIANTS},
        }
        require(
            result["variants"]["advance-fixed"]["fixture_sha256"]
            == result["variants"]["positive"]["fixture_sha256"],
            "Repair differs",
        )
        result["sources"] = {str(f.relative_to(ROOT)): V.T.sha(f) for f in sources(c)}
        result["tools"] = {
            name: tools[name]["binary_sha256"] for name in [c["binary"], "asm198x"]
        }
        result["artifacts"] = {
            f.name: V.T.sha(f) for f in out.iterdir() if f.suffix in [".png", ".z"]
        }
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        print(
            c["machine_id"],
            "PASS",
            len(result["variants"]["positive"]["cases"]) + 6,
            "native observations",
            flush=True,
        )


if __name__ == "__main__":
    main()
