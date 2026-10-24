"""Load maintained Spectrum BASIC through ROM tape and qualify countdown state."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


A = module("spectrum_assembly", "verify-spectrum-assembly-deadlines.py")
T = A.T
F = ROOT / "sinclair-zx-spectrum/patterns/basic/framework/turn-deadline"
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")
CASES = A.A.B.CASES


def source_paths() -> list[Path]:
    return (
        [
            F / n
            for n in (
                "caller.bas",
                "customise.bas",
                "routines.bas",
                "clock.bas",
                "dispatch.bas",
                "input.bas",
                "presentation.bas",
                "monitor.bas",
                "mistakes/reset-baseline.bas",
                "Makefile",
            )
        ]
        + [Path(__file__)]
        + A.source_paths()
    )


def fixture_listing(wrong: bool = False) -> str:
    driver = """   5 CLEAR 49999
  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET O=50001: POKE 50000,165
  30 FOR I=1 TO 12
  40 READ DU,DC,DV: GO SUB 3000: GO SUB 3100
  50 LET DC=DV: GO SUB 3200: GO SUB 2000
  60 NEXT I
 100 LET N=0: LET EX=0: LET DX=1: LET K$=" ": GO SUB 6000
 110 POKE O,N: POKE O+1,EX
 120 LET DX=1: LET K$="T": GO SUB 6000
 130 POKE O+2,N: POKE O+3,DA
 140 LET DX=0: LET DA=0: LET K$=" ": GO SUB 6000
 150 POKE O+4,N: POKE O+5,DA: POKE O+6,90: POKE O+7,239
 160 STOP
