"""Execute layout routines and diagnostic repairs in four released native emulators."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/proportional-text"


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


V = load("layout_transport", ROOT / "scripts/verify-geometry.py")
TB = load("layout_text_transport", ROOT / "scripts/verify-bitmap-text.py")
M = load("layout_model", S / "model.py")
B = load("layout_build", S / "build.py")
C = load("layout_cases", S / "cases.py")
require = V.require


def normal(c: dict, r: dict, syms: dict) -> dict:
    return dict(
        r,
        source_ptr=r.get("source_ptr", c["data"]),
        font_ptr=r.get("font_ptr", syms["font_data"]),
        metric_ptr=r.get("metric_ptr", syms["metric_data"]),
    )


def inputs(c: dict, r: dict) -> bytes:
    data = bytearray([165] * 80)
    for at, v in zip([0, 2, 4, 6], r.get("rect", [21, 37, 176, 80]), strict=True):
        data[at : at + 2] = (v & 65535).to_bytes(2, c["order"])
    data[8] = r.get("align", 1)
    data[9] = r.get("pitch", 12)
    data[10:12] = r["source_ptr"].to_bytes(2, c["order"])
    data[12] = r.get("length", len(r.get("bytes", [])))
    data[64:66] = r["metric_ptr"].to_bytes(2, c["order"])
    data[66] = r.get("spacing", 1)
    return bytes(data)


def outputs(c: dict, data: bytes) -> dict:
    result = {
        k: data[at]
        for k, at in [
            ("accepted", 13),
            ("consumed", 14),
            ("lines", 15),
            ("last_count", 16),
        ]
    }
    for k, at, n in [
        ("measured", 18, 2),
        ("first_x", 20, 2),
        ("last_x", 22, 2),
        ("last_y", 24, 2),
        ("calls", 26, 2),
        ("writes", 28, 4),
    ]:
        result[k] = int.from_bytes(data[at : at + n], c["order"])
    result["accepted"] = bool(result["accepted"])
    return result


def guard_segments(c: dict) -> list[tuple[int, int]]:
    return TB.segments(c) + [(c["l"] - 16, 16), (c["l"] + 80, 16)]


def guards(m: Any, c: dict) -> list[str]:
    return [V.read(m, a, n).hex() for a, n in guard_segments(c)]


def observe(m: Any, c: dict, out: Path, name: str) -> dict:
    data = V.read(m, c["base"], c["length"])
    p = out / (name + ".dat.z")
    p.write_bytes(zlib.compress(data, 9))
    return {
        "memory": p.name,
        "context": V.read(m, c["l"], 80).hex(),
        "mailbox": V.read(m, c["command"], 2).hex(),
        "guards": guards(m, c),
    }


def check(
    c: dict,
    r: dict,
    record: dict,
    before: bytes,
    expected: dict,
    grid: list[bytearray],
    out: Path,
) -> None:
    actual = bytes.fromhex(record["context"])
    require(
        actual[:13] == before[:13] and actual[64:67] == before[64:67],
        r["id"] + ": public layout inputs changed",
    )
    require(
        outputs(c, actual) == expected,
        r["id"]
        + ": layout outputs differ: "
        + str(outputs(c, actual))
        + " expected "
        + str(expected),
    )
    require(
        zlib.decompress((out / record["memory"]).read_bytes())
        == M.TEXT.P.packed(c, grid, 165 if c["machine_id"] == "amstrad-cpc" else 0),
        c["machine_id"] + " " + r["id"] + ": destination mismatch",
    )
    require(bytes.fromhex(record["mailbox"])[0] == 0, "Call incomplete")


def execute(c: dict, args: argparse.Namespace, variant: str, out: Path) -> dict:
    _, image = B.build(c["machine_id"], args.assembler, variant)
    syms = V.T.symbols(image.with_name("selected.sym"))
    m = V.T.Machine(
        [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    try:
        m.call("run_frames", frames=120)
        require(
            V.read(m, c["command"], 2) == b"\x00\xef", "Layout startup did not complete"
        )
        fault = variant.split("-")[0] if variant.endswith("-fault") else None
        custom = variant == "customise"
        startup = normal(
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
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        exp = M.evaluate(c, grid, startup, fault)
        o = observe(m, c, out, variant + "-startup")
        # The reset caller clears CPC padding to zero, unlike the later sentinel exercise.
        require(
            outputs(c, bytes.fromhex(o["context"])) == exp,
            "Startup layout outputs differ",
        )
        require(
            zlib.decompress((out / o["memory"]).read_bytes())
            == M.TEXT.P.packed(c, grid, 0),
            "Startup bitmap differs",
        )
        V.capture(m, c, out, variant + "-startup", grid)
        o.update(request=startup, capture=variant + "-startup.png")
        if variant == "customise":
            return {
                "startup": o,
                "fixture_sha256": V.T.sha(image),
                "symbols": {
                    k: syms[k] for k in ["font_data", "label_data", "metric_data"]
                },
            }
        # Fill the complete allocation with a pattern; preserve all unowned neighbours.
        grid = [
            bytearray((x * 3 + y * 5) % (c["pen_max"] + 1) for x in range(c["width"]))
            for y in range(c["height"])
        ]
        V.write(
            m,
            c["base"],
            M.TEXT.P.packed(c, grid, 165 if c["machine_id"] == "amstrad-cpc" else 0),
        )
        for addr, n in guard_segments(c)[:4] + guard_segments(c)[-2:]:
            V.write(m, addr, bytes((i * 19 + 71) & 255 for i in range(n)))
        baseline = guards(m, c)
        rom_font = V.read(m, syms["font_data"], 512).hex()
        rom_metrics = V.read(m, syms["metric_data"], 64).hex()
        cases = C.cases(c) if variant == "positive" else C.diagnostic(variant)
        records = []
        for i, case in enumerate(cases):
            r = normal(c, case, syms)
            if r.get("scene") or variant != "positive":
                V.request(m, c, 3)
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
                # The backend clears visible CPC pixels while preserving unused allocation bytes.
            payload = bytes(r.get("bytes", [])).ljust(256, b"\xa5")
            V.write(m, c["data"], payload)
            metric_payload = bytes(r.get("metric_values", M.WIDTHS))
            V.write(m, c["data"] + 512, metric_payload)
            submitted = inputs(c, r)
            V.write(m, c["l"], submitted)
            tr = dict(r, kind="string", xy=[0, 0], length=0)
            V.write(m, c["t"], TB.inputs(c, tr))
            frame_count = V.request(
                m, c, {"measure": 1, "line": 2, "block": 4}[r["kind"]]
            )
            exp = M.evaluate(c, grid, r, fault)
            rec = observe(m, c, out, variant + "-" + r["id"])
            check(c, r, rec, submitted, exp, grid, out)
            require(rec["guards"] == baseline, "Layout changed neighbours")
            require(V.read(m, c["data"], 256) == payload, "Source allocation changed")
            require(V.read(m, syms["font_data"], 512).hex() == rom_font, "Font changed")
            require(
                V.read(m, syms["metric_data"], 64).hex() == rom_metrics,
                "Metrics changed",
            )
            require(
                V.read(m, c["data"] + 512, 64) == metric_payload, "RAM metrics changed"
            )
            rec.update(
                ram_metrics=V.read(m, c["data"] + 512, 64).hex(),
                request=r,
                observed_frames=frame_count,
                source=payload.hex(),
                rom_font=V.read(m, syms["font_data"], 512).hex(),
                rom_metrics=V.read(m, syms["metric_data"], 64).hex(),
            )
            if r.get("scene") or variant != "positive" or i % 12 == 0:
                V.capture(m, c, out, variant + "-" + r["id"], grid)
                rec["capture"] = variant + "-" + r["id"] + ".png"
            if fault:
                good_grid = [bytearray(c["width"]) for _ in range(c["height"])]
                good = M.evaluate(c, good_grid, r)
                require(exp != good, "Fault did not change observable outputs")
                mismatch = sum(
                    a != b
                    for a, b in zip(
                        M.TEXT.P.packed(c, grid, 0),
                        M.TEXT.P.packed(c, good_grid, 0),
                        strict=True,
                    )
                )
                require(mismatch > 0, "Fault did not change the picture")
                rec["good_bitmap_mismatches"] = mismatch
            records.append(rec)
            if i % 12 == 0:
                print(c["machine_id"], variant, i + 1, "calls checked", flush=True)
        return {
            "startup": o,
            "cases": records,
            "guards": baseline,
            "rom_font": rom_font,
            "rom_metrics": rom_metrics,
            "symbols": {k: syms[k] for k in ["font_data", "label_data", "metric_data"]},
            "fixture_sha256": V.T.sha(image),
            "costs": {
                "layout_bytes": syms["layout_end"] - syms["layout_measure"],
                "text_bytes": syms["text_end"] - syms["text_char"],
                "backend_bytes": syms["text_backend_end"] - syms["text_backend_start"],
                "layout_context": 80,
                "text_context": 96,
                "backend_context": 48,
                "font": 512,
            },
        }
    finally:
        m.close()


def sources(c: dict) -> list[Path]:
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/proportional-text"
    files = (
        list(folder.glob("*.asm")) + list(folder.glob("*.inc")) + [folder / "Makefile"]
    )
    files += (
        list(S.glob("*.py"))
        + list(S.glob("*.json"))
        + [S / ("font-" + c["cpu"] + ".inc"), S / ("widths-" + c["cpu"] + ".inc")]
        + list((S / "mistakes").glob(c["cpu"] + "-*.inc"))
        + [S / (c["cpu"] + ".inc")]
    )
    files += [
        ROOT / "scripts" / n
        for n in [
            "verify-proportional-text.py",
            "check-proportional-text.py",
            "test_proportional_text.py",
            "verify-bitmap-text.py",
            "verify-geometry.py",
            "verify-game-loops.py",
            "verify-tilemaps.py",
        ]
    ]
    for category, names in [
        (
            "bitmap-text",
            [
                c["cpu"] + ".inc",
                "font-" + c["cpu"] + ".inc",
                "font.json",
                "model.py",
                "build.py",
                "systems.json",
                "cases.py",
            ],
        ),
        (
            "geometry",
            ["model.py", "cpc.inc"]
            if c["machine_id"] == "amstrad-cpc"
            else ["model.py"],
        ),
        (
            "drawing-foundations",
            [] if c["machine_id"] == "amstrad-cpc" else [c["cpu"] + ".inc"],
        ),
    ]:
        files += [S.parent / category / n for n in names]
    if c["machine_id"] == "spectrum":
        files.append(folder.parent / "bitmap-addressing/bitmap-addressing.inc")
    return files


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--only")
    a = p.parse_args()
    for c in json.loads((S / "systems.json").read_text()):
        if a.only and c["machine_id"] != a.only:
            continue
        tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
        for key, path in [
            (c["binary"], a.native / c["binary"]),
            ("asm198x", Path(a.assembler)),
        ]:
            require(
                V.T.sha(path) == tools[key]["binary_sha256"], "Unqualified tool: " + key
            )
        out = (
            ROOT
            / c["folder"]
            / "patterns/assembly/rendering/proportional-text/build/verification"
        )
        out.mkdir(parents=True, exist_ok=True)
        result = {"machine_id": c["machine_id"], "variants": {}}
        for variant in B.VARIANTS:
            result["variants"][variant] = execute(c, a, variant, out)
        for key in ["advance"]:
            require(
                result["variants"][key + "-fixed"]["fixture_sha256"]
                == result["variants"]["positive"]["fixture_sha256"],
                "Repaired fixture differs from original",
            )
        result["sources"] = {str(f.relative_to(ROOT)): V.T.sha(f) for f in sources(c)}
        result["tools"] = {
            k: tools[k]["binary_sha256"] for k in [c["binary"], "asm198x"]
        }
        result["artifacts"] = {
            f.name: V.T.sha(f) for f in out.iterdir() if f.suffix in [".png", ".z"]
        }
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        print(
            c["machine_id"],
            "PASS",
            len(result["variants"]["positive"]["cases"]) + 1,
            "positive calls; customisation and two fault/repair observations",
            flush=True,
        )
