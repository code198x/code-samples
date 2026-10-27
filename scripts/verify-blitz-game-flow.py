"""Compile game-flow owners and full-state observations in original Blitz BASIC2.10/Ted1.1."""

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


M = module("flow_transport", ROOT / "scripts/verify-blitz-map-queries.py")
A, T = M.A, M.T
F = ROOT / "commodore-amiga/patterns/blitz/framework/game-flow"
B = module("flow_builder", F / "build.py")
C = module("flow_oracle", F / "oracle.py")
V = F / "verification"


def identity(args: argparse.Namespace) -> dict[str, Any]:
    return {"fixture_sha256": T.sha(args.private / "cases.adf"),
            "program_sha256": {name: hashlib.sha256(B.program(name).encode("ascii")).hexdigest() for name in B.VARIANTS}}


def source_paths() -> list[Path]:
    return sorted(F.glob("*.bb2")) + [F / "oracle.py", F / "build.py", F / "Makefile", Path(__file__),
            ROOT / "scripts/verify-blitz-map-queries.py", ROOT / "scripts/verify-blitz-deadline.py",
            ROOT / "scripts/verify-game-loops.py", ROOT / "scripts/check-amiga-command-loops.py"] + [A.PHASES / M.phase_file(name) for name in M.PHASE_NAMES]


def expected(name: str) -> list[int]:
    state, score, previous, resets, resumed, finished = 0, 0, 0, 0, 0, 0
    health = 5 if name == "custom" else 3
    for frame, held in enumerate((0, 3, 3, 0, 0, 3, 3, 0, 3, 0, 4, 0, 8, 8, 0)):
        events = held & ~previous
        previous = held
        if state == 1:
            score = (score + 1) % 256
        following = C.NEXT[state][events]
        fresh = following == 1 and state in (0, 2)
        reset = fresh or (name == "wrong" and following == 1 and state != following)
        state = following
        if reset:
            score, resets = 0, resets + 1
        if frame == 8:
            resumed = score
        if frame == 10:
            finished = score
    return [resumed, resets, state, score, health, finished]


def positions() -> list[tuple[int, int]]:
    return [(336, 120), (320, 160), (304, 200), (304, 240), (320, 280), (352, 320)]


