"""Qualify four more 6502 map callers through original reset fixtures.

No restricted firmware is required. These are CPU/RAM tests, not display tests.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/tile-map"
CONFIG = ROOT / "docs/assembly-map-gaps.json"


def load(name: str, path: Path):
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
            SHARED / "6502.inc",
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
        assert kernel.count("adc TM+2") == 1
        kernel = kernel.replace("adc TM+2", "adc #6")
    elif variant == "write-without-valid":
        assert kernel.count("    beq tile_set_done\n") == 1
        kernel = kernel.replace("    beq tile_set_done\n", "")
    elif variant != "positive":
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
    for variant in ("positive", "wrong-stride", "write-without-valid"):
        image = build(c, args.assembler, variant)
        m = T.Machine(command(c, image, args.native))
        try:
            m.call("run_frames", frames=30)
            data = m.call("memory_read", addr=c["results"], len=44)["bytes"]
            T.require(
                len(data) == 44 and data[-1] == 239,
                f"{c['system']} {variant}: incomplete caller",
            )
            equal = bytes(data) == V.expected()
            T.require(
                equal == (variant == "positive"),
                f"{c['system']} {variant}: wrong oracle outcome {data}",
            )
            observations[variant] = data
            fixtures[variant] = T.sha(image)
            print("PASS", c["system"], variant, flush=True)
        finally:
            m.close()
    record = {
        "status": "passed",
        "machine": c["system"],
        "language": "assembly",
        "configuration": c,
        "observations": observations,
        "fixtures": fixtures,
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
    args = p.parse_args()
    configs = json.loads(CONFIG.read_text())
    if args.only:
        configs = [c for c in configs if c["system"] == args.only]
        T.require(len(configs) == 1, "Unknown system")
    if not args.build_only:
        if args.native is None:
            p.error("--native is required")
        args.native = args.native.resolve()
        args.assembler = str(Path(args.assembler).resolve())
    for c in configs:
        if args.build_only:
            print(build(c, args.assembler))
        else:
            verify(c, args)


if __name__ == "__main__":
    main()
