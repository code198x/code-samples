"""Fresh CPU-level Spectrum pixel positioning, source preservation and controls."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "phases", ROOT / "scripts/verify-sprite-phases.py"
)
assert spec and spec.loader
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)


def check(args: argparse.Namespace, out: Path, broken: str = "") -> None:
    source = V.C.flatten(V.folder("spectrum") / "demo.asm")
    body = source.split("start:\n", 1)[1].split("    ld hl,$cafe", 1)[0]
    paths = [
        V.folder("spectrum") / "phase.inc",
        V.folder("spectrum") / "draw.inc",
        V.folder("spectrum").parent / "clipped-sprites/clip.inc",
        V.folder("spectrum").parent / "bitmap-addressing/bitmap-addressing.inc",
    ]
    code = "\n".join(p.read_text() for p in paths)
    code = V.variant(code, "spectrum", broken)
    declarations = (
        "org $b000\n"
        + (V.folder("spectrum") / "phases.inc").read_text()
        + "\norg $c000\ncontext: defs 32,0\n"
    )
    actual = V.Z.execute(
        out,
        V.Z.caller(body, code, declarations),
        [(0x4000, 6912), (0xB000, 784)],
        argparse.Namespace(assembler=args.assembler, emulator=args.emulator),
    )
    V.C.require(
        bytes(actual[0]) == V.expected("spectrum") + bytes([71]) * 768,
        "spectrum phase bitmap mismatch",
    )
    symbols = V.T.symbols(out / "caller.sym")
    V.C.require(
        bytes(actual[1]) == V.asset_bytes("spectrum", symbols),
        "Spectrum source bytes changed",
    )


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--emulator", required=True)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    check(a, out / "normal")
    controls = {}
    for name in ["phase", "stride", "floor"]:
        try:
            check(a, out / ("broken-" + name), name)
        except ValueError as error:
            V.C.require(
                str(error) == "spectrum phase bitmap mismatch",
                "Control failed before bitmap oracle: " + str(error),
            )
            controls[name] = str(error)
        else:
            raise ValueError("Broken " + name + " escaped bitmap oracle")
    result = {
        "status": "passed",
        "phases": 8,
        "draws": 40,
        "rejected_controls": controls,
        "observer_sha256": V.R.sha(Path(__file__)),
        "fixture_sha256": V.R.sha(ROOT / "scripts/verify-sprite-phases.py"),
        "limits": "Synthetic-ROM 48K CPU fixture, DI; no ROM startup, animation cadence or hardware claim.",
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("All eight phases, 40 draws and three controls passed")


if __name__ == "__main__":
    main()
