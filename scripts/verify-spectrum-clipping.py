"""Fresh firmware-free Spectrum clipping and cropped-image checks."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "clip", ROOT / "scripts/verify-sprite-clipping.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def drawing(args: argparse.Namespace, out: Path, broken: bool = False) -> None:
    source = C.flatten(C.folder("spectrum") / "demo.asm")
    body = source.split("start:\n", 1)[1].split("    ld hl,$cafe", 1)[0]
    routine = (
        (C.folder("spectrum") / "clip.inc").read_text()
        + "\n"
        + (C.folder("spectrum") / "draw.inc").read_text()
        + "\n"
        + (
            C.folder("spectrum").parent / "bitmap-addressing/bitmap-addressing.inc"
        ).read_text()
    )
    if broken:
        routine = routine.replace("    ld e,(ix+8)", "    ld e,0")
    declarations = (
        "org $b000\n"
        + (C.folder("spectrum") / "shapes.inc").read_text()
        + "\norg $b100\ncontext: defs 32,0\n"
    )
    actual = C.Z.execute(
        out,
        C.Z.caller(body, routine, declarations),
        [(0x4000, 6912), (0xB000, 64)],
        argparse.Namespace(assembler=args.assembler, emulator=args.spectrum),
    )
    C.require(
        bytes(actual[0]) == C.expected_scene("spectrum") + bytes([71]) * 768,
        "Spectrum CPU cropped image mismatch",
    )
    expected = bytes(
        int(v)
        for v in C.re.split(
            r"defb\s+", (C.folder("spectrum") / "shapes.inc").read_text(), maxsplit=1
        )[1]
        .strip()
        .split(",")
    )
    C.require(bytes(actual[1]) == expected, "Spectrum CPU source preservation mismatch")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--emulator", required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    args.spectrum = args.emulator
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    C.axes(args, out / "axis", "spectrum")
    drawing(args, out / "scene")
    controls = {}
    for name, fn in [
        ("axis", lambda: C.axes(args, out / "broken-axis", "spectrum", True)),
        ("source-crop", lambda: drawing(args, out / "broken-crop", True)),
    ]:
        try:
            fn()
        except ValueError as error:
            C.require(
                "mismatch" in str(error),
                "Control failed before output oracle: " + str(error),
            )
            controls[name] = str(error)
        else:
            raise ValueError("Broken " + name + " escaped oracle")
    result = {
        "status": "passed",
        "axis_cases": len(C.CASES),
        "native_scenes": 1,
        "rejected_controls": controls,
        "observer_sha256": C.R.sha(Path(__file__)),
        "fixture_sha256": C.R.sha(ROOT / "scripts/verify-sprite-clipping.py"),
        "limits": "Synthetic-ROM 48K CPU fixture, DI. No ROM boot, hardware or frame-budget claim.",
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("220 axes, cropped image and two controls passed")


if __name__ == "__main__":
    main()
