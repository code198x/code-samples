"""Run source-bound map queries inside original AMOS Professional 2.00."""

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


A = module("runtime", ROOT / "scripts/verify-amos-deadline.py")
T = A.T
F = ROOT / "commodore-amiga/patterns/amos/rendering/tile-map"
B = module("builder", F / "build.py")
V = F / "verification"


def source_paths():
    return (
        [F / n for n in ("routines.amos", "caller.amos", "build.py", "Makefile")]
        + [
            ROOT / "cross-platform/patterns/rendering/tile-map/managed-cases.py",
            Path(__file__),
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-amos-deadline.py",
            ROOT / "scripts/check-amiga-command-loops.py",
        ]
        + [
            A.PHASES / n
            for n in (
                "amos-cases-cold.json",
                "amos-cases-blank.json",
                "working-case.json",
            )
        ]
    )


def configure(args):
    args.private.mkdir(exist_ok=True, parents=True)
    subprocess.run(["python3", str(F / "build.py")], check=True, timeout=30)
    target = args.private / "cases.adf"
    T.require(not target.exists(), "Refusing to overwrite fixture")
    command = [str(args.builder), "create", str(target), "--label", "Cases"]
    for n in B.VARIANTS:
        command += ["--add", str(F / "build" / (n + ".asc")) + "=" + n + ".asc"]
    subprocess.run(command, check=True, timeout=60)
    subprocess.run([str(args.builder), "verify", str(target)], check=True, timeout=60)
    # Source fixture and original runtime remain private; only own code/evidence is public.
    identity = {
        "fixture_sha256": T.sha(target),
        "program_sha256": {
            n: hashlib.sha256(B.program(n).encode()).hexdigest() for n in B.VARIANTS
        },
    }
    (args.private / "identity.json").write_text(json.dumps(identity, indent=2) + "\n")
    return identity


def import_case(m, args, name):
    steps = json.loads((A.PHASES / "working-case.json").read_text())
    for original in steps:
        text = (
            json.dumps(original)
            .replace("${RUN}", str(args.private))
            .replace("${AMOS}", str(args.amos))
            .replace("working", name)
        )
        fields = json.loads(text)
        action = fields.pop("action")
        # Original requester/import work can outlast its old 100-frame settle.
        if action == "run_frames" and fields["frames"] == 100:
            fields["frames"] = 300
        result = m.call(action, **fields)
        if action == "run_frames":
            T.require(
                result["frames"] == fields["frames"]
                and result["stop_reason"] == "ReachedTarget",
                "Incomplete import window",
            )
        if action == "type_string":
            T.require(
                result["chars_typed"] == len(fields["text"]),
                "Incomplete source selection",
            )
        if action == "save_screenshot":
            break


def run(args, name):
    m = T.Machine(A.command(args))
    try:
        import_case(m, args, name)
        m.call("run_frames", frames=20)
        image = V / (name + ".png")
        m.call("save_screenshot", path=str(image))
        if name == "small":
            actual = [
                A.number(image, 388, 50, 2),
                A.number(image, 420, 66, 2),
                A.number(image, 644, 82, 2),
            ]
            T.require(actual == [1, 1, 2], "Small caller output differs")
            return {
                "outputs": actual,
                "image": image.name,
                "image_sha256": T.sha(image),
                "program_sha256": hashlib.sha256(B.program(name).encode()).hexdigest(),
                "server": m.server["serverInfo"],
            }
        base = A.number(image, 388, 98)
        count = A.number(image, 388, 66, 3)
        size = A.number(image, 388, 114, 5)
        T.require(
            count == len(B.C.cases())
            and size == count * 48 + 2
            and 0 < base < 2 * 1024 * 1024 - size,
            "No completed map caller/allocation",
        )
        raw = [
            b
            for i in range(0, size, 128)
            for b in m.call("memory_read", addr=base + i, len=min(128, size - i))[
                "bytes"
            ]
        ]
        T.require(raw[-2:] == [202, 254], "Missing final completion marker")
        values = []
        for i in range(count):
            row = raw[i * 48 : (i + 1) * 48]
            T.require(row[46:48] == [165, 90], "Incomplete native map operation")
            fields = [
                int.from_bytes(bytes(row[j : j + 2]), "big", signed=j in (2, 6, 8))
                for j in range(0, 10, 2)
            ]
            values.append(fields + row[10:46])
        expected = B.C.expected(name == "custom")
        T.require(
            (values == expected) == (name != "wrong"), "Independent map oracle differs"
        )
        exit_property = A.number(image, 388, 82, 2)
        T.require(
            exit_property == (1 if name == "custom" else 2),
            "Custom property not visible",
        )
        m.call("input", events=[{"Key": {"name": "q", "pressed": True}}])
        m.call("run_frames", frames=8)
        m.call("input", events=[{"Key": {"name": "q", "pressed": False}}])
        m.call("run_frames", frames=30)
        quit_image = V / (name + "-quit.png")
        m.call("save_screenshot", path=str(quit_image))
        return {
            "base": base,
            "allocation_bytes": size,
            "count": count,
            "bytes": raw,
            "values": values,
            "exit_property": exit_property,
            "image": image.name,
            "image_sha256": T.sha(image),
            "quit_image": quit_image.name,
            "quit_image_sha256": T.sha(quit_image),
            "program_sha256": hashlib.sha256(B.program(name).encode()).hexdigest(),
            "server": m.server["serverInfo"],
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ("emulator", "kickstart", "amos", "builder", "private"):
        p.add_argument("--" + name, type=Path, required=True)
    p.add_argument("--prepare", action="store_true")
    p.add_argument("--boot", action="store_true")
    p.add_argument("--variants", default=",".join(B.VARIANTS))
    args = p.parse_args()
    V.mkdir(exist_ok=True)
    baseline = json.loads((A.FOLDER / "verification/configuration.json").read_text())
    T.require(
        T.sha(args.amos) == baseline["runtime_media_sha256"]
        and T.sha(args.kickstart) == baseline["firmware_sha256"]
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
        for n in ("amos-cases-cold.json", "amos-cases-blank.json"):
            m = T.Machine(A.command(args))
            try:
                A.phase(m, args, n)
            finally:
                m.close()
            print(n, "complete", flush=True)
    cfg = {
        "model": "A1200 PAL, 2 MiB chip, no fast RAM, original AMOS Professional 2.00",
        "emulator_sha256": T.sha(args.emulator),
        "kickstart_sha256": T.sha(args.kickstart),
        "runtime_sha256": T.sha(args.amos),
        "builder_sha256": T.sha(args.builder),
    }
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "commodore-amiga", "language": "amos", "cases": {}}
    )
    r.update(
        configuration=cfg,
        fixture=identity,
        sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
    )
    for n in args.variants.split(","):
        T.require(n in B.VARIANTS, "Unknown case")
        r["cases"][n] = run(args, n)
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(n, "passed", flush=True)


if __name__ == "__main__":
    main()
