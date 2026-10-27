"""Run each complete generated pool caller through fresh original-ROM boots."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import signal
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "ace_pool_native", ROOT / "scripts/verify-ace-object-pool.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native pool verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
B = V.module("ace_pool_builder", V.F / "build.py")


def qualify(args: argparse.Namespace, group: str) -> None:
    target = V.V / ("callers-" + group + ".json")
    image = V.V / ("callers-" + group + ".png")
    V.T.require(
        not target.exists() and not image.exists(),
        "Preserve earlier full-caller evidence",
    )
    n = V.Native(args, group)
    script_sha = V.T.sha(Path(__file__))
    record = n.record
    record.update(
        group=group,
        producer_sha256=script_sha,
        configuration=json.loads((ROOT / "docs/ace-map-tools.json").read_text()),
        caller_rows=[],
    )
    try:
        n.prepare()
        text = B.program(group)
        loaded = "".join((V.F / f).read_text() for f in record["files"])
        V.T.require(text.startswith(loaded), "Builder changed native loaded recipe")
        demo = text[len(loaded) :].splitlines()
        expected_demo = (V.F / "demo.fth").read_text()
        if group == "wrong":
            expected_demo = expected_demo.replace("0 PREL DROP", "0 DROP")
        V.T.require(demo == expected_demo.splitlines(), "Wrong generated owner recipe")
        record.update(
            program_sha256=hashlib.sha256(text.encode("ascii")).hexdigest(),
            demo_lines=demo,
        )
        for line in demo:
            if line == "PNEW U.":
                result = V.C.step(
                    n.state,
                    n.flags,
                    n.here,
                    "init",
                    n.state["PC"],
                    n.addresses["SLOTS"],
                )
                V.T.require(result == [1], "Owner initialisation failed")
            elif line.startswith("NEWOBJ DROP DROP"):
                slot, ok = V.C.step(n.state, n.flags, n.here, "get")
                if ok:
                    n.payload[slot] = 60
            elif line == "0 PREL DROP":
                V.C.step(n.state, n.flags, n.here, "release", 0)
            n.enter(line)
            raw = n.bytes(record["before"], n.here - record["before"])
            expected = bytearray.fromhex(record["dictionary_before_hex"])
            for name, value in n.state.items():
                offset = n.addresses[name] - record["before"]
                expected[offset : offset + 2] = value.to_bytes(2, "little")
            offset = n.addresses["SLOTS"] - record["before"]
            expected[offset : offset + 9] = bytes(n.flags)
            offset = n.addresses["PAYLOAD"] - record["before"]
            expected[offset : offset + 18] = b"".join(
                v.to_bytes(2, "little") for v in n.payload
            )
            V.T.require(
                raw == expected, "Generated caller changed context, storage or code"
            )
            top = V.A.read(n.machine, 15419)
            V.T.require(
                V.A.read(n.machine, 15415) == n.here
                and top == n.here + 14
                and V.A.read(n.machine, n.here + 12) == 77,
                "Generated caller leaked stack or changed prefix",
            )
            cpu = int(n.machine.call("query_cpu")["registers"]["sp"].lstrip("$"), 16)
            V.T.require(top < cpu <= 16384, "Generated caller stack collision")
            record["caller_rows"].append(
                {
                    "line": line,
                    "state": n.state.copy(),
                    "flags": n.flags.copy(),
                    "payload": n.payload.copy(),
                    "dictionary_hex": raw.hex(),
                    "data_top": top,
                    "prefix": 77,
                    "cpu_sp": cpu,
                }
            )
        n.machine.call("save_screenshot", path=str(image))
        record["capture"] = {
            "image": image.name,
            "sha256": V.T.sha(image),
            "pixels": V.A.capture_check(n.machine, image),
        }
        n.enter("NUMBER")
        record["final_stack"] = {
            "dictionary": V.A.read(n.machine, 15415),
            "data_top": V.A.read(n.machine, 15419),
            "screen_hex": bytes(V.A.screen(n.machine)[0]).hex(),
        }
        V.T.require(
            V.A.read(n.machine, 15419) == n.here + 12,
            "Generated caller did not leave an empty stack",
        )
        V.T.require(
            V.sources() == record["sources"] and V.T.sha(Path(__file__)) == script_sha,
            "Caller input changed during original-ROM execution",
        )
        record["complete"] = True
        print(
            group,
            len(record["caller_rows"]),
            "complete generated owner passed",
            flush=True,
        )
    finally:
        try:
            target.write_text(json.dumps(record, indent=2) + "\n")
        finally:
            n.machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--emulator", type=Path, required=True)
    parser.add_argument("--firmware", type=Path, required=True)
    args = parser.parse_args()
    cfg = json.loads((ROOT / "docs/ace-map-tools.json").read_text())
    V.T.require(
        V.T.sha(args.emulator) == cfg["emulator_sha256"]
        and V.T.sha(args.firmware) == cfg["firmware_sha256"],
        "Changed original runtime",
    )
    signal.signal(
        signal.SIGALRM,
        lambda *_: (_ for _ in ()).throw(TimeoutError("1800 second caller bound")),
    )
    signal.alarm(1800)
    V.V.mkdir(exist_ok=True)
    for group in B.VARIANTS:
        qualify(args, group)
    signal.alarm(0)


if __name__ == "__main__":
    main()
