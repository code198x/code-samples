"""Execute glyph transforms in four native emulators, then verify actual drawing."""

from __future__ import annotations

import argparse
import importlib.util
import json
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
S = ROOT / "cross-platform/patterns/rendering/glyph-resize"


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


BASE = load("glyph_base", ROOT / "scripts/verify-scaled-text.py")
V = BASE.V
M = load("glyph_model", S / "model.py")
B = load("glyph_build", S / "build.py")
require = V.require


def sources(c: dict[str, Any]) -> list[Path]:
    folder = ROOT / c["folder"] / "patterns/assembly/rendering/glyph-resize"
    return sorted(
        set(
            BASE.sources(c)
            + list(S.glob("*.py"))
            + list(S.glob("*.json"))
            + [S / (c["cpu"] + ".inc"), S / "mistakes" / (c["cpu"] + "-sampling.inc")]
            + list(folder.glob("*.asm"))
            + list(folder.glob("*.inc"))
            + [folder / "Makefile"]
            + [
                ROOT / "scripts" / n
                for n in [
                    "verify-glyph-resize.py",
                    "check-glyph-resize.py",
                    "test_glyph_resize.py",
                ]
            ]
        )
    )


def input_bytes(
    c: dict[str, Any], src: int, dst: int, width: int, height: int
) -> bytes:
    return (
        src.to_bytes(2, c["order"])
        + dst.to_bytes(2, c["order"])
        + bytes([width, height])
        + bytes([165]) * 26
    )


def draw_request(c: dict[str, Any], syms: dict[str, int]) -> dict[str, Any]:
    return BASE.normal(
        c,
        {
            "kind": "char",
            "xy": [21, 37],
            "bytes": [],
            "code": 65,
            "first": 65,
            "count": 1,
            "fallback": 65,
            "scale": [4, 4],
            "mode": 1,
            "font_ptr": c["data"] + 128,
        },
        syms,
    )


