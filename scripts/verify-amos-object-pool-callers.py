"""Observe the small AMOS object-pool owners in the original interpreter."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("pool_native", ROOT / "scripts/verify-amos-object-pool.py")
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)


def expected(name):
    capacity = 4 if name == "custom" else 1 if name == "single" else 8
    acquisitions = [[slot, 1] for slot in range(capacity)] + [[capacity, 0]]
    reuse = [capacity, 0] if name == "wrong" else [0, 1]
    return [capacity] + [value for pair in acquisitions for value in pair] + reuse + [60, 99]


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
    for name in ("small", "working", "custom", "single", "wrong", "repaired"):
        machine = V.T.Machine(V.A.command(args))
        try:
            V.import_case(machine, args, name)
            image = V.V / ("caller-" + name + ".png")
            machine.call("save_screenshot", path=str(image))
            capacity = expected(name)[0]
            positions = [(676, 50)]
            positions += [(x, 66 + slot * 16) for slot in range(capacity + 1) for x in (388, 804)]
            reuse_y = 50 + (capacity + 2) * 16
            positions += [(420, reuse_y), (836, reuse_y), (484, reuse_y + 16), (836, reuse_y + 16)]
            observed = [V.A.number(image, x, y, 3) for x, y in positions]
            V.T.require(observed == expected(name), "Native pool allocation/reuse differs: " + str((name, observed, expected(name))))
            records[name] = {"outputs": observed, "program_sha256": hashlib.sha256(V.B.program(name).encode("ascii")).hexdigest(), "image": image.name, "image_sha256": V.T.sha(image), "server": machine.server["serverInfo"]}
            target.write_text(json.dumps({"cases": records, "sources": {str(p.relative_to(ROOT)): V.T.sha(p) for p in V.source_paths() + [Path(__file__)]}, "fixture": V.identity(args), "configuration": cfg}, indent=2) + "\n")
            print(name, observed, "native owner pixels passed", flush=True)
        finally:
            machine.close()


if __name__ == "__main__":
    main()
