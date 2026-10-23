"""Exercise four map operations through each stock 1 KiB BASIC ROM."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
S = importlib.util.spec_from_file_location(
    "memory", ROOT / "scripts/verify-zx-map-memory.py"
)
assert S and S.loader
M = importlib.util.module_from_spec(S)
S.loader.exec_module(M)
V = M.V
T = M.T


def number(raw: list) -> float:
    if raw[0] == 0:
        return 0
    mantissa = int.from_bytes(bytes([raw[1] & 127, *raw[2:5]]), "big")
    return (-1 if raw[1] & 128 else 1) * (1 + mantissa / 2**31) * 2 ** (raw[0] - 129)


def variables(raw: list, system: str) -> dict:
    result = {}
    i = 0
    while i < len(raw) - 1:
        tag = raw[i]
        kind = tag >> 5
        name = chr((tag & 31) + 32 - 38 + 65)
        if system.endswith("80"):
            if kind in (3, 7):
                size = 3 if kind == 3 else 7
                value = int.from_bytes(bytes(raw[i + 1 : i + 3]), "little", signed=True)
            elif kind == 5:
                count = raw[i + 1] + 1
                size = 2 + 2 * count
                value = [
                    int.from_bytes(bytes(raw[j : j + 2]), "little", signed=True)
                    for j in range(i + 2, i + size, 2)
                ]
            else:
                raise AssertionError(f"Unexpected ZX80 variable kind {kind}")
        else:
            if kind == 3:
                size = 6
                value = number(raw[i + 1 : i + 6])
            elif kind == 2:
                count = M.word(raw, i + 1)
                size = 3 + count
                value = raw[i + 3 : i + size]
                name += "$"
            else:
                raise AssertionError(f"Unexpected ZX81 variable kind {kind}")
        T.require(i + size <= len(raw) - 1, "Truncated variable record")
        T.require(name not in result, "Duplicate variable")
        result[name] = value
        i += size
    T.require(i == len(raw) - 1 and raw[-1] == 128, "Variable terminator missing")
    return result


def heap(machine: object, system: str) -> dict:
    sys = V.read(machine, 16384, 40)
    start = M.word(sys, 8 if system.endswith("80") else 16)
    end = M.word(sys, 10 if system.endswith("80") else 20)
    raw = V.read(machine, start, end - start)
    return {"address": start, "hex": bytes(raw).hex(), "values": variables(raw, system)}


def sources(system: str) -> dict:
    p = V.folder(system)
    paths = list((p / "compact").glob("*.bas")) + list(
        (p / "compact/mistakes").glob("*.bas")
    )
    paths += [
        p / "routines.bas",
        p / "demo.bas",
        ROOT / "scripts/verify-zx-map-memory.py",
        Path(__file__),
        ROOT / "scripts/verify-zx-basic-map.py",
        ROOT / "scripts/verify-game-loops.py",
    ]
    return {str(p.relative_to(ROOT)): T.sha(p) for p in sorted(set(paths))}


def calls(system: str) -> list:
    cases = []
    for r in range(5):
        for c in range(7):
            cases.append({"label": f"read-{c}-{r}", "op": "read", "args": [c, r]})
    for c, r in [(-1, 0), (0, -1), (7, 0), (0, 5)]:
        cases.append({"label": f"outside-{c}-{r}", "op": "read", "args": [c, r]})
    for c, r, t in [(7, 0, 1), (0, 5, 1), (0, 0, -1), (0, 0, 4)]:
        cases.append(
            {"label": f"reject-write-{c}-{r}-{t}", "op": "write", "args": [c, r, t]}
        )
    for t in [-1, 0, 1, 2, 3, 4]:
        cases.append({"label": f"property-{t}", "op": "property", "args": [t]})
    for x, y in [(0, 0), (7, 7), (8, 8), (55, 39), (56, 0), (0, 40), (-1, 0), (0, -1)]:
        cases.append({"label": f"world-{x}-{y}", "op": "world", "args": [x, y]})
    if system.endswith("81"):
        cases += [
            {"label": "fraction-column", "op": "read", "args": [0.5, 0]},
            {"label": "fraction-row", "op": "read", "args": [0, 0.5]},
            {"label": "fraction-ID", "op": "write", "args": [0, 0, 1.5]},
            {"label": "fraction-property", "op": "property", "args": [1.5]},
        ]
    cases += [
        {"label": "write-last", "op": "write", "args": [6, 4, 1]},
        {"label": "read-last", "op": "read", "args": [6, 4]},
        {"label": "write-first", "op": "write", "args": [0, 0, 3]},
        {"label": "read-first", "op": "read", "args": [0, 0]},
    ]
    return cases


def run(system: str, native: Path) -> None:
    p = V.folder(system)
    out = p / "verification/memory"
    out.mkdir(exist_ok=True)
    m, k, identity = M.boot(system, native, 1024)
    record = {
        "machine": system,
        "ram_bytes": 1024,
        "identity": identity,
        "sources": sources(system),
        "cases": [],
        "status": "incomplete",
    }
    k.keys["REM"] = "y" if system.endswith("80") else "e"
    try:
        for name in (
            ["compact/room.bas", "demo.bas", "routines.bas"]
            if system.endswith("80")
            else [
                "compact/room.bas",
                "compact/demo.bas",
                "compact/routines.bas",
                "compact/extras.bas",
            ]
        ):
            for line in (p / name).read_text().splitlines():
                k.line(line)
            print(system, "entered", name, flush=True)
        raw, lines = M.program(m, system)
        record["program_hex"] = bytes(raw).hex()
        record["lines"] = lines
        record["loaded_snapshot"] = M.snapshot(m, system, 1024, "loaded")
        k.key("r")
        k.key("enter")
        m.call("run_frames", frames=300)
        record["caller_screen"] = M.screen(m, system)
        record["caller_heap"] = heap(m, system)
        record["caller_snapshot"] = M.snapshot(m, system, 1024, "caller-stopped")
        m.call("save_screenshot", path=str(out / "compact-caller.png"))

        # Leave the ZX80 report screen before entering another command.
        if system.endswith("80"):
            k.key("enter")
        caller = (
            p / ("demo.bas" if system.endswith("80") else "compact/demo.bas")
        ).read_text()
        for line in caller.splitlines():
            n = int(line.split()[0])
            k.literal(str(n))
            k.key("enter")
            m.call("run_frames", frames=600)
            if n in k.expected_lines:
                k.expected_lines.remove(n)
        for line in (p / "compact/verify-caller.bas").read_text().splitlines():
            k.line(line)

        def start() -> dict:
            k.key("r")
            k.key("enter")
            m.call("run_frames", frames=300)
            return heap(m, system)

        record["dispatcher_start"] = start()
        rraw, rlines = M.program(m, system)
        record["dispatcher_program_hex"] = bytes(rraw).hex()
        record["dispatcher_lines"] = rlines

        def call(case: dict) -> dict:
            op = case["op"]
            args = case["args"]
            if op in ("read", "write"):
                c, r = args[:2]
                v = args[2] if op == "write" else 77
            elif op == "property":
                c, r, v = 0, 0, args[0]
            else:
                c, r = args
                v = 0
            target = (
                {"read": 1000, "write": 1100, "property": 1200, "world": 1300}
                if system.endswith("80")
                else {"read": 100, "write": 200, "property": 300, "world": 400}
            )[op]
            for value in (c, r, v, target):
                k.literal(str(value))
                k.key("enter")
                m.call("run_frames", frames=200)
            m.call("run_frames", frames=300)
            h = heap(m, system)
            s = M.screen(m, system)
            T.require(
                V.read(m, 16384, 1)[0] == 255, f"BASIC error in {case['label']}: {s}"
            )
            # PRINT history can scroll; state is independently decoded from VARS.
            return {
                "label": case["label"],
                "op": op,
                "args": args,
                "submitted": [c, r, v, target],
                "heap": h,
                "screen": s,
                "snapshot": M.snapshot(m, system, 1024, case["label"]),
            }

        for case in calls(system):
            actual = call(case)
            record["cases"].append(actual)
            print(
                system,
                case["label"],
                actual["heap"]["values"].get("T"),
                actual["snapshot"]["observed_gap"],
                flush=True,
            )

        # Faults get fresh ROM boots. INPUT mode is not an editing prompt.
        def variant(name: str, patches: list[str], cases: list[dict]) -> dict:
            nonlocal m, k
            m.close()
            m, k, variant_identity = M.boot(system, native, 1024)
            T.require(variant_identity == identity, "Variant tool/ROM changed")
            k.keys["REM"] = "y" if system.endswith("80") else "e"
            replacements = {int(line.split()[0]): line for line in patches}
            fragments = (
                ["compact/room.bas", "compact/verify-caller.bas", "routines.bas"]
                if system.endswith("80")
                else [
                    "compact/room.bas",
                    "compact/verify-caller.bas",
                    "compact/routines.bas",
                    "compact/extras.bas",
                ]
            )
            entry_clears = []
            for fragment in fragments:
                for line in (p / fragment).read_text().splitlines():
                    if system.endswith("81"):
                        before = M.snapshot(m, system, 1024, "before-entry-cls")
                        k.command("CLS")
                        after = M.snapshot(m, system, 1024, "after-entry-cls")
                        entry_clears.append(
                            {
                                "line": int(line.split()[0]),
                                "before": before,
                                "after": after,
                            }
                        )
                    k.line(replacements.get(int(line.split()[0]), line))
            raw, lines = M.program(m, system)
            result = {
                "patches": patches,
                "entry_clears": entry_clears,
                "program_hex": bytes(raw).hex(),
                "lines": lines,
                "initial_heap": start(),
                "cases": [],
            }
            for case in cases:
                result["cases"].append(call(case))
            print(system, "finished fresh", name, flush=True)
            record[name] = result
            return result

        custom_line = (
            "2450 LET P(3)=5"
            if system.endswith("80")
            else (p / "compact/customise.bas").read_text().strip()
        )
        wrong_line = (p / "compact/mistakes/wrong-stride.bas").read_text().strip()
        fault = variant(
            "stride_variant",
            [custom_line, wrong_line],
            [
                {"label": "closed-exit", "op": "property", "args": [3]},
                {"label": "wrong-stride", "op": "read", "args": [0, 2]},
            ],
        )
        record["custom_start"] = record["stride_start"] = fault["initial_heap"]
        record["customisation"], record["wrong_stride"] = fault["cases"]
        fault = variant(
            "write_variant",
            [(p / "compact/mistakes/write-without-valid.bas").read_text().strip()],
            [
                {"label": "first-offset", "op": "read", "args": [0, 0]},
                {"label": "write-without-valid", "op": "write", "args": [7, 0, 1]},
            ],
        )
        record["write_start"] = fault["initial_heap"]
        record["seed_offset"], record["bad_write"] = fault["cases"]
        m.call("save_screenshot", path=str(out / "compact-bad-write.png"))
        repair = variant(
            "repair_variant",
            [],
            [
                {"label": "stride-repaired", "op": "read", "args": [0, 2]},
                {"label": "write-repaired", "op": "write", "args": [7, 0, 2]},
            ],
        )
        record["stride_repair_start"] = record["write_repair_start"] = repair[
            "initial_heap"
        ]
        record["stride_repair"], record["write_repair"] = repair["cases"]
        record["status"] = "passed"
    except Exception:
        record["failure_screen"] = M.screen(m, system)
        m.call("save_screenshot", path=str(out / "compact-failure.png"))
        raise
    finally:
        (out / "compact.json").write_text(json.dumps(record, indent=2) + "\n")
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--system", choices=V.SYSTEMS, required=True)
    a = p.parse_args()
    run(a.system, a.native.resolve())


if __name__ == "__main__":
    main()
