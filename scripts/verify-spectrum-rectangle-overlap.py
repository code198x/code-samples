"""ROM-load independent Spectrum assembly and BASIC rectangle callers."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    return v


A = module("observer", "verify-spectrum-assembly-deadlines.py")
T = A.T
C = module("c64", "verify-c64-rectangle-overlap.py").C
D = module("basic", "verify-spectrum-basic-deadlines.py")
FS = {
    lang: ROOT / f"sinclair-zx-spectrum/patterns/{lang}/physics/rectangle-overlap"
    for lang in ("assembly", "basic")
}
VARIANTS = ("demo", "custom", "wrong", "repaired", "boundaries")


def source_paths(lang):
    F = FS[lang]
    names = (
        (
            "demo.asm",
            "custom.asm",
            "wrong.asm",
            "repaired.asm",
            "caller.inc",
            "display.inc",
            "wrong-touch.inc",
            "build.py",
            "Makefile",
        )
        if lang == "assembly"
        else ("caller.bas", "overlap.bas", "build.py", "Makefile")
    )
    return (
        [F / n for n in names]
        + (
            [F / "../../framework/collect-and-respond/collision.inc"]
            if lang == "assembly"
            else []
        )
        + [
            ROOT / "cross-platform/patterns/physics/rectangle-overlap/cases.py",
            Path(__file__),
            ROOT / "scripts/verify-c64-rectangle-overlap.py",
        ]
        + A.source_paths()
        + D.source_paths()
    )


def basic_cases():
    c = C.cases(65535)
    for n, v in [("negative", -1), ("too-high", 65536), ("fraction", 2.5)]:
        c.append({"name": n, "a": [v, 2, 8, 6], "b": [1, 1, 9, 9], "expected": -1})
    return c


def build(args):
    for F in FS.values():
        subprocess.run(
            ["python3", str(F / "build.py")],
            check=True,
            timeout=60,
            env=os.environ
            | {"ASM198X": str(args.assembler), "BUILD198X": str(args.build198x)},
        )
    F = FS["basic"]
    B = F / "build"
    cases = basic_cases()
    src = (
        f"""10 CLEAR 49999: BORDER 0: PAPER 0: INK 7: CLS
20 FOR i=0 TO {len(cases) - 1}
30 READ al,ay,ar,ab,bl,by,br,bb
40 GO SUB 3000
50 POKE 50010+i,rr+1
60 NEXT i
70 POKE 50000,165: POKE 50001,239
80 STOP
"""
        + (F / "overlap.bas").read_text()
        + "".join(
            str(7000 + i) + " DATA " + ",".join(map(str, c["a"] + c["b"])) + "\n"
            for i, c in enumerate(cases)
        )
    )
    (B / "boundaries.bas").write_text(D.canonical(src))
    subprocess.run(
        [
            str(args.build198x),
            "basic",
            str(B / "boundaries.bas"),
            "--machine",
            "sinclair-zx-spectrum",
            "-o",
            str(B / "boundaries.tap"),
        ],
        check=True,
        timeout=30,
    )


def run(args, lang, name):
    F = FS[lang]
    V = F / "verification"
    V.mkdir(exist_ok=True)
    B = F / "build"
    stem = "demo" if lang == "assembly" and name == "boundaries" else name
    tap = B / (stem + ".tap")
    payload = list(A.blocks(tap, 4 if lang == "assembly" else 2)[-1][1:-1])
    m = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.rom)])

    def read(addr, n):
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(tap))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        loaded = []
        stops = []
        if lang == "assembly":
            sym = T.symbols(F / (stem + ".sym"))
            for _ in range(30):
                stop = m.call("run_until_pc", addr=32768, max_steps=1000000)
                stops.append(stop)
                if stop["reached"]:
                    break
            T.require(stop["reached"], "USR entry absent")
            loaded = read(32768, len(payload))
            T.require(loaded == payload, "Loaded code differs before entry")
            stop = m.call("run_until_pc", addr=sym["hold"], max_steps=300000)
            T.require(stop["reached"], "Native assembly cases incomplete")
            guards = [read(sym[n], 1)[0] for n in ("completed", "ready")]
            values = read(sym["results"], len(C.cases()))
            expected = [c["expected"] for c in C.cases()]
            result = read(sym["result"], 1)[0]
            costs = {
                "code_bytes": sym["rect_a"] - sym["boxes_overlap"],
                "state_bytes": 8,
                "payload_bytes": len(payload),
            }
            T.require(
                guards == [165, 239] and (values == expected) == (name != "wrong"),
                "Geometry oracle/guards differ",
            )
        else:
            for _ in range(100):
                m.call("run_frames", frames=200)
                if read(50000, 2) == (
                    [165, 239]
                    if name == "boundaries"
                    else [2 if name in ("demo", "wrong") else 1, 165]
                ):
                    break
            else:
                raise AssertionError("BASIC did not complete")
            ptrs = {
                n: int.from_bytes(bytes(read(a, 2)), "little")
                for n, a in [("prog", 23635), ("vars", 23627), ("edit", 23641)]
            }
            loaded = read(ptrs["prog"], ptrs["vars"] - ptrs["prog"])
            T.require(loaded == payload, "ROM-loaded tokenised program differs")
            if name == "boundaries":
                values = read(50010, len(basic_cases()))
                expected = [c["expected"] + 1 for c in basic_cases()]
                guards = read(50000, 2)
                result = -1
                T.require(
                    values == expected and guards == [165, 239],
                    "BASIC interval/range oracle differs",
                )
            else:
                values = []
                guards = read(50000, 2)
                result = guards[0] - 1
                expected = []
            costs = {
                "token_bytes": len(payload),
                "variable_bytes": ptrs["edit"] - ptrs["vars"],
                "reserved_observer_bytes": len(basic_cases()) + 10,
            }
        m.call("run_frames", frames=3)
        render = None
        image = None
        if name != "boundaries":
            render = A.pixels(m, 0, str(result))
            image = V / (name + ".png")
            m.call("save_screenshot", path=str(image))
        return {
            "result": result,
            "bytes": values,
            "expected": expected,
            "guards": guards,
            "loaded_bytes": loaded,
            "payload_sha256": hashlib.sha256(bytes(payload)).hexdigest(),
            "tap_sha256": T.sha(tap),
            "costs": costs,
            "pixels": render,
            "image": image.name if image else None,
            "image_sha256": T.sha(image) if image else None,
            "server": m.server["serverInfo"],
            "stops": stops,
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("assembler", "build198x", "emulator", "rom"):
        p.add_argument("--" + name, type=Path, required=True)
    args = p.parse_args()
    build(args)
    for lang, F in FS.items():
        V = F / "verification"
        V.mkdir(exist_ok=True)
        cfg = {
            "model": "Spectrum 48K PAL stock ROM",
            "assembler_sha256": T.sha(args.assembler),
            "build198x_sha256": T.sha(args.build198x),
            "emulator_sha256": T.sha(args.emulator),
            "rom_sha256": T.sha(args.rom),
        }
        (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
        r = {
            "system": "sinclair-zx-spectrum",
            "language": lang,
            "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in source_paths(lang)},
            "configuration": cfg,
            "cases": {},
        }
        for name in VARIANTS:
            r["cases"][name] = run(args, lang, name)
            (V / "results.json").write_text(json.dumps(r, indent=2) + "\n")
            print(lang, name, "passed", flush=True)


if __name__ == "__main__":
    main()
