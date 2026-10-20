"""Execute four geometry components and CPC packing; retain full per-call outcomes.

Only original reset callers are used. No firmware, OS coexistence or frame-budget
claim is made. Positive and deliberately faulty executing builds run separately.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/geometry"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise ValueError(path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = load("geometry_transport", ROOT / "scripts/verify-game-loops.py")
B = load("geometry_builder", SHARED / "build.py")
M = load("geometry_model", SHARED / "model.py")
C = load("geometry_cases", SHARED / "cases.py")
PNG = load("geometry_png", ROOT / "scripts/verify-tilemaps.py")
COMMANDS = {
    "line": 1,
    "circle": 2,
    "ellipse": 3,
    "fill_circle": 4,
    "fill_ellipse": 5,
    "pixel": 6,
    "read": 7,
    "hspan": 8,
    "vspan": 9,
    "fill": 10,
    "box": 11,
}


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def read(m, addr: int, length: int) -> bytes:
    return bytes(
        v
        for i in range(0, length, 128)
        for v in m.call("memory_read", addr=addr + i, len=min(128, length - i))["bytes"]
    )


def write(m, addr: int, data: bytes) -> None:
    for i, v in enumerate(data):
        m.call("poke_byte", addr=addr + i, value=v)


def request(m, c: dict[str, Any], command: int) -> int:
    m.call("poke_byte", addr=c["command"], value=command)
    for i in range(512):
        m.call("run_frames", frames=2)
        if read(m, c["command"], 1) == b"\0":
            m.call("run_frames", frames=2)
            return (i + 1) * 2
    raise AssertionError(
        f"{c['machine_id']} command {command} did not complete within bounded observation"
    )


def inputs(c: dict[str, Any], r: dict[str, Any], primitive: bool = False) -> bytes:
    data = bytearray([165] * (48 if primitive else 160))
    for at, value in zip([0, 2, 4, 6], r["coords"], strict=True):
        data[at : at + 2] = (value & 65535).to_bytes(2, c["order"])
    data[8] = r["op"]
    data[11] = r.get("pen", 1)
    if not primitive:
        data[9] = r.get("flags", 0)
        for at, value in zip(
            [12, 14, 16, 18],
            r.get("clip", [0, 0, c["width"], c["height"]]),
            strict=True,
        ):
            data[at : at + 2] = (value & 65535).to_bytes(2, c["order"])
    return bytes(data)


def sources(c: dict[str, Any]) -> list[Path]:
    files = [
        SHARED / n
        for n in [
            "build.py",
            "model.py",
            "cases.py",
            "systems.json",
            "toolchain.json",
            "LICENSE-Zingl.txt",
            "arithmetic-bound.json",
            c["cpu"] + ".inc",
        ]
    ]
    files += [
        ROOT / "scripts" / n
        for n in [
            "verify-geometry.py",
            "check-geometry.py",
            "verify-game-loops.py",
            "verify-tilemaps.py",
            "verify-geometry-arithmetic.py",
        ]
    ]
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/geometry"
    files += [folder / "demo.asm", folder / "Makefile"]
    files += (
        [SHARED / "cpc.inc"]
        if c["machine_id"] == "amstrad-cpc"
        else [SHARED.parent / "drawing-foundations" / (c["cpu"] + ".inc")]
    )
    if c["machine_id"] == "spectrum":
        files += [folder.parent / "bitmap-addressing/bitmap-addressing.inc"]
    return files


def segments(c: dict[str, Any]) -> list[tuple[int, int]]:
    # Guard the two private workspaces and observe the bitmap boundary.
    result = [
        (c["g"] - 16, 16),
        (c["g"] + 160, 16),
        (c["context"] - 16, 16),
        (c["context"] + 48, 16),
        (c["base"] - 16, 16),
    ]
    end = c["base"] + c["length"]
    if end < 65536:
        result.append((end, 768 if c["machine_id"] == "spectrum" else 16))
    return result


def guards(m, c: dict[str, Any]) -> list[str]:
    return [read(m, a, n).hex() for a, n in segments(c)]


def geometry_status(
    c: dict[str, Any], actual: bytes, submitted: bytes, expected: dict[str, Any]
) -> None:
    require(
        actual[:10] == submitted[:10] and actual[11:20] == submitted[11:20],
        "Geometry request inputs changed",
    )
    require(actual[10] == int(expected["accepted"]), "Geometry acceptance differs")
    require(
        int.from_bytes(actual[20:24], c["order"]) == expected["writes"],
        "Geometry write count differs",
    )
    require(
        int.from_bytes(actual[24:26], c["order"]) == expected["calls"],
        "Geometry backend-call count differs",
    )


def primitive_status(
    c: dict[str, Any], actual: bytes, submitted: bytes, expected: dict[str, Any]
) -> None:
    require(
        actual[:9] == submitted[:9] and actual[11] == submitted[11],
        "CPC primitive request changed",
    )
    require(
        actual[9] == int(expected["accepted"]) and actual[10] == expected["read"],
        "CPC acceptance/readback differs",
    )
    require(
        int.from_bytes(actual[40:42], "little") == expected["writes"],
        "CPC primitive write count differs",
    )


def capture(
    m,
    c: dict[str, Any],
    out: Path,
    name: str,
    grid: list[bytearray],
    match: bool = True,
) -> int:
    path = out / (name + ".png")
    m.call("save_screenshot", path=str(path))
    actual = PNG.raster(path)
    expected = M.frame(c, grid)
    require(
        actual[0] == expected[0],
        f"{c['machine_id']} native frame dimensions differ: {actual[0]}",
    )
    different = sum(
        actual[1][i : i + 4] != expected[1][i : i + 4]
        for i in range(0, len(actual[1]), 4)
    )
    if match:
        require(
            different == 0,
            f"{c['machine_id']} {name}: native pixels differ ({different})",
        )
    else:
        require(
            different > 0, "Completed faulty build was not detected in native pixels"
        )
    return different


def observe(m, c: dict[str, Any], out: Path, name: str) -> dict[str, Any]:
    memory = read(m, c["base"], c["length"])
    path = out / (name + ".dat.z")
    path.write_bytes(zlib.compress(memory, 9))
    return {
        "id": name,
        "memory": path.name,
        "context": read(m, c["g"], 160).hex(),
        "backend": read(m, c["context"], 48).hex(),
        "guards": guards(m, c),
        "mailbox": read(m, c["command"], 2).hex(),
    }


def run_positive(c: dict[str, Any], args, out: Path) -> dict[str, Any]:
    _, image = B.build(c["machine_id"], args.assembler)
    fixture_hash = T.sha(image)
    syms = T.symbols(image.parent / "selected.sym")
    costs = {
        "geometry_bytes": syms["geometry_end"] - syms["geo_line"],
        "backend_bytes": syms["geometry_backend_end"] - syms["geometry_backend_start"],
        "geometry_context": 160,
        "backend_context": 48,
        "row_table_bytes": 512 if c["cpu"] == "6502" else 0,
    }
    m = T.Machine(
        [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    try:
        m.call("run_frames", frames=120)
        require(read(m, c["command"], 2) == b"\0\xef", "Original caller not ready")
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        startup = {
            "id": "startup",
            "kind": "ellipse",
            "coords": [80, 70, 48, 24],
            "op": 0,
            "pen": 1,
        }
        expected = M.apply(c, grid, startup)
        o = observe(m, c, out, "startup")
        geometry_status(c, bytes.fromhex(o["context"]), inputs(c, startup), expected)
        require(
            zlib.decompress((out / o["memory"]).read_bytes()) == M.packed(c, grid),
            "Direct caller ellipse differs",
        )
        capture(m, c, out, "startup", grid)
        o.update(request=startup, capture="startup.png")
        initial_guard = guards(m, c)
        # Seed writable workspace guards independently of whichever instruction uses them.
        for address, n in segments(c)[:4]:
            write(m, address, bytes((i * 17 + 53) & 255 for i in range(n)))
        initial_guard = guards(m, c)
        records = []
        padding = 0
        if c["machine_id"] == "amstrad-cpc":
            write(m, c["base"], bytes([165]) * c["length"])
            padding = 165
            grid = [
                bytearray(1 if x % 2 == 0 else 2 for x in range(c["width"]))
                for _ in range(c["height"])
            ]
            g_initial = read(m, c["g"], 160)
            for i, r in enumerate(C.cpc_cases()):
                data = inputs(c, r, True)
                write(m, c["context"], data)
                frames = request(m, c, COMMANDS[r["kind"]])
                expected = M.primitive(c, grid, r)
                rec = observe(m, c, out, r["id"])
                actual = zlib.decompress((out / rec["memory"]).read_bytes())
                require(
                    actual == M.packed(c, grid, padding),
                    f"CPC {r['id']}: complete packed picture differs",
                )
                primitive_status(c, bytes.fromhex(rec["backend"]), data, expected)
                require(
                    rec["context"] == g_initial.hex(),
                    "CPC backend changed geometry workspace",
                )
                require(rec["guards"] == initial_guard, "CPC backend guard changed")
                rec.update(request=r, observed_frames=frames, stage="primitive")
                if i % 32 == 0 or i == len(C.cpc_cases()) - 1:
                    capture(m, c, out, r["id"], grid)
                    rec["capture"] = r["id"] + ".png"
                records.append(rec)
        request(m, c, 12)
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        in_scene = False
        for i, r in enumerate(C.geometry_cases(c)):
            if r.get("scene") and not in_scene:
                request(m, c, 12)
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
                in_scene = True
            data = inputs(c, r)
            write(m, c["g"], data)
            frames = request(m, c, COMMANDS[r["kind"]])
            expected = M.apply(c, grid, r)
            rec = observe(m, c, out, r["id"])
            actual = zlib.decompress((out / rec["memory"]).read_bytes())
            require(
                actual == M.packed(c, grid, padding),
                f"{c['machine_id']} {r['id']} {r}: complete bitmap differs",
            )
            geometry_status(c, bytes.fromhex(rec["context"]), data, expected)
            require(
                rec["guards"] == initial_guard,
                f"{c['machine_id']} {r['id']}: guard differs",
            )
            rec.update(request=r, observed_frames=frames, stage="geometry")
            if i % 32 == 0 or r.get("scene") or (r["coords"][2:] == [1, 255]):
                capture(m, c, out, r["id"], grid)
                rec["capture"] = r["id"] + ".png"
            records.append(rec)
            if i % 32 == 0:
                print(c["machine_id"], i + 1, "geometry calls checked", flush=True)
        return {
            "startup": o,
            "cases": records,
            "guards": initial_guard,
            "padding": padding,
            "fixture_sha256": fixture_hash,
            "costs": costs,
        }
    finally:
        m.close()


def run_fault(c: dict[str, Any], args, out: Path, variant: str) -> dict[str, Any]:
    _, image = B.build(c["machine_id"], args.assembler, variant)
    m = T.Machine(
        [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    try:
        m.call("run_frames", frames=120)
        require(
            read(m, c["command"], 2) == b"\0\xef",
            "Fault did not finish its direct startup call",
        )
        request(m, c, 12)
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        primitive = variant == "packing-fault"
        r = {
            "id": variant,
            "kind": "pixel" if primitive else "ellipse",
            "coords": [1, 20, 0, 0] if primitive else [70, 70, 30, 12],
            "op": 0,
            "pen": 3 if primitive else 1,
        }
        data = inputs(c, r, primitive)
        write(m, c["context"] if primitive else c["g"], data)
        before = guards(m, c)
        frames = request(m, c, COMMANDS[r["kind"]])
        rec = observe(m, c, out, variant)
        (M.primitive if primitive else M.apply)(c, grid, r)
        actual = zlib.decompress((out / rec["memory"]).read_bytes())
        correct = M.packed(c, grid)
        mismatches = sum(a != b for a, b in zip(actual, correct, strict=True))
        require(
            mismatches > 0,
            "Faulty executing code did not fail the independent memory model",
        )
        require(rec["guards"] == before, "Fault escaped the owned bitmap")
        status = (
            bytes.fromhex(rec["backend"])[9]
            if primitive
            else bytes.fromhex(rec["context"])[10]
        )
        require(status == 1, "Fault control must be an accepted and completed draw")
        pixel_errors = capture(m, c, out, variant, grid, False)
        rec.update(
            request=r,
            capture=variant + ".png",
            completed=True,
            accepted=True,
            observed_frames=frames,
            memory_mismatches=mismatches,
            pixel_mismatches=pixel_errors,
            fixture_sha256=T.sha(image),
            guard_before=before,
        )
        return rec
    finally:
        m.close()


def verify(c: dict[str, Any], args) -> None:
    tools = {t["tool"]: t for t in json.loads((SHARED / "toolchain.json").read_text())}
    require(
        T.sha(args.native / c["binary"]) == tools[c["binary"]]["binary_sha256"],
        "Unqualified emulator",
    )
    require(
        T.sha(Path(args.assembler)) == tools["asm198x"]["binary_sha256"],
        "Unqualified assembler",
    )
    out = ROOT / c["folder"] / "patterns/assembly/rendering/geometry/build/verification"
    out.mkdir(parents=True, exist_ok=True)
    for p in out.iterdir():
        if p.suffix in [".json", ".png", ".z"]:
            p.unlink()
    result = {
        "machine_id": c["machine_id"],
        "configuration": "Original reset fixture; native mode; released Asm198x 0.0.71 and Emu198x 0.39.0",
        "positive": run_positive(c, args, out),
        "faults": {},
    }
    for variant in ["curve-fault"] + (
        ["packing-fault"] if c["machine_id"] == "amstrad-cpc" else []
    ):
        result["faults"][variant] = run_fault(c, args, out, variant)
    result["sources"] = {str(p.relative_to(ROOT)): T.sha(p) for p in sources(c)}
    result["tool_identity"] = {
        key: tools[key]["binary_sha256"] for key in [c["binary"], "asm198x"]
    }
    result["artifacts"] = {
        p.name: T.sha(p) for p in out.iterdir() if p.suffix in [".png", ".z"]
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(
        c["machine_id"],
        "PASS",
        1 + len(result["positive"]["cases"]),
        "calls;",
        len(result["faults"]),
        "completed fault controls caught",
        flush=True,
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    a = p.parse_args()
    systems = json.loads((SHARED / "systems.json").read_text())
    if a.system:
        systems = [c for c in systems if c["machine_id"] == a.system]
        if not systems:
            p.error("Unknown geometry system")
    require(bool(systems), "No systems selected")
    for c in systems:
        verify(c, a)
