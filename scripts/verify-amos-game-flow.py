"""Execute source-bound AMOS game-flow packets in the original runtime."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
F = ROOT / "commodore-amiga/patterns/amos/framework/game-flow"
def module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value
M = module("amos_flow_transport", ROOT / "scripts/verify-amos-map-queries.py")
A = M.A
T = A.T
B = module("amos_flow_builder", F / "build.py")
C = module("amos_flow_oracle", F / "oracle.py")
V = F / "verification"
def identity(args):
    return {"fixture_sha256": T.sha(args.private / "cases.adf"),
            "programs": {n: hashlib.sha256(B.program(n).encode("ascii")).hexdigest() for n in B.VARIANTS}}
def prepare(args):
    args.private.mkdir(exist_ok=True, parents=True)
    assert not (args.private / "cases.adf").exists(), "Use a fresh private fixture"
    subprocess.run(["make", "-C", str(F)], check=True, timeout=30)
    command = [str(args.builder), "create", str(args.private / "cases.adf"), "--label", "Cases"]
    for n in B.VARIANTS:
        command += ["--add", str(F / "build" / (n + ".asc")) + "=" + n + ".asc"]
    subprocess.run(command, check=True, timeout=60)
    subprocess.run([str(args.builder), "verify", str(args.private / "cases.adf")], check=True, timeout=60)
    (args.private / "identity.json").write_text(json.dumps(identity(args), indent=2) + "\n")
def import_case(machine, args, name):
    checked = False
    for original in json.loads((A.PHASES / "working-case.json").read_text()):
        step = json.loads(json.dumps(original).replace("${RUN}", str(args.private)).replace("${AMOS}", str(args.amos)).replace("working", name))
        action = step.pop("action")
        if action == "input" and any(e.get("Key", {}).get("name") == "f2" and not e["Key"]["pressed"] for e in step["events"]):
            checked = True
        if action == "run_frames" and step["frames"] == 100:
            # The large DATA source needs the original checker to finish before F1.
            step["frames"] = 1200 if checked else 300
            checked = False
        if action == "run_frames":
            for off in range(0, step["frames"], 200):
                count = min(200, step["frames"] - off)
                result = machine.call(action, frames=count)
                T.require(result["frames"] == count and result["stop_reason"] == "ReachedTarget", "Incomplete import/check window")
            continue
        result = machine.call(action, **step)
        if action == "type_string":
            T.require(result["chars_typed"] == len(step["text"]), "Incomplete native source selection")
        if action == "run_frames":
            T.require(result["frames"] == step["frames"] and result["stop_reason"] == "ReachedTarget", "Incomplete import/check window")
        if action == "save_screenshot":
            break

def run(args, name):
    T.require(name in ("cases",), "Packet variant required")
    machine = T.Machine(A.command(args))
    try:
        import_case(machine, args, name)
        image = V / (name + ".png")
        machine.call("save_screenshot", path=str(image))
        base = A.number(image, 388, 98)
        expected = C.packet()
        T.require(0 < base < 2 * 1024 * 1024 - len(expected), "Invalid native observer address")
        for _ in range(30):
            tail = machine.call("memory_read", addr=base + len(expected) - len(C.MARKER), len=len(C.MARKER))["bytes"]
            if bytes(tail) == C.MARKER:
                break
            result = machine.call("run_frames", frames=200)
            T.require(result["frames"] == 200 and result["stop_reason"] == "ReachedTarget", "Incomplete packet window")
        else:
            raise AssertionError("Native game-flow packet did not complete in bounded window")
        raw = bytes(b for off in range(0, len(expected), 128)
                    for b in machine.call("memory_read", addr=base + off, len=min(128, len(expected) - off))["bytes"])
        T.require(len(raw) == len(expected), "Truncated native game-flow packet")
        if raw != expected:
            at = next(i for i, (left, right) in enumerate(zip(raw, expected)) if left != right)
            raise AssertionError(f"Native game-flow packet differs at byte {at}, case {at // C.RECORD_BYTES}: {raw[at]} vs {expected[at]}")
        machine.call("save_screenshot", path=str(image))
        T.require(A.number(image, 420, 66, 3) == len(C.cases()), "Native count pixels differ")
        T.require(A.number(image, 388, 82, 2) == 0, "Native final status pixels differ")
        T.require(A.number(image, 388, 114) == len(expected), "Native allocated bank size differs")
        return {"program_sha256": hashlib.sha256(B.program(name).encode("ascii")).hexdigest(),
                "bank_address": base, "allocated_observer_bytes": len(expected),
                "case_count": len(C.cases()), "record_bytes": C.RECORD_BYTES,
                "packet": list(raw), "packet_sha256": hashlib.sha256(raw).hexdigest(),
                "image": image.name, "image_sha256": T.sha(image), "server": machine.server["serverInfo"]}
    finally:
        machine.close()
def source_paths():
    return sorted(F.glob("*.amos")) + [F / n for n in ["oracle.py", "build.py", "Makefile"]] + [Path(__file__), ROOT / "scripts/verify-amos-map-queries.py", ROOT / "scripts/verify-amos-deadline.py", ROOT / "scripts/verify-game-loops.py", ROOT / "scripts/check-amiga-command-loops.py"] + [A.PHASES / n for n in ["amos-cases-cold.json", "amos-cases-blank.json", "working-case.json"]]
def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ["emulator", "kickstart", "amos", "builder", "private"]:
        parser.add_argument("--" + name, required=True, type=Path)
    parser.add_argument("--prepare", action="store_true")
    parser.add_argument("--boot", action="store_true")
    parser.add_argument("--variants", default="cases")
    args = parser.parse_args()
    cfg = json.loads((A.FOLDER / "verification/configuration.json").read_text())
    assert T.sha(args.emulator) == cfg["emulator_sha256"] and T.sha(args.kickstart) == cfg["firmware_sha256"] and T.sha(args.amos) == cfg["runtime_media_sha256"] and T.sha(args.builder) == cfg["builder_sha256"], "Different original native configuration"
    if args.prepare:
        prepare(args)
    assert json.loads((args.private / "identity.json").read_text()) == identity(args), "Stale source fixture"
    if args.boot:
        for name in ["amos-cases-cold.json", "amos-cases-blank.json"]:
            machine = T.Machine(A.command(args))
            try:
                A.phase(machine, args, name)
            finally:
                machine.close()
    V.mkdir(exist_ok=True)
    target = V / "packets.json"
    prior = json.loads(target.read_text()) if target.exists() else {"cases": {}}
    sources = {str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()}
    if prior["cases"]:
        assert prior["sources"] == sources and prior["fixture"] == identity(args), "Changed qualification inputs; retain old evidence first"
    prior.update(system="commodore-amiga", language="amos", sources=sources, fixture=identity(args), configuration={k: cfg[k] for k in ["emulator_sha256", "firmware_sha256", "runtime_media_sha256", "builder_sha256", "configuration", "runtime"]})
    for name in args.variants.split(","):
        assert name not in prior["cases"], "Do not overwrite a qualified case"
        prior["cases"][name] = run(args, name)
        target.write_text(json.dumps(prior, indent=2) + "\n")
        print(name, "360 complete native transition packets and pixels passed", flush=True)
if __name__ == "__main__":
    main()
