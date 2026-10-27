"""Compile complete pool observations and small owners in original Blitz/Ted."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


M = module("pool_transport", ROOT / "scripts/verify-blitz-map-queries.py")
A, T = M.A, M.T
F = ROOT / "commodore-amiga/patterns/blitz/framework/object-pool"
B = module("pool_full_builder", F / "build.py")
C, D, L = B.C, B.D, B.L
V = F / "verification"


def identity(args: argparse.Namespace) -> dict[str, Any]:
    return {
        "fixture_sha256": T.sha(args.private / "cases.adf"),
        "program_sha256": {
            name: hashlib.sha256(B.program(name).encode("ascii")).hexdigest()
            for name in B.VARIANTS
        },
    }


def source_paths() -> list[Path]:
    return (
        sorted(F.glob("*.bb2"))
        + [
            F / "build.py",
            F / "oracle.py",
            F / "boundary_oracle.py",
            F / "age_oracle.py",
            F / "Makefile",
            Path(__file__),
            ROOT / "scripts/verify-blitz-map-queries.py",
            ROOT / "scripts/verify-blitz-deadline.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/check-amiga-command-loops.py",
        ]
        + [A.PHASES / M.phase_file(name) for name in M.PHASE_NAMES]
    )


def expected(name: str) -> list[int]:
    capacity = 4 if name == "custom" else 1 if name == "single" else 8
    acquisitions = [[slot, 1] for slot in range(capacity)] + [[capacity, 0]]
    reuse = [capacity, 0] if name == "wrong" else [0, 1]
    return (
        [capacity]
        + [value for pair in acquisitions for value in pair]
        + reuse
        + [60, 99]
    )


def positions(name: str) -> list[tuple[int, int]]:
    capacity = expected(name)[0]
    points = [(432, 120)]
    points += [(x, 144 + slot * 24) for slot in range(capacity + 1) for x in (288, 480)]
    reuse_y = 80 + 2 * (32 + (capacity + 1) * 12)
    return points + [
        (304, reuse_y),
        (496, reuse_y),
        (336, reuse_y + 24),
        (496, reuse_y + 24),
    ]


def model(name: str) -> tuple[bytes, int, int]:
    if name in {"cases", "wrong-cases", "repaired-cases"}:
        return C.packet(name == "wrong-cases"), len(C.cases()), C.RECORD_BYTES
    if name in {"boundaries", "extremes"}:
        extreme = name == "extremes"
        return D.packet(extreme), len(D.cases(extreme)), D.RECORD_BYTES
    if name == "age":
        return L.packet(), len(L.cases()), L.RECORD_BYTES
    raise ValueError(name)


def run(args: argparse.Namespace, name: str) -> dict[str, Any]:
    machine = T.Machine(A.command(args))
    try:
        machine.call("load_snapshot", path=str(args.private / "insert-requester.state"))
        text = "Cases:" + name + ".asc\n"
        result = machine.call("type_string", text=text, hold_frames=2)
        T.require(
            result["chars_typed"] == len(text),
            "Incomplete original Ted source selection",
        )

        def frames(count: int) -> None:
            for offset in range(0, count, 200):
                n = min(200, count - offset)
                result = machine.call("run_frames", frames=n)
                T.require(
                    result["frames"] == n and result["stop_reason"] == "ReachedTarget",
                    "Incomplete original compile/run window",
                )

        def key(key_name: str, pressed: bool) -> None:
            machine.call(
                "input", events=[{"Key": {"name": key_name, "pressed": pressed}}]
            )

        frames(500)
        machine.call(
            "input",
            events=[{"PointerMotion": {"device": "mouse-1", "dx": 100, "dy": 0}}],
        )
        frames(3)
        key("ramiga", True)
        frames(4)
        key("x", True)
        frames(4)
        key("x", False)
        frames(4)
        key("ramiga", False)
        frames(300)
        image = V / ("caller-" + name + ".png")
        machine.call("save_screenshot", path=str(image))
        observations: dict[str, Any]
        if name in {"small", "working", "custom", "single", "wrong", "repaired"}:
            outputs = [A.number(image, x, y, 3) for x, y in positions(name)]
            T.require(
                outputs == expected(name),
                "Compiled pool owner outputs differ: " + str((name, outputs)),
            )
            observations = {"outputs": outputs}
        else:
            packet, count, stride = model(name)
            base, size = A.number(image, 288, 200), A.number(image, 288, 240)
            T.require(
                size == len(packet) and 0 < base < 2 * 1024 * 1024 - size,
                "Invalid full diagnostic allocation",
            )
            for _ in range(60):
                tail = machine.call("memory_read", addr=base + size - 8, len=8)["bytes"]
                if bytes(tail) == C.MARKER + C.DONE:
                    break
                frames(200)
            else:
                raise AssertionError("Native pool traversal did not complete")
            raw = bytes(
                value
                for offset in range(0, size, 128)
                for value in machine.call(
                    "memory_read", addr=base + offset, len=min(128, size - offset)
                )["bytes"]
            )
            if raw != packet:
                (V / ("failed-" + name + ".bin")).write_bytes(raw)
                mismatch = next(
                    (
                        i
                        for i, pair in enumerate(zip(raw, packet))
                        if pair[0] != pair[1]
                    ),
                    min(len(raw), len(packet)),
                )
                raise AssertionError(
                    f"Full pool {name} differs at byte{mismatch}, row{mismatch // stride}, offset{mismatch % stride}"
                )
            machine.call("save_screenshot", path=str(image))
            T.require(
                A.number(image, 304, 120, 3) == count
                and A.number(image, 288, 160, 2) == 0,
                "Native pool count or exit differs",
            )
            T.require(
                A.number(image, 288, 200) == base
                and A.number(image, 288, 240) == size
                and A.number(image, 192, 280, 10) == 123456789,
                "Native pool allocation or font differs",
            )
            observations = {
                "case_count": count,
                "record_bytes": stride,
                "bank_address": base,
                "allocated_observer_bytes": size,
                "packet": list(raw),
                "packet_sha256": hashlib.sha256(raw).hexdigest(),
            }
        key("q", True)
        frames(8)
        key("q", False)
        frames(30)
        quit_image = V / ("caller-" + name + "-quit.png")
        machine.call("save_screenshot", path=str(quit_image))
        T.require(
            T.sha(image) != T.sha(quit_image),
            "Native caller did not leave its result screen",
        )
        return observations | {
            "program_sha256": hashlib.sha256(
                B.program(name).encode("ascii")
            ).hexdigest(),
            "image": image.name,
            "image_sha256": T.sha(image),
            "quit_image": quit_image.name,
            "quit_image_sha256": T.sha(quit_image),
            "server": machine.server["serverInfo"],
        }
    finally:
        machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("emulator", "kickstart", "blitz", "blitz-libs", "builder", "private"):
        parser.add_argument("--" + name, required=True, type=Path)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--boot", action="store_true")
    parser.add_argument("--variants", default=",".join(B.VARIANTS))
    args = parser.parse_args()
    names = args.variants.split(",")
    T.require(
        bool(names)
        and len(set(names)) == len(names)
        and all(name in B.VARIANTS for name in names),
        "Invalid or duplicate native variants",
    )
    T.require(
        len(C.cases()) == 768 and len(C.packet()) == 380936 and C.RECORD_BYTES == 496,
        "Empty or incomplete pool model",
    )
    T.require(
        len(D.cases()) == 46
        and len(D.cases(True)) == 6
        and len(D.packet()) == 5344
        and len(D.packet(True)) == 704
        and len(L.packet()) == 464,
        "Incomplete domain or lifetime model",
    )
    cfg = A.config()
    T.require(
        T.sha(args.emulator) == cfg["emulator_sha256"]
        and T.sha(args.kickstart) == cfg["firmware_sha256"]
        and T.sha(args.blitz) == cfg["runtime_media_sha256"]["system"]
        and T.sha(args.blitz_libs) == cfg["runtime_media_sha256"]["libs"]
        and T.sha(args.builder) == cfg["builder_sha256"],
        "Changed original Blitz configuration",
    )
    if args.prepare:
        M.F, M.B = F, B
        M.configure(args)
    T.require(
        json.loads((args.private / "identity.json").read_text()) == identity(args),
        "Changed source-bound fixture",
    )
    if args.boot:
        for name in M.PHASE_NAMES:
            machine = T.Machine(A.command(args))
            try:
                A.phase(machine, args, M.phase_file(name))
            finally:
                machine.close()
            print(name, "original Ted phase complete", flush=True)
    V.mkdir(exist_ok=True)
    target = V / "results.json"
    record = json.loads(target.read_text()) if target.exists() else {"cases": {}}
    sources = {str(path.relative_to(ROOT)): T.sha(path) for path in source_paths()}
    if record["cases"]:
        T.require(
            record["sources"] == sources
            and record["fixture"] == identity(args)
            and record["configuration"] == cfg,
            "Changed qualification inputs; retain old evidence first",
        )
    record.update(
        system="commodore-amiga",
        language="blitz",
        sources=sources,
        fixture=identity(args),
        configuration=cfg,
    )
    for name in names:
        T.require(
            name not in record["cases"], "Do not overwrite a qualified native caller"
        )
        T.require(
            not (V / ("caller-" + name + ".png")).exists()
            and not (V / ("caller-" + name + "-quit.png")).exists(),
            "Retain old captures before fresh qualification",
        )
        record["cases"][name] = run(args, name)
        T.require(
            sources
            == {str(path.relative_to(ROOT)): T.sha(path) for path in source_paths()},
            "Changed source during native execution",
        )
        target.write_text(json.dumps(record, indent=2) + "\n")
        print(name, "original compiled full observations passed", flush=True)


if __name__ == "__main__":
    main()
