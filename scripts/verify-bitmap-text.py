"""Run bounded text calls in four native machines and retain complete outcomes."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/bitmap-text"


def load(name, path):
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


def normal(c, r, symbols):
    r = dict(r)
    r.setdefault("source_ptr", c["data"])
    r.setdefault(
        "font_ptr",
        c["data"] + 512 if r.get("font") == "synthetic" else symbols["font_data"],
    )
    return r


def inputs(c, r):
    data = bytearray([165] * 96)
    fields = [
        (0, r["xy"][0]),
        (2, r["xy"][1]),
        (4, r["font_ptr"]),
        (6, r["source_ptr"]),
        (11, r.get("count", 64)),
    ]
    fields += list(
        zip(
            [18, 20, 22, 24],
            r.get("clip", [0, 0, c["width"], c["height"]]),
            strict=True,
        )
    )
    for at, value in fields:
        data[at : at + 2] = (value & 65535).to_bytes(2, c["order"])
    for at, value in [
        (8, r.get("length", len(r.get("bytes", [])))),
        (9, r.get("code", 65)),
        (10, r.get("first", 32)),
        (13, r.get("fallback", 63)),
        (14, r.get("mode", 0)),
        (15, r.get("fg", 1)),
        (16, r.get("bg", 0)),
    ]:
        data[at] = value
    return bytes(data)


def status(c, actual, submitted, expect):
    require(
        actual[:17] == submitted[:17] and actual[18:26] == submitted[18:26],
        "Public text inputs changed",
    )
    require(actual[17] == int(expect["accepted"]), "Text acceptance differs")
    require(
        int.from_bytes(actual[26:28], c["order"], signed=True) == expect["next_x"],
        "Advance differs",
    )
    require(
        actual[28] == expect["consumed"] and actual[29] == expect["missing"],
        "Consumed/fallback count differs",
    )
    require(
        int.from_bytes(actual[30:32], c["order"]) == expect["calls"],
        "Span count differs",
    )
    require(
        int.from_bytes(actual[32:36], c["order"]) == expect["writes"],
        "Byte writes differ",
    )


def sources(c):
    files = [
        S / name
        for name in [
            "build.py",
            "model.py",
            "cases.py",
            "systems.json",
            "toolchain.json",
            "font.json",
            "font-" + c["cpu"] + ".inc",
            c["cpu"] + ".inc",
        ]
    ]
    files += [
        ROOT / "scripts" / name
        for name in [
            "verify-bitmap-text.py",
            "check-bitmap-text.py",
            "verify-geometry.py",
            "verify-game-loops.py",
            "verify-tilemaps.py",
        ]
    ]
    files += [S.parent / "geometry/model.py"]
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/bitmap-text"
    files += [folder / "demo.asm", folder / "Makefile"]
    files += (
        [S.parent / "geometry/cpc.inc"]
        if c["machine_id"] == "amstrad-cpc"
        else [S.parent / "drawing-foundations" / (c["cpu"] + ".inc")]
    )
    if c["machine_id"] == "spectrum":
        files += [folder.parent / "bitmap-addressing/bitmap-addressing.inc"]
    return files


def segments(c):
    result = [
        (c["t"] - 16, 16),
        (c["t"] + 96, 16),
        (c["context"] - 16, 16),
        (c["context"] + 48, 16),
        (c["base"] - 16, 16),
    ]
    end = c["base"] + c["length"]
    if end < 65536:
        result.append((end, 768 if c["machine_id"] == "spectrum" else 16))
    return result


def guards(m, c):
    return [V.read(m, a, n).hex() for a, n in segments(c)]


def observe(m, c, out, name):
    p = out / (name + ".dat.z")
    p.write_bytes(zlib.compress(V.read(m, c["base"], c["length"]), 9))
    return {
        "memory": p.name,
        "context": V.read(m, c["t"], 96).hex(),
        "mailbox": V.read(m, c["command"], 2).hex(),
        "guards": guards(m, c),
    }


def capture(m, c, out, name, grid, match=True):
    return V.capture(m, c, out, name, grid, match)


def execute(c, args, variant, out):
    _, image = B.build(c["machine_id"], args.assembler, variant)
    syms = V.T.symbols(image.parent / "selected.sym")
    m = V.T.Machine(
        [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
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
                and bytes.fromhex(o["context"])[17] == 1
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
                "backend_bytes": syms["text_backend_end"] - syms["text_backend_start"],
                "font_bytes": 512,
                "text_context": 96,
                "backend_context": 48,
                "row_tables": 512 if c["cpu"] == "6502" else 0,
            },
        }
    finally:
        m.close()


def verify(c, args):
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
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
    configs = json.loads((S / "systems.json").read_text())
    if args.system:
        configs = [c for c in configs if c["machine_id"] == args.system]
    require(bool(configs), "No matching system")
    for c in configs:
        verify(c, args)