def grid_for(c: dict[str, Any], rows: bytes) -> list[bytearray]:
    grid = [bytearray(c["width"]) for _ in range(c["height"])]
    for y in range(32):
        for x in range(32):
            grid[37 + y][21 + x] = int(bool(rows[y // 4] & (128 >> (x // 4))))
    return grid


def observe_frame(
    machine: Any, c: dict[str, Any], out: Path, name: str, rows: bytes
) -> dict[str, str]:
    grid = grid_for(c, rows)
    packed = V.read(machine, c["base"], c["length"])
    require(packed == BASE.M.P.packed(c, grid), name + ": destination bitmap differs")
    path = out / (name + ".dat.z")
    path.write_bytes(zlib.compress(packed, 9))
    V.capture(machine, c, out, name, grid)
    return {"memory": path.name, "capture": name + ".png"}


def execute(
    c: dict[str, Any], args: argparse.Namespace, variant: str, out: Path
) -> dict[str, Any]:
    _, image = B.build(c["machine_id"], args.assembler, variant)
    syms = V.T.symbols(image.with_name("selected.sym"))
    machine = V.T.Machine(
        [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
    )
    fault = variant == "sampling-fault"
    try:
        machine.call("run_frames", frames=120)
        require(V.read(machine, c["command"], 2) == b"\0\xef", "Startup incomplete")
        font = BASE.M.DEFAULT
        rows = font[304:312]
        width, height = (8, 4) if variant == "customise" else (5, 7)
        expected = M.resize(rows, width, height, crop_fault=fault)
        require(
            V.read(machine, c["data"] + 128, 8) == expected,
            "Startup transformed glyph differs",
        )
        startup = observe_frame(machine, c, out, variant + "-startup", expected)
        startup.update(
            rows=rows.hex(),
            width=width,
            height=height,
            output=expected.hex(),
            mailbox="00ef",
        )
        if variant == "customise":
            return {"startup": startup, "fixture_sha256": V.T.sha(image)}
        cases = (
            M.cases()
            if variant == "positive"
            else [
                {
                    "id": "sampling",
                    "width": 5,
                    "height": 7,
                    "rows": rows.hex(),
                    "overlap": 0,
                }
            ]
        )
        records = []
        for i, case in enumerate(cases):
            source = c["data"] + 64
            dest = source + case["overlap"]
            if case["overlap"] == 0:
                dest = c["data"] + 128  # ordinary separate buffers
            # Explicit exact in-place cases use overlap=8 as a sentinel.
            if case["overlap"] == 8:
                dest = source
            if case.get("invalid_side") == "source":
                source = case["invalid_address"]
            if case.get("invalid_side") == "dest":
                dest = case["invalid_address"]
            ram = bytearray((j * 19 + 71) & 255 for j in range(192))
            if source < 65529:
                ram[source - c["data"] : source - c["data"] + 8] = bytes.fromhex(
                    case["rows"]
                )
            V.write(machine, c["data"], ram)
            request = input_bytes(c, source, dest, case["width"], case["height"])
            # Outside the transform context and the 6502 scratch pointer must survive.
            guards = [(c["l"] - 8, 8), (c["l"] + 32, 8)]
            if c["cpu"] == "6502":
                guards += [(126, 2), (130, 2)]
            for address, n in guards:
                V.write(machine, address, bytes([90]) * n)
            V.write(machine, c["l"], request)
            frames = V.request(machine, c, 4)
            context = V.read(machine, c["l"], 32)
            accepted = (
                1 <= case["width"] <= 8
                and 1 <= case["height"] <= 8
                and source <= 65528
                and dest <= 65528
            )
            require(
                context[:6] == request[:6] and context[6] == int(accepted),
                "Transform status/input differs",
            )
            expected_ram = bytearray(ram)
            result = (
                M.resize(
                    bytes.fromhex(case["rows"]),
                    case["width"],
                    case["height"],
                    crop_fault=fault,
                )
                if accepted
                else None
            )
            if accepted:
                expected_ram[dest - c["data"] : dest - c["data"] + 8] = result
            actual_ram = V.read(machine, c["data"], 192)
            require(
                actual_ram == expected_ram,
                case["id"] + ": glyph/guard/source memory differs",
            )
            require(
                all(V.read(machine, a, n) == bytes([90]) * n for a, n in guards),
                "Scratch neighbour changed",
            )
            rec = {
                "case": case,
                "source": source,
                "dest": dest,
                "before": ram.hex(),
                "after": actual_ram.hex(),
                "context": context.hex(),
                "observed_frames": frames,
                "mailbox": V.read(machine, c["command"], 2).hex(),
                "guards": [V.read(machine, a, n).hex() for a, n in guards],
            }
            if accepted and (i < 8 or (i < 32 and i % 4 == 1) or variant != "positive"):
                V.request(machine, c, 3)
                V.write(machine, c["data"] + 128, result)
                r = draw_request(c, syms)
                V.write(machine, c["t"], BASE.inputs(c, r))
                V.request(machine, c, 1)
                require(V.read(machine, c["t"] + 17, 1) == b"\1", "Draw rejected")
                rec.update(
                    observe_frame(machine, c, out, variant + "-" + case["id"], result)
                )
                if fault:
                    correct = M.resize(
                        bytes.fromhex(case["rows"]), case["width"], case["height"]
                    )
                    require(correct != result, "Fault is invisible")
                    rec["correct_output"] = correct.hex()
            records.append(rec)
            if i % 128 == 0:
                print(c["machine_id"], variant, i + 1, "checked", flush=True)
        return {
            "startup": startup,
            "cases": records,
            "fixture_sha256": V.T.sha(image),
            "costs": {
                "component_bytes": syms["glyph_resize_end"] - syms["glyph_resize"],
                "context_bytes": 32,
                "pointer_bytes": 2 if c["cpu"] == "6502" else 0,
                "output_bytes": 8,
                "input_reads": 8,
                "clear_writes": 8,
                "set_pixels": sum(row.bit_count() for row in expected),
                "sampled_pixels": width * height,
            },
        }
    finally:
        machine.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--only")
    args = p.parse_args()
    configs = json.loads((S / "systems.json").read_text())
    selected = [c for c in configs if not args.only or c["machine_id"] == args.only]
    require(bool(selected), "No selected system")
    tools = {t["tool"]: t for t in json.loads((S / "toolchain.json").read_text())}
    for c in selected:
        for name, path in [
            (c["binary"], args.native / c["binary"]),
            ("asm198x", Path(args.assembler)),
        ]:
            require(
                V.T.sha(path) == tools[name]["binary_sha256"],
                "Unqualified tool " + name,
            )
        out = (
            ROOT
            / c["folder"]
            / "patterns/assembly/rendering/glyph-resize/build/verification"
        )
        out.mkdir(exist_ok=True, parents=True)
        result = {
            "machine_id": c["machine_id"],
            "variants": {v: execute(c, args, v, out) for v in B.VARIANTS},
        }
        require(
            result["variants"]["sampling-fixed"]["fixture_sha256"]
            == result["variants"]["positive"]["fixture_sha256"],
            "Repair differs",
        )
        result["sources"] = {str(f.relative_to(ROOT)): V.T.sha(f) for f in sources(c)}
        result["tools"] = {
            n: tools[n]["binary_sha256"] for n in [c["binary"], "asm198x"]
        }
        result["artifacts"] = {
            f.name: V.T.sha(f) for f in out.iterdir() if f.suffix in [".png", ".z"]
        }
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        print(
            c["machine_id"],
            "PASS",
            len(result["variants"]["positive"]["cases"]) + 6,
            "observations",
            flush=True,
        )


if __name__ == "__main__":
    main()
