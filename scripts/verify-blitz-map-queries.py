"""Compile and execute checked maps in original Blitz BASIC 2.10/Ted."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    v = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(v)
    return v


A = module("runtime", ROOT / "scripts/verify-blitz-deadline.py")
T = A.T
F = ROOT / "commodore-amiga/patterns/blitz/rendering/tile-map"
B = module("builder", F / "build.py")
V = F / "verification"
PHASE_NAMES = (
    "boot",
    "drawer",
    "pointer",
    "open",
    "ide",
    "ide-later",
    "blank",
    "edit",
    "empty",
    "settled",
    "insert-requester",
)


def phase_file(n):
    return n + ".json" if n == "insert-requester" else "blitz-" + n + ".json"


def source_paths():
    return (
        [F / n for n in ("routines.bb2", "caller.bb2", "build.py", "Makefile")]
        + [
            ROOT / "cross-platform/patterns/rendering/tile-map/managed-cases.py",
            Path(__file__),
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-blitz-deadline.py",
            ROOT / "scripts/check-amiga-command-loops.py",
        ]
        + [A.PHASES / phase_file(n) for n in PHASE_NAMES]
    )


def configure(args):
    args.private.mkdir(exist_ok=True, parents=True)
    subprocess.run(["python3", str(F / "build.py")], check=True, timeout=30)
    target = args.private / "cases.adf"
    T.require(not target.exists(), "Refusing to replace fixture")
    command = [str(args.builder), "create", str(target), "--label", "Cases"]
    for n in B.VARIANTS:
        command += ["--add", str(F / "build" / (n + ".asc")) + "=" + n + ".asc"]
    subprocess.run(command, check=True, timeout=60)
    subprocess.run([str(args.builder), "verify", str(target)], check=True, timeout=60)
    identity = {
        "fixture_sha256": T.sha(target),
        "program_sha256": {
            n: hashlib.sha256(B.program(n).encode()).hexdigest() for n in B.VARIANTS
        },
    }
    (args.private / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
    return identity


def run(args, name):
    m = T.Machine(A.command(args))
    try:
        m.call("load_snapshot", path=str(args.private / "insert-requester.state"))
        text = "Cases:" + name + ".asc\n"
        r = m.call("type_string", text=text, hold_frames=2)
        T.require(r["chars_typed"] == len(text), "Incomplete source selection")

        def frames(n):
            for offset in range(0, n, 200):
                count = min(200, n - offset)
                r = m.call("run_frames", frames=count)
                T.require(
                    r["frames"] == count and r["stop_reason"] == "ReachedTarget",
                    "Incomplete import/compile window",
                )

        def key(n, down):
            m.call("input", events=[{"Key": {"name": n, "pressed": down}}])

        frames(500)
        m.call(
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
        image = V / (name + ".png")
        m.call("save_screenshot", path=str(image))
        common = {
            "program_sha256": hashlib.sha256(B.program(name).encode()).hexdigest(),
            "server": m.server["serverInfo"],
            "image": image.name,
            "image_sha256": T.sha(image),
        }
        if name == "small":
            outputs = [
                A.number(image, 288, 120, 2),
                A.number(image, 304, 160, 2),
                A.number(image, 416, 200, 2),
            ]
            T.require(outputs == [1, 1, 2], "Small compiled caller differs")
            return common | {"outputs": outputs}
        base = A.number(image, 288, 200)
        size = A.number(image, 288, 240)
        count = A.number(image, 304, 120, 3)
        T.require(
            count == 64
            and size == count * 168 + 8
            and 0 < base < 2 * 1024 * 1024 - size,
            "No completed map bank/allocation",
        )
        raw = [
            b
            for offset in range(0, size, 128)
            for b in m.call(
                "memory_read", addr=base + offset, len=min(128, size - offset)
            )["bytes"]
        ]
        T.require(raw[-8:] == [26, 43, 60, 77, 0, 0, 0, 239], "Missing final guards")
        values = []
        for i in range(count):
            row = raw[i * 168 : (i + 1) * 168]
            T.require(row[164:168] == [0, 0, 165, 90], "Incomplete map operation")
            values.append(
                [
                    int.from_bytes(bytes(row[j : j + 4]), "big", signed=True)
                    for j in range(0, 164, 4)
                ]
            )
        T.require(
            (values == B.C.expected(name == "custom")) == (name != "wrong"),
            "Native map oracle differs",
        )
        prop = A.number(image, 288, 160, 2)
        T.require(prop == (1 if name == "custom" else 2), "Custom property not visible")
        T.require(
            A.number(image, 192, 280, 10) == 123456789,
            "Unexpected original runtime font",
        )
        key("q", True)
        frames(8)
        key("q", False)
        frames(30)
        quit_image = V / (name + "-quit.png")
        m.call("save_screenshot", path=str(quit_image))
        return common | {
            "base": base,
            "allocation_bytes": size,
            "count": count,
            "bytes": raw,
            "values": values,
            "exit_property": prop,
            "quit_image": quit_image.name,
            "quit_image_sha256": T.sha(quit_image),
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for n in ("emulator", "kickstart", "blitz", "blitz-libs", "builder", "private"):
        p.add_argument("--" + n, type=Path, required=True)
    p.add_argument("--prepare", action="store_true")
    p.add_argument("--boot", action="store_true")
    p.add_argument("--variants", default=",".join(B.VARIANTS))
    args = p.parse_args()
    V.mkdir(exist_ok=True)
    baseline = A.config()
    T.require(
        T.sha(args.kickstart) == baseline["firmware_sha256"]
        and T.sha(args.blitz) == baseline["runtime_media_sha256"]["system"]
        and T.sha(args.blitz_libs) == baseline["runtime_media_sha256"]["libs"]
        and T.sha(args.builder) == baseline["builder_sha256"],
        "Different original runtime/firmware/builder",
    )
    identity = (
        configure(args)
        if args.prepare
        else json.loads((args.private / "identity.json").read_text())
    )
    T.require(
        identity
        == {
            "fixture_sha256": T.sha(args.private / "cases.adf"),
            "program_sha256": {
                n: hashlib.sha256(B.program(n).encode()).hexdigest() for n in B.VARIANTS
            },
        },
        "Stale source fixture",
    )
    if args.boot:
        for n in PHASE_NAMES:
            m = T.Machine(A.command(args))
            try:
                A.phase(m, args, phase_file(n))
            finally:
                m.close()
            print(n, "phase complete", flush=True)
    cfg = {
        "model": "A1200 PAL, 2 MiB chip/no fast RAM, original Blitz BASIC 2.10 / Ted 1.1, three drives",
        "emulator_sha256": T.sha(args.emulator),
        "kickstart_sha256": T.sha(args.kickstart),
        "runtime_sha256": {"system": T.sha(args.blitz), "libs": T.sha(args.blitz_libs)},
        "builder_sha256": T.sha(args.builder),
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "commodore-amiga", "language": "blitz", "cases": {}}
    )
    r.update(
        configuration=cfg,
        fixture=identity,
        sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
    )
    for name in args.variants.split(","):
        T.require(name in B.VARIANTS, "Unknown case")
        r["cases"][name] = run(args, name)
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(name, "passed", flush=True)


if __name__ == "__main__":
    main()
