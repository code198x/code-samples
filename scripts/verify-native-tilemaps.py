"""Execute byte-map routines on twenty machine-specific CPU/RAM configurations.

The fixtures are original synthetic reset ROMs/cartridges. They qualify these
routines and mapped memory, not stock firmware loading, video or frame budgets.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/tile-map"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = load("transport", ROOT / "scripts/verify-game-loops.py")
B = load("builder", SHARED / "build.py")
OBSERVER_SHA = T.sha(Path(__file__))
TRANSPORT_SHA = T.sha(ROOT / "scripts/verify-game-loops.py")
BINARIES = {
    "acorn-bbc-micro": "acorn-bbc-micro",
    "commodore-c64": "c64",
    "commodore-amiga": "amiga",
    "nintendo-nes": "nes",
    "sinclair-zx-spectrum": "spectrum",
    "nintendo-game-boy": "game-boy",
    "coleco-colecovision": "colecovision",
}


def command(cfg: dict, image: Path, native: Path) -> list[str]:
    system = cfg["machine_id"]
    kind = cfg["kind"]
    out = image.parent
    name = BINARIES.get(system, system)
    result = [str(native / f"emu198x-{name}"), "--mcp"]
    if kind == "kernal":
        result += [
            "--kernal",
            str(image),
            "--basic",
            str(out / "basic.rom"),
            "--chargen",
            str(out / "chargen.rom"),
        ]
    elif kind == "electron":
        result += ["--os", str(image), "--basic", str(out / "basic.rom")]
    elif kind == "5200":
        result += ["--cart", str(image), "--bios", str(out / "bios.rom")]
    elif kind == "cart":
        result += ["--cart", str(image)]
    elif kind in ("nes", "gb"):
        result += ["--rom", str(image)]
    elif kind in ("sms", "gg", "sg"):
        result += ["--cart", str(image)]
    elif kind == "kickstart":
        result += ["--kickstart", str(image), "--model", "a500"]
    elif kind == "bios":
        result += ["--bios", str(image)]
    elif kind == "mos":
        result += ["--mos", str(image)]
    else:
        result += ["--rom", str(image)]
    if system in ("sinclair-zx80", "sinclair-zx81"):
        result += ["--ram-bytes", "1024"]
    return result


def expected() -> bytes:
    # Explicit row-major world, independent of the guest's address arithmetic.
    rows = [
        bytes([0, 1, 2, 3, 0, 1, 2]),
        bytes([3, 0, 1, 2, 3, 0, 1]),
        bytes([2, 3, 0, 1, 2, 3, 0]),
        bytes([1, 2, 3, 0, 1, 2, 3]),
        bytes([0, 1, 2, 3, 0, 1, 2]),
    ]
    return b"".join(rows) + bytes([0, 0, 1, 1, 3, 4, 1, 0, 239])


def verify(system: str, args: argparse.Namespace) -> dict:
    cfg, image = B.build(system, args.assembler)
    folder = image.parent.parent
    output = folder / "build/verification"
    output.mkdir(exist_ok=True)
    (output / "results.json").unlink(missing_ok=True)
    original = (folder / "demo.asm").read_text()

    def execute(label: str) -> bytes:
        cfg, image = B.build(system, args.assembler)
        machine = T.Machine(command(cfg, image, args.native.resolve()))
        try:
            # Bounded native execution; output is RAM, not a video-frame claim.
            machine.call("run_frames", frames=30)
            raw = bytes(
                machine.call("memory_read", addr=cfg["results"], len=44)["bytes"]
            )
            T.require(
                raw[-1] == 239,
                f"{system}: {label} did not reach completion: {raw.hex()}",
            )
            (output / f"{label}.json").write_text(
                json.dumps({"bytes": list(raw)}, indent=2) + "\n"
            )
            return raw
        finally:
            machine.close()

    actual = execute("positive")
    T.require(
        actual == expected(),
        f"{system}: query/write/property/conversion results differ: {list(actual)}",
    )
    # Change the declared width only for address calculation, leaving bounds
    # and test data unchanged. This must reach completion and fail the oracle.
    code = SHARED / f"{cfg['cpu']}.inc"
    base = code.read_text()
    if cfg["cpu"] == "6502":
        mutated = base.replace("adc TM+2", "adc #6")
    elif cfg["cpu"] in ("z80", "sm83"):
        mutated = base.replace("ld a,(TM+2)\n    ld e,a", "ld a,6\n    ld e,a").replace(
            "ld a,[TM+2]\n    ld e,a", "ld a,6\n    ld e,a"
        )
    else:
        mutated = base.replace("move.b 4(a0),d2", "move.b #6,d2")
    if cfg["cpu"] == "6502":
        bad_write = base.replace("    beq tile_set_done\n", "")
    elif cfg["cpu"] in ("z80", "sm83"):
        bad_write = base.replace("    or a\n    ret z\n", "    or a\n")
    else:
        bad_write = base.replace("    beq tile_set_done\n", "")
    controls = {"wrong-stride": mutated, "write-without-valid": bad_write}
    local = folder / "negative.inc"
    altered = original.replace(
        f"../../../../../cross-platform/patterns/rendering/tile-map/{cfg['cpu']}.inc",
        "negative.inc",
    )
    T.require(altered != original, "Caller did not include negative routine")
    try:
        for label, replacement in controls.items():
            T.require(replacement != base, f"{label}: mutation was not applied")
            local.write_text(replacement)
            (folder / "demo.asm").write_text(altered)
            wrong = execute(label)
            T.require(wrong != expected(), f"{system}: {label} passed the oracle")
    finally:
        (folder / "demo.asm").write_text(original)
        B.build(system, args.assembler)
        local.unlink(missing_ok=True)
    record = {
        "status": "passed",
        "machine_id": system,
        "cpu": cfg["cpu"],
        "configuration": "Original synthetic reset ROM/cartridge; no stock OS services; native CPU/RAM execution",
        "expected": list(expected()),
        "actual": list(actual),
        "wrong_stride_rejected": True,
        "write_without_valid_rejected": True,
        "case_groups": {
            "reads": 35,
            "outside_reads": 4,
            "rejected_writes": 5,
            "invalid_property": 1,
            "valid_write": 1,
            "valid_property": 1,
            "conversion": 2,
        },
        "completed_negative_control": True,
        "sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [
                folder / "demo.asm",
                code,
                SHARED / "build.py",
                SHARED / "native.json",
            ]
        },
        "observer_sha256": OBSERVER_SHA,
        "transport_sha256": TRANSPORT_SHA,
        "assembler_sha256": T.sha(Path(args.assembler)),
        "emulator_sha256": T.sha(
            args.native.resolve() / f"emu198x-{BINARIES.get(system, system)}"
        ),
        "fixture_sha256": T.sha(image),
        "limits": "CPU/routine and declared-memory evidence. Does not establish stock firmware/loader compatibility, display output, interrupt coexistence, frame timing or original hardware.",
    }
    (output / "results.json").write_text(json.dumps(record, indent=2) + "\n")
    print("PASS", system, flush=True)
    return record


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--only")
    args = p.parse_args()
    systems = [
        c["machine_id"] for c in json.loads((SHARED / "native.json").read_text())
    ]
    if args.only:
        T.require(args.only in systems, "Unknown system")
        systems = [args.only]
    for system in systems:
        verify(system, args)


if __name__ == "__main__":
    main()
