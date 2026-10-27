"""Execute complete state cases and four owners through the stock Ace ROM."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
F = ROOT / "jupiter-ace/patterns/forth/framework/game-flow"
V = F / "verification"


def module(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


A = module("ace_native", ROOT / "scripts/verify-ace-deadline.py")
T = A.T
C = module("ace_flow_model", F / "oracle.py")
NAMES = ("GS", "GE", "GC", "GF", "GX", "GN")
TRACE = (0, 3, 3, 0, 0, 3, 3, 0, 3, 0, 4, 0, 8, 8, 0)


def sources() -> dict[str, str]:
    paths = [p for p in F.rglob("*.fth") if not p.is_relative_to(F / "build")]
    paths += [
        F / "Makefile",
        F / "oracle.py",
        Path(__file__),
        ROOT / "docs/ace-map-tools.json",
        ROOT / "scripts/verify-ace-deadline.py",
        ROOT / "scripts/verify-game-loops.py",
        ROOT / "scripts/check-amiga-command-loops.py",
    ]
    return {str(p.relative_to(ROOT)): T.sha(p) for p in sorted(paths)}


def config() -> dict[str, Any]:
    return json.loads((ROOT / "docs/ace-map-tools.json").read_text())


def cpu_sp(machine: Any) -> int:
    return int(machine.call("query_cpu")["registers"]["sp"].lstrip("$"), 16)


def capture(machine: Any, name: str) -> dict[str, Any]:
    path = V / (name + ".png")
    T.require(not path.exists(), "Preserve earlier native capture")
    machine.call("run_frames", frames=2)
    machine.call("save_screenshot", path=str(path))
    return {
        "image": path.name,
        "image_sha256": T.sha(path),
        "pixels": A.capture_check(machine, path),
    }


def prepare(machine: Any, files: list[str]) -> dict[str, Any]:
    result = machine.call("run_frames", frames=150)
    T.require(
        result["frames"] == 150 and result["stop_reason"] == "ReachedTarget",
        "Incomplete stock boot",
    )
    A.enter(machine, ": NUMBER CLS U. ;")
    before = A.value(machine, "HERE")
    ram_top = A.value(machine, "15384 @")
    T.require(ram_top == 16384, "Not the unexpanded 3 KiB machine")
    sizes = {}
    for name in files:
        for line in (F / name).read_text().splitlines():
            A.enter(machine, line)
        sizes[name] = A.value(machine, "HERE")
        print(name, "HERE", sizes[name], flush=True)
    here = A.read(machine, 15415)
    T.require(A.read(machine, 15419) == here + 12, "Definition entry leaked stack")
    return {
        "here_before": before,
        "here_after_files": sizes,
        "here": here,
        "ram_top": ram_top,
        "dictionary_before_hex": dictionary(machine, before, here).hex(),
        "entered_source_sha256": hashlib.sha256(
            "".join((F / name).read_text() for name in files).encode("ascii")
        ).hexdigest(),
    }


def dictionary(machine: Any, start: int, end: int) -> bytes:
    T.require(15441 <= start < end < 16384, "Invalid native compiled dictionary extent")
    result = bytearray()
    for address in range(start, end, 128):
        size = min(128, end - address)
        raw = machine.call("memory_read", addr=address, len=size)["bytes"]
        T.require(len(raw) == size, "Truncated native dictionary")
        result.extend(raw)
    return bytes(result)


def compiled_identity(
    machine: Any, result: dict[str, Any], addresses: dict[str, int]
) -> None:
    start, end = result["here_before"], result["here"]
    before = bytes.fromhex(result["dictionary_before_hex"])
    after = dictionary(machine, start, end)
    T.require(len(before) == len(after) == end - start, "Incomplete compiled identity")
    T.require(
        len(set(addresses.values())) == len(addresses),
        "Aliased native variable storage",
    )
    a, b = bytearray(before), bytearray(after)
    for address in addresses.values():
        T.require(start <= address < end - 1, "Native variable outside dictionary")
        a[address - start : address - start + 2] = b"\x00\x00"
        b[address - start : address - start + 2] = b"\x00\x00"
    T.require(a == b, "Compiled code or headers changed outside variable payload")
    result["program_identity"] = {
        "start": start,
        "bytes": end - start,
        "before_sha256": hashlib.sha256(before).hexdigest(),
        "after_hex": after.hex(),
        "after_sha256": hashlib.sha256(after).hexdigest(),
        "immutable_sha256": hashlib.sha256(a).hexdigest(),
    }


def observe(machine: Any, here: int) -> dict[str, int]:
    top, sp = A.read(machine, 15419), cpu_sp(machine)
    T.require(here + 12 <= top < sp <= 16384, "Native stack separation exhausted")
    return {"dictionary": here, "data_top": top, "cpu_sp": sp, "separation": sp - top}


def table(args: argparse.Namespace) -> dict[str, Any]:
    machine = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.firmware)])
    try:
        result = prepare(machine, ["routines.fth", "boundaries.fth"])
        here = result["here"]
        addresses = {
            n: A.value(machine, n) for n in NAMES + ("OA", "OB", "OC", "OD", "OE")
        }
        A.enter(machine, "65535 OA ! 32768 OB ! 3 OC ! 0 OD !")
        rows = []
        for index, (state, events, initialise) in enumerate(C.cases()):
            word = "GICASE" if initialise else "GCASE"
            command = f"77 {state} {events} {word}"
            A.enter(machine, command)
            values = [A.read(machine, addresses[n]) for n in NAMES + ("OA", "OB", "OC")]
            completed = A.read(machine, addresses["OD"])
            T.require(
                values == C.expected(state, events, initialise),
                f"Ace state row{index} differs: {values}",
            )
            T.require(
                completed == index + 1 and A.read(machine, 15419) == here + 14,
                "Incomplete call or lower-stack damage",
            )
            row: dict[str, Any] = {
                "inputs": [state, events, initialise],
                "values": values,
                "completed": completed,
                "after_return": observe(machine, here),
                "command": command,
            }
            if index in (0, 1, 18, 20, 40, 64, 315, 320, 365):
                A.enter(machine, "GWAIT")
                T.require(
                    A.read(machine, addresses["OE"]) == 1,
                    "Diagnostic caller is not waiting",
                )
                row["while_waiting"] = observe(machine, here)
                answer = machine.call("type_string", text="\n", settle_frames=8)
                T.require(answer["chars_typed"] == 1, "Incomplete fresh Return trigger")
                T.require(
                    A.read(machine, addresses["OE"]) == 0,
                    "Diagnostic caller failed to return",
                )
            row["tag"] = A.value(machine, "")
            T.require(
                row["tag"] == 77 and A.read(machine, 15419) == here + 12,
                "Caller leaked or consumed stack prefix",
            )
            rows.append(row)
            if index % 32 == 0:
                print("table", index + 1, "/", len(C.cases()), flush=True)
        A.enter(machine, "GLOOK")
        compiled_identity(machine, result, addresses)
        result.update(
            addresses=addresses,
            rows=rows,
            capture=capture(machine, "table"),
            server=machine.server["serverInfo"],
        )
        return result
    except Exception:
        machine.call("save_screenshot", path=str(V / "failed-table.png"))
        raise
    finally:
        machine.close()


def owner_expected(name: str) -> list[int]:
    return (
        [0, 3, 1, 2, 3, 2]
        if name == "wrong"
        else [4, 2, 1, 2, 5 if name == "custom" else 3, 6]
    )


def owner(args: argparse.Namespace, name: str) -> dict[str, Any]:
    machine = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.firmware)])
    try:
        files = [
            "routines.fth",
            "mistakes/reset-on-resume.fth" if name == "wrong" else "reset.fth",
            "caller.fth",
            "customise.fth" if name == "custom" else "settings.fth",
        ]
        result = prepare(machine, files)
        here = result["here"]
        addresses = {
            n: A.value(machine, n) for n in NAMES + ("GP", "GV", "GH", "GL", "GR")
        }
        A.enter(machine, "77 GNEW")
        rows = []
        resumed = finished = 0
        for frame, held in enumerate(TRACE):
            A.enter(machine, str(held) + " GTICK")
            state = {n: A.read(machine, addr) for n, addr in addresses.items()}
            T.require(
                state == C.owner_rows(name)[frame], "Full native owner context differs"
            )
            T.require(
                A.read(machine, 15419) == here + 14, "Owner disturbed lower stack"
            )
            rows.append(
                {
                    "frame": frame,
                    "held": held,
                    "state": state,
                    "stack": observe(machine, here),
                }
            )
            if frame == 8:
                resumed = state["GV"]
                A.enter(machine, "GSHOW")
                result["resumed_capture"] = capture(machine, name + "-resumed")
            if frame == 10:
                finished = state["GV"]
        final = rows[-1]["state"]
        outputs = [
            resumed,
            final["GR"],
            final["GS"],
            final["GV"],
            final["GL"],
            finished,
        ]
        T.require(
            outputs == owner_expected(name),
            "Owner resume/reset/custom behaviour differs",
        )
        tag = A.value(machine, "")
        T.require(
            tag == 77 and A.read(machine, 15419) == here + 12,
            "Owner leaked or consumed prefix",
        )
        A.enter(machine, "GSHOW")
        compiled_identity(machine, result, addresses)
        result.update(
            rows=rows,
            outputs=outputs,
            tag=tag,
            addresses=addresses,
            final_capture=capture(machine, name + "-final"),
            server=machine.server["serverInfo"],
        )
        return result
    except Exception:
        machine.call("save_screenshot", path=str(V / ("failed-" + name + ".png")))
        raise
    finally:
        machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--emulator", required=True, type=Path)
    parser.add_argument("--firmware", required=True, type=Path)
    args = parser.parse_args()
    cfg = config()
    T.require(
        T.sha(args.emulator) == cfg["emulator_sha256"]
        and T.sha(args.firmware) == cfg["firmware_sha256"]
        and args.firmware.stat().st_size == 8192,
        "Changed original Ace configuration",
    )
    T.require(
        len(C.cases()) == len(set(C.cases())) == 366,
        "Empty or incomplete native state model",
    )
    V.mkdir(exist_ok=True)
    target = V / "native.json"
    T.require(
        not target.exists() and not list(V.glob("*.png")),
        "Retain earlier proof before fresh run",
    )
    pins = sources()
    record: dict[str, Any] = {
        "system": "jupiter-ace",
        "language": "forth",
        "configuration": cfg,
        "sources": pins,
        "cases": {},
    }
    for name in ("table", "working", "custom", "wrong", "repaired"):
        record["cases"][name] = table(args) if name == "table" else owner(args, name)
        T.require(pins == sources(), "Changed source during native qualification")
        target.write_text(json.dumps(record, indent=2) + "\n")
        print(name, "original ROM observations passed", flush=True)


if __name__ == "__main__":
    main()
