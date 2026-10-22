"""Qualify four more 6502 map callers through original reset fixtures.

No restricted firmware is required. These are CPU/RAM tests, not display tests.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path
from shutil import which
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/tile-map"
CONFIG = ROOT / "docs/assembly-map-gaps.json"


def load(name: str, path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


V = load("native_tilemaps", ROOT / "scripts/verify-native-tilemaps.py")
T = V.T


def folder(c: dict) -> Path:
    return ROOT / c["system"] / "patterns/assembly/rendering/tile-map"


def inputs(c: dict) -> dict[str, str]:
    return {
        str(p.relative_to(ROOT)): T.sha(p)
        for p in (
            folder(c) / "demo.asm",
            folder(c) / "properties.inc",
            folder(c) / "customise-properties.inc",
            SHARED / "6502.inc",
            SHARED / "mistakes/wrong-stride-6502.inc",
            SHARED / "mistakes/write-without-valid-6502.inc",
            CONFIG,
            Path(__file__),
            ROOT / "scripts/verify-native-tilemaps.py",
            ROOT / "scripts/verify-game-loops.py",
            SHARED / "build.py",
            SHARED / "native.json",
        )
    }


def build(c: dict, assembler: str, variant: str = "positive") -> Path:
    p = folder(c)
    out = p / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    kernel = (SHARED / "6502.inc").read_text()
    if variant == "wrong-stride":
        kernel = (SHARED / "mistakes/wrong-stride-6502.inc").read_text()
    elif variant == "write-without-valid":
        kernel = (SHARED / "mistakes/write-without-valid-6502.inc").read_text()
    elif variant not in ("positive", "closed-exit"):
        raise ValueError(variant)
    (out / "kernel.inc").write_text(kernel)
    source = (
        (p / "demo.asm")
        .read_text()
        .replace(
            "../../../../../cross-platform/patterns/rendering/tile-map/6502.inc",
            str(out / "kernel.inc"),
        )
    )
    properties = p / (
        "customise-properties.inc" if variant == "closed-exit" else "properties.inc"
    )
    source = source.replace(
        '!source "properties.inc"', '!source "' + str(properties) + '"'
    )
    (out / "selected.asm").write_text(source)
    subprocess.run(
        [
            assembler,
            "--dialect",
            "acme",
            str(out / "selected.asm"),
            "-o",
            str(out / "raw.bin"),
        ],
        check=True,
        timeout=45,
        cwd=p,
    )
    raw = (out / "raw.bin").read_bytes()
    T.require(len(raw) == 65536 - c["origin"], "Wrong ROM span or reset vectors")
    if c["system"] == "acorn-atom":
        raw = bytes(8192) + raw
    image = out / "fixture.bin"
    image.write_bytes(raw)
    (out / "basic.rom").write_bytes(bytes(8192))
    (out / "char.rom").write_bytes(bytes(4096))
    (out / "editor.rom").write_bytes(bytes(2048))
    return image


def command(c: dict, image: Path, native: Path) -> list[str]:
    cmd = [str(native / ("emu198x-" + c["system"])), "--mcp"]
    if c["system"] in ("acorn-atom", "oric-atmos"):
        cmd += ["--rom", str(image)]
        if c["system"] == "acorn-atom":
            cmd += ["--model", "acorn-atom-full"]
        return cmd
    out = image.parent
    cmd += [
        "--kernal",
        str(image),
        "--basic",
        str(out / "basic.rom"),
        "--char",
        str(out / "char.rom"),
    ]
    if c["system"] == "commodore-pet":
        return cmd + ["--editor", str(out / "editor.rom"), "--columns", "40"]
    return cmd + ["--region", "pal", "--ram-expansion", "none"]


def verify(c: dict, args: argparse.Namespace) -> None:
    out = folder(c) / "verification"
    out.mkdir(exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    observations = {}
    fixtures = {}
    for variant in ("positive", "closed-exit", "wrong-stride", "write-without-valid"):
        image = build(c, args.assembler, variant)
        m = T.Machine(command(c, image, args.native))
        try:
            m.call("run_frames", frames=30)
            data = m.call("memory_read", addr=c["results"], len=44)["bytes"]
            T.require(
                len(data) == 44 and data[-1] == 239,
                f"{c['system']} {variant}: incomplete caller",
            )
            expected = bytearray(V.expected())
            if variant == "closed-exit":
                expected[40] = 5
            equal = bytes(data) == bytes(expected)
            T.require(
                equal == (variant in ("positive", "closed-exit")),
                f"{c['system']} {variant}: wrong oracle outcome {data}",
            )
            observations[variant] = data
            fixtures[variant] = T.sha(image)
            print("PASS", c["system"], variant, flush=True)
        finally:
            m.close()
    positive = (folder(c) / "build/positive/fixture.bin").read_bytes()
    customised = (folder(c) / "build/closed-exit/fixture.bin").read_bytes()
    differences = sum(a != b for a, b in zip(positive, customised, strict=True))
    T.require(differences == 1, "Customisation changed more than one data byte")
    record = {
        "status": "passed",
        "machine": c["system"],
        "language": "assembly",
        "configuration": c,
        "observations": observations,
        "fixtures": fixtures,
        "customisation": {
            "changed_fixture_bytes": differences,
            "normal_property": 4,
            "closed_exit_property": 5,
            "property_table_bytes": 4,
        },
        "sources": inputs(c),
        "assembler_sha256": T.sha(Path(args.assembler)),
        "emulator_sha256": T.sha(args.native / ("emu198x-" + c["system"])),
        "limits": "Original reset ROM; CPU/RAM evidence only. No stock loader, display, interrupt coexistence or frame deadline claim.",
    }
    (out / "results.json").write_text(json.dumps(record, indent=2) + "\n")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--native", type=Path)
    p.add_argument("--only")
    p.add_argument("--build-only", action="store_true")
    p.add_argument(
        "--variant",
        choices=("positive", "closed-exit", "wrong-stride", "write-without-valid"),
        default="positive",
    )
    args = p.parse_args()
    configs = json.loads(CONFIG.read_text())
    if args.only:
        configs = [c for c in configs if c["system"] == args.only]
        T.require(len(configs) == 1, "Unknown system")
    if not args.build_only:
        if args.native is None:
            p.error("--native is required")
        args.native = args.native.resolve()
        resolved_assembler = which(args.assembler)
        T.require(
            resolved_assembler is not None,
            "Assembler executable not found: " + args.assembler,
        )
        args.assembler = str(Path(resolved_assembler).resolve())
    for c in configs:
        if args.build_only:
            print(build(c, args.assembler, args.variant))
        else:
            verify(c, args)


if __name__ == "__main__":
    main()