2000 POKE O,DR-256*INT (DR/256): POKE O+1,INT (DR/256)
2010 POKE O+2,DA: POKE O+3,DX
2020 POKE O+4,DE-256*INT (DE/256): POKE O+5,INT (DE/256)
2030 POKE O+6,DP-256*INT (DP/256): POKE O+7,INT (DP/256)
2040 LET O=O+8: RETURN
"""
    helper = (F / "routines.bas").read_text()
    if wrong:
        helper = helper.replace("IF DR>0 THEN", "IF DR>=0 THEN")
    data = "".join(
        f"{9100 + i} DATA " + ",".join(map(str, c)) + "\n" for i, c in enumerate(CASES)
    )
    return canonical(driver + helper + (F / "dispatch.bas").read_text() + data)


def canonical(text: str) -> str:
    lines = [l.split(maxsplit=1) for l in text.splitlines() if l.strip()]
    T.require(len({int(l[0]) for l in lines}) == len(lines), "Duplicate BASIC line")
    return "".join(
        f"{int(n):4d} {body}\n" for n, body in sorted(lines, key=lambda x: int(x[0]))
    )


def listing(variant: str) -> str:
    if "boundar" in variant:
        return fixture_listing(variant == "wrong-boundary")
    names = [
        "customise.bas" if variant == "custom" else "caller.bas",
        "dispatch.bas",
        "input.bas",
        "routines.bas",
        "mistakes/reset-baseline.bas" if variant == "wrong" else "clock.bas",
        "presentation.bas",
        "monitor.bas",
    ]
    return canonical("".join((F / n).read_text() for n in names))


def number(raw: list[int]) -> float | int:
    T.require(len(raw) == 5, "Truncated Sinclair number")
    if raw[0] == 0:
        return raw[2] + 256 * raw[3] - (65536 if raw[1] == 255 else 0)
    mantissa = (
        (1 << 31) | ((raw[1] & 127) << 24) | (raw[2] << 16) | (raw[3] << 8) | raw[4]
    )
    return (-1 if raw[1] & 128 else 1) * mantissa * 2.0 ** (raw[0] - 160)


def variables(raw: list[int]) -> list[dict[str, Any]]:
    i = 0
    result = []
    while i < len(raw) and raw[i] != 128:
        start = i
        tag = raw[i]
        i += 1
        kind = tag >> 5
        name = chr((tag & 31) + 96)
        if kind == 5:
            while True:
                c = raw[i]
                i += 1
                name += chr(c & 127)
                if c & 128:
                    break
        if kind in (3, 5, 7):
            value = number(raw[i : i + 5])
            i += 18 if kind == 7 else 5
        elif kind == 2:
            size = int.from_bytes(bytes(raw[i : i + 2]), "little")
            i += 2
            value = bytes(raw[i : i + size]).decode("ascii")
            i += size
            name += "$"
        else:
            raise AssertionError(("Unexpected variable kind", kind, i, raw))
        T.require(i <= len(raw), "Variable overrun")
        result.append({"name": name, "kind": kind, "value": value, "bytes": i - start})
    T.require(
        i == len(raw) - 1 and raw[i] == 128, "Missing native variables terminator"
    )
    return result


def memory_layout(m: Any) -> dict[str, Any]:
    def read(addr: int, n: int) -> list[int]:
        return m.call("memory_read", addr=addr, len=n)["bytes"]

    def chunk(addr: int, n: int) -> list[int]:
        return [
            byte for i in range(0, n, 128) for byte in read(addr + i, min(128, n - i))
        ]

    ptrs = {
        name: read(addr, 2)
        for name, addr in [
            ("prog", 23635),
            ("vars", 23627),
            ("e_line", 23641),
            ("stkend", 23653),
            ("ramtop", 23730),
        ]
    }
    word = lambda x: int.from_bytes(bytes(x), "little")
    start, end, edit, stack, top = [
        word(ptrs[k]) for k in ["prog", "vars", "e_line", "stkend", "ramtop"]
    ]
    T.require(
        23755 <= start < end < edit <= stack < top == 49999,
        "Invalid Spectrum BASIC workspace",
    )
    program = chunk(start, end - start)
    varbytes = chunk(end, edit - end)
    entries = variables(varbytes)
    lines = []
    i = 0
    while i < len(program):
        T.require(i + 4 <= len(program), "Truncated native line")
        n = int.from_bytes(bytes(program[i : i + 2]), "big")
        length = int.from_bytes(bytes(program[i + 2 : i + 4]), "little") + 4
        T.require(
            length >= 5
            and i + length <= len(program)
            and program[i + length - 1] == 13,
            "Invalid native line length",
        )
        lines.append({"number": n, "bytes": length})
        i += length
    return {
        "pointers": ptrs,
        "program_start": start,
        "program_end": end,
        "program_bytes": program,
        "lines": lines,
        "variable_bytes": varbytes,
        "variables": entries,
        "variable_extent": edit - end,
        "helper_token_bytes": sum(
            l["bytes"] for l in lines if 3000 <= l["number"] <= 3250
        ),
        "helper_variable_bytes": sum(
            v["bytes"]
            for v in entries
            if v["name"] in ("du", "dc", "dp", "dr", "da", "dx", "de")
        ),
        "memory_limit": top,
        "stack_end": stack,
    }


def run(args: argparse.Namespace, variant: str) -> dict[str, Any]:
    out = F / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    text = listing(variant)
    (out / "caller.bas").write_text(text)
    subprocess.run(
        [
            str(args.build198x),
            "basic",
            str(out / "caller.bas"),
            "--machine",
            "sinclair-zx-spectrum",
            "-o",
            str(out / "caller.tap"),
        ],
        check=True,
        timeout=30,
        capture_output=True,
    )
    program = list(A.blocks(out / "caller.tap", 2)[1][1:-1])
    m = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.rom)])
    frames = 0
    samples = []

    def advance(n: int) -> None:
        nonlocal frames
        for i in range(0, n, 200):
            c = min(200, n - i)
            m.call("run_frames", frames=c)
            frames += c

    def read(addr: int, n: int) -> list[int]:
        return m.call("memory_read", addr=addr, len=n)["bytes"]

    def observe(stage: str) -> dict[str, Any]:
        for _ in range(80):
            raw = read(50000, 19)
            if raw[18] == 202:
                break
            advance(1)
        T.require(raw[16:19] == [165, 90, 202], "Incomplete native observer")
        sample = {
            "stage": stage,
            "frames": frames,
            "raw": raw,
            "turn": raw[0],
            "expiries": raw[1],
            "active": raw[2],
            "event": raw[3],
            "remaining": int.from_bytes(bytes(raw[4:6]), "little"),
            "clock": int.from_bytes(bytes(raw[6:8]), "little"),
            "previous": int.from_bytes(bytes(raw[8:10]), "little"),
            "elapsed": int.from_bytes(bytes(raw[10:12]), "little"),
            "duration": int.from_bytes(bytes(raw[12:14]), "little"),
        }
        samples.append(sample)
        print(variant, stage, sample, flush=True)
        return sample

    def key(name: str, pressed: bool, n: int) -> None:
        m.call("input", events=[{"Key": {"name": name, "pressed": pressed}}])
        advance(n)

    def tap(name: str) -> None:
        key(name, True, 30)
        key(name, False, 30)

    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(out / "caller.tap"))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        for _ in range(100):
            advance(100)
            raw = read(50000, 105 if "boundar" in variant else 19)
            if (
                raw[0] == 165 and raw[-2:] == [90, 239]
                if "boundar" in variant
                else raw[16:19] == [165, 90, 202]
            ):
                break
        else:
            raise AssertionError("BASIC did not complete startup/fixture")
        if "boundar" in variant:
            T.require(
                (raw == A.expected_fixture()) == (variant == "boundaries"),
                "Native arithmetic/policy oracle mismatch",
            )
            result = {"bytes": raw, "oracle_matches": raw == A.expected_fixture()}
            layout = memory_layout(m)
            result["return_screen"] = A.returned(m, advance)
        else:
            first = observe("initial")
            advance(60)
            idle = observe("untimed-idle")
            T.require(
                first["turn"] == idle["turn"] == 0 and first["clock"] != idle["clock"],
                "Idle changed world or clock stopped",
            )
            key("space", True, 90)
            key("space", False, 30)
            action = observe("untimed-action")
            T.require(
                action["turn"] == 1 and action["active"] == 0, "Held action repeated"
            )
            tap("t")
            enabled = observe("enabled")
            advance(20)
            progress = observe("idle-progress")
            T.require(progress["active"] == enabled["active"] == 1, "No enabled timer")
            if variant == "wrong":
                advance(300)
                expired = observe("wrong-never-expires")
                T.require(
                    expired["turn"] == 1
                    and expired["expiries"] == 0
                    and expired["remaining"] == 200,
                    "No baseline-reset symptom",
                )
            else:
                T.require(
                    progress["remaining"] < enabled["remaining"],
                    "Timer did not count down",
                )
                tap("space")
                restart = observe("action-restarts")
                T.require(
                    restart["turn"] == 2 and restart["active"] == 1,
                    "Timed action failed",
                )
                for _ in range(50):
                    advance(5)
                    expired = observe("await-expiry")
                    if expired["expiries"]:
                        break
                T.require(
                    expired["turn"] == 3 and expired["expiries"] == 1,
                    "No automatic turn",
                )
            advance(2)
            expected = (
                f"TURN {expired['turn']} E {expired['expiries']} T {expired['active']}"
            )
            # Redraw finishes before its observer marker. Find the actual native row.
            lines = m.call("query", path="screen.text.lines")["result"]["value"]
            T.require(lines[1].startswith(expected), "Native text differs")
            render = A.pixels(m, 1, expected)
            image = F / "verification" / (variant + ".png")
            m.call("save_screenshot", path=str(image))
            layout = memory_layout(m)
            tap("t")
            disabled = observe("disabled")
            advance(250)
            stopped = observe("disabled-idle")
            T.require(
                not stopped["active"] and stopped["turn"] == disabled["turn"],
                "Disable failed",
            )
            key("q", True, 30)
            key("q", False, 60)
            result = {
                "samples": samples,
                "pixels": render,
                "return_screen": A.returned(m, advance),
            }
        T.require(
            layout["program_bytes"] == program,
            "ROM-loaded tokenised program differs from TAP",
        )
        image = F / "verification" / (variant + ".png")
        if "boundar" in variant:
            m.call("save_screenshot", path=str(image))
        return result | {
            "layout": layout,
            "program_sha256": hashlib.sha256(bytes(program)).hexdigest(),
            "source_sha256": hashlib.sha256(text.encode()).hexdigest(),
            "tap_sha256": T.sha(out / "caller.tap"),
            "server": m.server["serverInfo"],
            "image": image.name,
            "image_sha256": T.sha(image),
        }
    except Exception:
        m.call("save_screenshot", path=str(F / "verification/diagnostic.png"))
        raise
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", type=Path, required=True)
    p.add_argument("--rom", type=Path, required=True)
    p.add_argument("--build198x", type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    out = F / "verification"
    out.mkdir(parents=True, exist_ok=True)
    target = out / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"machine": "sinclair-zx-spectrum", "language": "basic", "cases": {}}
    )
    for v in args.variants.split(","):
        T.require(v in VARIANTS, "Unknown variant")
        r["cases"][v] = run(args, v)
        r.update(
            sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
            emulator_sha256=T.sha(args.emulator),
            firmware_sha256={args.rom.name: T.sha(args.rom)},
            build198x_sha256=T.sha(args.build198x),
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(v, "passed", flush=True)


if __name__ == "__main__":
    main()
