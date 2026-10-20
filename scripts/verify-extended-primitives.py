"""Execute Oric/ANTIC primitives independently on three released native machines."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/extended-primitives"


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


V = load("extended_transport", ROOT / "scripts/verify-geometry.py")
B = load("extended_build", S / "build.py")
M = load("extended_model", S / "model.py")
C = load("extended_cases", S / "cases.py")
require = V.require
COMMANDS = {"pixel": 1, "read": 2, "hspan": 3, "vspan": 4, "fill": 5, "box": 6}


def inputs(r):
    data = bytearray([165] * 48)
    for at, value in zip([0, 2, 4, 6], r["coords"], strict=True):
        data[at : at + 2] = (value & 65535).to_bytes(2, "little")
    data[8] = r["op"]
    return bytes(data)


def status(actual, submitted, expected):
    require(
        actual[:9] == submitted[:9] and actual[11] == submitted[11],
        "Primitive inputs changed",
    )
    require(
        actual[9] == int(expected["accepted"]) and actual[10] == expected["read"],
        "Primitive status/read differs",
    )
    require(
        int.from_bytes(actual[40:42], "little") == expected["writes"],
        "Byte-write count differs",
    )


def sources(c):
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/pixels-and-boxes"
    return (
        [
            S / n
            for n in [
                "build.py",
                "model.py",
                "cases.py",
                "systems.json",
                "toolchain.json",
                "oric.inc" if c["machine_id"] == "oric" else "antic.inc",
            ]
        ]
        + [folder / "demo.asm", folder / "Makefile"]
        + [
            ROOT / "scripts" / n
            for n in [
                "verify-extended-primitives.py",
                "check-extended-primitives.py",
                "verify-geometry.py",
                "verify-game-loops.py",
                "verify-tilemaps.py",
            ]
        ]
    )


def segments(c):
    guards = [
        (c["context"] - 16, 16),
        (c["context"] + 48, 16),
        (c["base"] - 16, 16),
        (c["base"] + c["length"], 16),
    ]
    if c["display_list"] is not None:
        guards.append((c["display_list"], 768))
    return guards


def guards(m, c):
    return [V.read(m, a, n).hex() for a, n in segments(c)]


def capture(m, c, out, name, data, match=True):
    path = out / (name + ".png")
    m.call("save_screenshot", path=str(path))
    actual = V.PNG.raster(path)
    expected = M.frame(c, data)
    require(actual[0] == expected[0], "Native frame dimensions differ")
    errors = sum(
        actual[1][i : i + 4] != expected[1][i : i + 4]
        for i in range(0, len(actual[1]), 4)
    )
    require(
        errors == 0 if match else errors > 0,
        "Independent native picture differs" if match else "Fault was invisible",
    )
    return errors


def observe(m, c, out, name):
    p = out / (name + ".dat.z")
    p.write_bytes(zlib.compress(V.read(m, c["base"], c["length"]), 9))
    return {
        "memory": p.name,
        "context": V.read(m, c["context"], 48).hex(),
        "mailbox": V.read(m, c["command"], 2).hex(),
        "guards": guards(m, c),
    }


def execute(c, args, out, variant):
    _, image = B.build(c["machine_id"], args.assembler, variant)
    syms = V.T.symbols(image.parent / "selected.sym")
    m = V.T.Machine(B.command(c, image, args.native))
    try:
        m.call("run_frames", frames=120)
        require(
            V.read(m, c["command"], 2) == b"\x00\xef",
            "Original reset caller did not complete",
        )
        initial = {"id": "startup", "kind": "box", "coords": [13, 27, 91, 53], "op": 0}
        data = M.baseline(c)
        expected = M.evaluate(c, data, initial)
        if variant == "positive":
            start = observe(m, c, out, "startup")
            require(
                zlib.decompress((out / start["memory"]).read_bytes()) == bytes(data),
                "Direct caller bitmap differs",
            )
            # The direct caller deliberately initialises only its used public fields.
            actual = bytes.fromhex(start["context"])
            submitted = inputs(initial)
            require(actual[:9] == submitted[:9], "Direct caller input differs")
            require(
                actual[9] == 1
                and int.from_bytes(actual[40:42], "little") == expected["writes"],
                "Direct caller result differs",
            )
            capture(m, c, out, "startup", data)
            start.update(request=initial, capture="startup.png")
            for addr, n in segments(c)[:2]:
                V.write(m, addr, bytes((i * 23 + 43) & 255 for i in range(n)))
            baseline = guards(m, c)
            data = M.baseline(c, True)
            V.write(m, c["base"], data)
            records = []
            scene = False
            for i, r in enumerate(C.cases(c)):
                if r.get("scene") and not scene:
                    data = M.baseline(c)
                    V.write(m, c["base"], data)
                    scene = True
                if "control" in r:
                    at = M.offset(c, *r["control"])
                    data[at] = r.get("value", 7)
                    m.call("poke_byte", addr=c["base"] + at, value=r.get("value", 7))
                submitted = inputs(r)
                V.write(m, c["context"], submitted)
                frames = V.request(m, c, COMMANDS[r["kind"]])
                expected = M.evaluate(c, data, r)
                o = observe(m, c, out, r["id"])
                require(
                    zlib.decompress((out / o["memory"]).read_bytes()) == bytes(data),
                    c["machine_id"] + " complete bitmap differs: " + str(r),
                )
                status(bytes.fromhex(o["context"]), submitted, expected)
                require(o["guards"] == baseline, "Primitive guard/display list changed")
                o.update(id=r["id"], request=r, observed_frames=frames)
                if i % 16 == 0 or r.get("scene") or "control" in r:
                    capture(m, c, out, r["id"], data)
                    o["capture"] = r["id"] + ".png"
                records.append(o)
                if i % 32 == 0:
                    print(c["machine_id"], i + 1, "primitive calls checked", flush=True)
            return {
                "startup": start,
                "cases": records,
                "guards": baseline,
                "fixture_sha256": V.T.sha(image),
                "costs": {
                    "backend_bytes": syms["backend_end"] - syms["backend_start"],
                    "row_table_bytes": c["height"] * 2,
                    "context_bytes": 48,
                    "display_list_bytes": 0 if c["machine_id"] == "oric" else 582,
                    "display_list_allocation": 0 if c["machine_id"] == "oric" else 768,
                },
                "reset_stub_sha256": V.T.sha(image.parent / "bios.rom")
                if c["machine_id"] == "atari-5200"
                else None,
            }
        data = M.baseline(c)
        V.write(m, c["base"], data)
        before = guards(m, c)
        request = {"id": variant, "kind": "pixel", "coords": [0, 12, 0, 0], "op": 0}
        V.write(m, c["context"], inputs(request))
        frames = V.request(m, c, 1)
        M.evaluate(c, data, request)
        o = observe(m, c, out, variant)
        actual = zlib.decompress((out / o["memory"]).read_bytes())
        errors = sum(a != b for a, b in zip(actual, data, strict=True))
        require(
            errors > 0 and bytes.fromhex(o["context"])[9] == 1,
            "Fault must finish accepted, incorrect drawing",
        )
        require(o["guards"] == before, "Fault escaped owned allocation")
        pixels = capture(m, c, out, variant, data, False)
        o.update(
            request=request,
            observed_frames=frames,
            capture=variant + ".png",
            memory_mismatches=errors,
            pixel_mismatches=pixels,
            guard_before=before,
            fixture_sha256=V.T.sha(image),
        )
        return o
    finally:
        m.close()


def verify(c, args):
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    for key, p in [
        (c["binary"], args.native / c["binary"]),
        ("asm198x", Path(args.assembler)),
    ]:
        require(V.T.sha(p) == tools[key]["binary_sha256"], "Unqualified tool: " + key)
    out = (
        ROOT
        / c["folder"]
        / "patterns/assembly/rendering/pixels-and-boxes/build/verification"
    )
    out.mkdir(parents=True, exist_ok=True)
    for p in out.iterdir():
        if p.suffix in [".json", ".png", ".z"]:
            p.unlink()
    result = {
        "machine_id": c["machine_id"],
        "positive": execute(c, args, out, "positive"),
        "faults": {},
    }
    for variant in ["mask-fault", "row-fault"]:
        result["faults"][variant] = execute(c, args, out, variant)
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
        "calls; two completed faults caught",
        flush=True,
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    a = p.parse_args()
    configs = json.loads((S / "systems.json").read_text())
    if a.system:
        configs = [c for c in configs if c["machine_id"] == a.system]
    require(bool(configs), "No matching system")
    for c in configs:
        verify(c, a)
