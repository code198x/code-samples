"""Observe the small AMOS game-flow owners in the original interpreter."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("flow_native", ROOT / "scripts/verify-amos-game-flow.py")
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)


def expected(name):
    state, score, previous, resets = 0, 0, 0, 0
    health = 5 if name == "custom" else 3
    resumed = finished = 0
    for frame, held in enumerate((0, 3, 3, 0, 0, 3, 3, 0, 3, 0, 4, 0, 8, 8, 0)):
        events = held & ~previous
        previous = held
        if state == 1:
            score = (score + 1) % 256
        following = V.C.NEXT[state][events]
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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("emulator", "kickstart", "amos", "builder", "private"):
        parser.add_argument("--" + name, required=True, type=Path)
    args = parser.parse_args()
    cfg = json.loads((V.A.FOLDER / "verification/configuration.json").read_text())
    for field, path in (("emulator_sha256", args.emulator), ("firmware_sha256", args.kickstart), ("runtime_media_sha256", args.amos), ("builder_sha256", args.builder)):
        V.T.require(V.T.sha(path) == cfg[field], "Changed original runtime configuration")
    V.T.require(json.loads((args.private / "identity.json").read_text()) == V.identity(args), "Changed source fixture")
    target = V.V / "callers.json"
    V.T.require(not target.exists(), "Preserve qualified caller evidence")
    records = {}
    for name in ("small", "working", "custom", "wrong", "repaired"):
        machine = V.T.Machine(V.A.command(args))
        try:
            V.import_case(machine, args, name)
            image = V.V / ("caller-" + name + ".png")
            machine.call("save_screenshot", path=str(image))
            positions = ((484, 66), (452, 82), (420, 98), (420, 114), (452, 130), (516, 146))
            observed = [V.A.number(image, x, y, 3) for x, y in positions]
            V.T.require(observed == expected(name), "Native owner session differs: " + str((name, observed, expected(name))))
            records[name] = {"outputs": observed, "program_sha256": hashlib.sha256(V.B.program(name).encode("ascii")).hexdigest(), "image": image.name, "image_sha256": V.T.sha(image), "server": machine.server["serverInfo"]}
            target.write_text(json.dumps({"cases": records, "sources": {str(p.relative_to(ROOT)): V.T.sha(p) for p in V.source_paths() + [Path(__file__)]}, "fixture": V.identity(args), "configuration": cfg}, indent=2) + "\n")
            print(name, observed, "native owner pixels passed", flush=True)
        finally:
            machine.close()


if __name__ == "__main__":
    main()