def run(args: argparse.Namespace, name: str) -> dict[str, Any]:
    machine = T.Machine(A.command(args))
    try:
        machine.call("load_snapshot", path=str(args.private / "insert-requester.state"))
        text = "Cases:" + name + ".asc\n"
        result = machine.call("type_string", text=text, hold_frames=2)
        T.require(result["chars_typed"] == len(text), "Incomplete original Ted source selection")

        def frames(count: int) -> None:
            for offset in range(0, count, 200):
                n = min(200, count - offset)
                result = machine.call("run_frames", frames=n)
                T.require(result["frames"] == n and result["stop_reason"] == "ReachedTarget", "Incomplete original compile/run window")

        def key(key_name: str, pressed: bool) -> None:
            machine.call("input", events=[{"Key": {"name": key_name, "pressed": pressed}}])

        frames(500)
        machine.call("input", events=[{"PointerMotion": {"device": "mouse-1", "dx": 100, "dy": 0}}])
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
        if name.startswith("cases-"):
            base = A.number(image, 288, 200)
            size = A.number(image, 288, 240)
            chunk = int(name.split("-")[1])
            rows = C.chunks()[chunk]
            packet = C.packet(chunk)
            T.require(size == len(packet) and 0 < base < 2 * 1024 * 1024 - size, "Invalid native game-flow observer allocation")
            for _ in range(30):
                tail = machine.call("memory_read", addr=base + size - 8, len=8)["bytes"]
                if bytes(tail) == C.MARKER + C.DONE:
                    break
                frames(200)
            else:
                raise AssertionError("Native game-flow record traversal did not complete")
            raw = bytes(value for offset in range(0, size, 128)
                        for value in machine.call("memory_read", addr=base + offset, len=min(128, size - offset))["bytes"])
            T.require(len(raw) == len(packet), "Truncated native game-flow observations")
            if raw != packet:
                offset = next(i for i, pair in enumerate(zip(raw, packet, strict=True)) if pair[0] != pair[1])
                raise AssertionError(f"Native game-flow record differs at byte{offset}, case{offset // C.RECORD_BYTES}: {raw[offset]} vs {packet[offset]}")
            machine.call("save_screenshot", path=str(image))
            T.require(A.number(image, 304, 120, 3) == len(rows) and A.number(image, 336, 160, 2) == int.from_bytes(C.record(*rows[-1])[16:20], "big", signed=True), "Native game-flow count/status pixels differ")
            T.require(A.number(image, 288, 200) == base and A.number(image, 288, 240) == size, "Native allocation pixels differ")
            T.require(A.number(image, 192, 280, 10) == 123456789, "Original runtime font differs")
            observations = {"case_count": len(rows), "total_case_count": len(C.cases()), "chunk_index": chunk, "start_case": chunk * 64, "record_bytes": C.RECORD_BYTES, "bank_address": base,
                            "allocated_observer_bytes": size, "packet": list(raw), "packet_sha256": hashlib.sha256(raw).hexdigest()}
        else:
            outputs = [A.number(image, x, y, 3) for x, y in positions()]
            T.require(outputs == expected(name), "Compiled game-flow owner differs: " + str((name, outputs)))
            observations = {"outputs": outputs}
        key("q", True)
        frames(8)
        key("q", False)
        frames(30)
        quit_image = V / ("caller-" + name + "-quit.png")
        machine.call("save_screenshot", path=str(quit_image))
        T.require(T.sha(image) != T.sha(quit_image), "Native caller did not leave its result screen")
        return observations | {"program_sha256": hashlib.sha256(B.program(name).encode("ascii")).hexdigest(),
                "image": image.name, "image_sha256": T.sha(image), "quit_image": quit_image.name,
                "quit_image_sha256": T.sha(quit_image), "server": machine.server["serverInfo"]}
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
    T.require(len(C.cases()) == 366 and C.RECORD_BYTES == 48 and len(C.packet()) == 17576, "Empty or incomplete independent game-flow cases")
    T.require([len(rows) for rows in C.chunks()] == [64, 64, 64, 64, 64, 46], "Missing or empty diagnostic chunks")
    T.require(bool(names) and len(set(names)) == len(names) and all(name in B.VARIANTS for name in names), "Invalid or duplicate native variants")
    cfg = A.config()
    T.require(T.sha(args.emulator) == cfg["emulator_sha256"] and T.sha(args.kickstart) == cfg["firmware_sha256"] and T.sha(args.blitz) == cfg["runtime_media_sha256"]["system"] and T.sha(args.blitz_libs) == cfg["runtime_media_sha256"]["libs"] and T.sha(args.builder) == cfg["builder_sha256"], "Changed original Blitz configuration")
    if args.prepare:
        M.F, M.B = F, B
        M.configure(args)
    T.require(json.loads((args.private / "identity.json").read_text()) == identity(args), "Changed source-bound fixture")
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
        T.require(record["sources"] == sources and record["fixture"] == identity(args) and record["configuration"] == cfg, "Changed qualification inputs; retain old evidence first")
    record.update(system="commodore-amiga", language="blitz", sources=sources, fixture=identity(args), configuration=cfg)
    for name in names:
        T.require(name not in record["cases"], "Do not overwrite a qualified native caller")
        record["cases"][name] = run(args, name)
        T.require(sources == {str(path.relative_to(ROOT)): T.sha(path) for path in source_paths()}, "Changed source during native execution")
        target.write_text(json.dumps(record, indent=2) + "\n")
        print(name, "original compiled observations passed", flush=True)
    chunk_names = ["cases-" + str(index) for index in range(6)]
    if all(name in record["cases"] for name in chunk_names):
        chunks = [record["cases"][name] for name in chunk_names]
        T.require([chunk["chunk_index"] for chunk in chunks] == list(range(6)), "Duplicate or swapped native chunks")
        T.require([chunk["case_count"] for chunk in chunks] == [64, 64, 64, 64, 64, 46], "Missing native rows")
        joined = b"".join(bytes(chunk["packet"][:-8]) for chunk in chunks) + C.MARKER + C.DONE
        T.require(joined == C.packet(), "Joined native observations differ from complete model")
        print(len(C.cases()), "full native records covered across all six original compiler chunks", flush=True)


if __name__ == "__main__":
    main()
