"""Run bounded text calls in four native machines and retain complete outcomes."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/bitmap-text/amiga"


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


V = load("text_transport_helpers", ROOT / "scripts/verify-geometry.py")
M = load("text_oracle", S / "model.py")
C = load("text_cases", S / "cases.py")
B = load("text_build", S / "build.py")
require = V.require


def normal(c: dict[str, Any], r: dict[str, Any], symbols: Any) -> Any:
    r = dict(r)
    r.setdefault("source_ptr", c["data"])
    r.setdefault(
        "font_ptr",
        c["data"] + 512 if r.get("font") == "synthetic" else symbols["font_data"],
    )
    return r


def inputs(c: dict[str, Any], r: dict[str, Any]) -> bytes:
    data = bytearray([165] * 96)
    fields = [(0, r["xy"][0]), (2, r["xy"][1]), (16, r.get("count", 64))] + list(
        zip(
            [22, 24, 26, 28],
            r.get("clip", [0, 0, c["width"], c["height"]]),
            strict=True,
        )
    )
    for at, val in fields:
        data[at : at + 2] = (val & 65535).to_bytes(2, "big")
    for at, val in [(4, r["font_ptr"]), (8, r["source_ptr"])]:
        data[at : at + 4] = val.to_bytes(4, "big")
    for at, val in [
        (12, r.get("length", len(r.get("bytes", [])))),
        (13, r.get("code", 65)),
        (14, r.get("first", 32)),
        (15, r.get("fallback", 63)),
        (18, r.get("mode", 0)),
        (19, r.get("fg", 1)),
        (20, r.get("bg", 0)),
    ]:
        data[at] = val
    return bytes(data)


def status(c: dict[str, Any], actual: bytes, submitted: bytes, expect: Any) -> None:
    require(
        actual[:21] == submitted[:21] and actual[22:30] == submitted[22:30],
        "Public text inputs changed",
    )
    require(actual[21] == int(expect["accepted"]), "Text acceptance differs")
    require(
        int.from_bytes(actual[30:32], "big", signed=True) == expect["next_x"],
        "Advance differs",
    )
    require(
        actual[32] == expect["consumed"] and actual[33] == expect["missing"],
        "Consumed/fallback count differs",
    )
    require(
        int.from_bytes(actual[34:36], "big") == expect["calls"], "Span count differs"
    )
    require(
        int.from_bytes(actual[36:40], "big") == expect["writes"], "Byte writes differ"
    )


def sources(c: dict[str, Any]) -> list[Path]:
    files = [S / n for n in ["build.py", "model.py", "cases.py", "system.json"]]
    files += [
        S.parent / n
        for n in ["m68000.inc", "font-m68000.inc", "font.json", "model.py", "cases.py"]
    ]
    files += [
        S.parents[1] / "geometry/model.py",
        S.parents[1] / "remaining-primitives/m68000.inc",
        S.parents[1] / "remaining-primitives/model.py",
        S.parents[1] / "remaining-primitives/toolchain.json",
    ]
    files += [
        ROOT / "scripts" / n
        for n in [
            "verify-amiga-bitmap-text.py",
            "check-amiga-bitmap-text.py",
            "verify-geometry.py",
            "verify-game-loops.py",
            "verify-tilemaps.py",
        ]
    ]
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/bitmap-text"
    files += [folder / "demo.asm", folder / "Makefile"]
    return files


def segments(c: dict[str, Any]) -> list[tuple[int, int]]:
    result = [
        (c["t"] - 16, 16),
        (c["t"] + 96, 16),
        (c["context"] - 16, 16),
        (c["context"] + 48, 16),
        (c["base"] - 16, 16),
    ]
    end = c["base"] + c["length"]
    result.append((end, 16))
    result.append((0x4000, 72))
    return result


def guards(m: Any, c: dict[str, Any]) -> list[str]:
    return [V.read(m, a, n).hex() for a, n in segments(c)]


def observe(m: Any, c: dict[str, Any], out: Path, name: str) -> dict[str, Any]:
    p = out / (name + ".dat.z")
    p.write_bytes(zlib.compress(V.read(m, c["base"], c["length"]), 9))
    return {
        "memory": p.name,
        "context": V.read(m, c["t"], 96).hex(),
        "mailbox": V.read(m, c["command"], 2).hex(),
        "guards": guards(m, c),
    }


def capture(
    m: Any, c: dict[str, Any], out: Path, name: str, grid: Any, match: bool = True
) -> int:
    path = out / (name + ".png")
    m.call("save_screenshot", path=str(path))
    actual = V.PNG.raster(path)
    expected = M.P.frame(c, grid)
    require(actual[0] == expected[0], "Native dimensions differ")
    errors = sum(
        actual[1][i : i + 4] != expected[1][i : i + 4]
        for i in range(0, len(actual[1]), 4)
    )
    require(
        errors == 0 if match else errors > 0,
        "Independent native image differs" if match else "Fault invisible",
    )
    return errors


def execute(
    c: dict[str, Any], args: argparse.Namespace, variant: str, out: Path
) -> dict[str, Any]:
    _, image = B.build(args.assembler, variant)
    syms = V.T.symbols(image.parent / "selected.sym")
    for key in ["font_data", "label_data"]:
        syms[key] += c["origin"]
    m = V.T.Machine(
        [
            str(args.native / c["binary"]),
            "--mcp",
            "--" + c["kind"],
            str(image),
            "--model",
            "a500",
        ]
    )
    try:
        m.call("run_frames", frames=120)
        require(
            V.read(m, c["command"], 2) == b"\x00\xef", "Text startup did not complete"
        )
        if variant != "positive":
            V.request(m, c, 3)
            r = normal(
                c,
                {
                    "id": variant,
                    "kind": "string",
                    "xy": [21, 37],
                    "bytes": list(b"WAVE"),
                    "mode": 1,
                },
                syms,
            )
            V.write(m, c["data"], bytes(r["bytes"]))
            V.write(m, c["t"], inputs(c, r))
            before = guards(m, c)
            frames = V.request(m, c, 2)
            o = observe(m, c, out, variant)
            grid = [bytearray(c["width"]) for _ in range(c["height"])]
            M.evaluate(c, grid, r)
            actual = zlib.decompress((out / o["memory"]).read_bytes())
            expected = M.P.packed(c, grid)
            different = sum(a != b for a, b in zip(actual, expected, strict=True))
            require(
                different > 0
                and bytes.fromhex(o["context"])[21] == 1
                and o["guards"] == before,
                "Fault did not complete a bounded, accepted wrong draw",
            )
            errors = capture(m, c, out, variant, grid, False)
            o.update(
                request=r,
                observed_frames=frames,
                capture=variant + ".png",
                memory_mismatches=different,
                pixel_mismatches=errors,
                guard_before=before,
                fixture_sha256=V.T.sha(image),
            )
            return o
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        startup = normal(
            c,
            {
                "id": "startup",
                "kind": "string",
                "xy": [21, 37],
                "bytes": list(b"PIXEL TEXT"),
                "mode": 1,
                "source_ptr": syms["label_data"],
            },
            syms,
        )
        expected = M.evaluate(c, grid, startup)
        o = observe(m, c, out, "startup")
        status(c, bytes.fromhex(o["context"]), inputs(c, startup), expected)
        require(
            zlib.decompress((out / o["memory"]).read_bytes()) == M.P.packed(c, grid),
            "Direct caller bitmap differs",
        )
        capture(m, c, out, "startup", grid)
        o.update(request=startup, capture="startup.png")
        for addr, n in segments(c)[:4]:
            V.write(m, addr, bytes((i * 19 + 71) & 255 for i in range(n)))
        baseline = guards(m, c)
        V.write(m, c["data"] + 512, M.SYNTHETIC)
        font_before = V.read(m, c["data"] + 512, len(M.SYNTHETIC)).hex()
        rom_before = V.read(m, syms["font_data"], 512).hex()
        grid = [
            bytearray((x * 3 + y * 5) % (c["pen_max"] + 1) for x in range(c["width"]))
            for y in range(c["height"])
        ]
        padding = 165 if c["machine_id"] == "amstrad-cpc" else 0
        V.write(m, c["base"], M.P.packed(c, grid, padding))
        records = []
        scene = False
        for i, case in enumerate(C.cases(c)):
            r = normal(c, case, syms)
            if r.get("scene") and not scene:
                V.request(m, c, 3)
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
                scene = True
            payload = bytes(r.get("bytes", [])).ljust(256, b"\xa5")
            V.write(m, c["data"], payload)
            V.write(m, c["t"], inputs(c, r))
            frames = V.request(m, c, 1 if r["kind"] == "char" else 2)
            expected = M.evaluate(c, grid, r)
            rec = observe(m, c, out, r["id"])
            status(c, bytes.fromhex(rec["context"]), inputs(c, r), expected)
            require(
                zlib.decompress((out / rec["memory"]).read_bytes())
                == M.P.packed(c, grid, padding),
                c["machine_id"] + " bitmap differs: " + str(r),
            )
            require(rec["guards"] == baseline, "Text guard changed")
            source = V.read(m, c["data"], 256).hex()
            font = V.read(m, c["data"] + 512, len(M.SYNTHETIC)).hex()
            rom = V.read(m, syms["font_data"], 512).hex()
            require(
                source == payload.hex() and font == font_before and rom == rom_before,
                "Text source allocation changed",
            )
            rec.update(
                id=r["id"],
                request=r,
                observed_frames=frames,
                source=source,
                font=font,
                rom_font=rom,
            )
            if i % 16 == 0 or r.get("scene"):
                capture(m, c, out, r["id"], grid)
                rec["capture"] = r["id"] + ".png"
            records.append(rec)
            if i % 16 == 0:
                print(c["machine_id"], i + 1, "text calls checked", flush=True)
        return {
            "startup": o,
            "cases": records,
            "guards": baseline,
            "padding": padding,
            "synthetic_font": font_before,
            "rom_font": rom_before,
            "symbols": {key: syms[key] for key in ["font_data", "label_data"]},
            "fixture_sha256": V.T.sha(image),
            "costs": {
                "text_bytes": syms["text_end"] - syms["text_char"],
                "backend_bytes": syms["backend_end"] - syms["backend_start"],
                "font_bytes": 512,
                "text_context": 96,
                "backend_context": 48,
                "row_tables": 512 if c["cpu"] == "6502" else 0,
            },
        }
    finally:
        m.close()


def verify(c: dict[str, Any], args: argparse.Namespace) -> None:
    tools = {
        t["tool"]: t
        for t in json.loads(
            (S.parents[1] / "remaining-primitives/toolchain.json").read_text()
        )
    }
    for key, path in [
        (c["binary"], args.native / c["binary"]),
        ("asm198x", Path(args.assembler)),
    ]:
        require(
            V.T.sha(path) == tools[key]["binary_sha256"], "Unqualified tool: " + key
        )
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/bitmap-text/build/verification"
    )
    out.mkdir(parents=True, exist_ok=True)
    for p in out.iterdir():
        if p.suffix in [".json", ".png", ".z"]:
            p.unlink()
    result = {
        "machine_id": c["machine_id"],
        "positive": execute(c, args, "positive", out),
        "faults": {},
    }
    for variant in ["glyph-fault", "advance-fault"]:
        result["faults"][variant] = execute(c, args, variant, out)
    result["sources"] = {str(p.relative_to(ROOT)): V.T.sha(p) for p in sources(c)}
    result["tools"] = {k: tools[k]["binary_sha256"] for k in [c["binary"], "asm198x"]}
    result["artifacts"] = {
        p.name: V.T.sha(p) for p in out.iterdir() if p.suffix in [".png", ".z"]
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(
        c["machine_id"],
        "PASS",
        len(result["positive"]["cases"]) + 1,
        "calls; two completed faults detected",
        flush=True,
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    args = p.parse_args()
    verify(json.loads((S / "system.json").read_text()), args)
