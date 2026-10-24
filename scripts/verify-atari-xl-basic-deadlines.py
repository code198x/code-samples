"""Type Atari BASIC callers and retain native countdown, allocation and output."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
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


A = module("atari_assembly", "verify-atari-xl-assembly-deadlines.py")
T = A.T
F = ROOT / "atari-800xl/patterns/basic/framework/turn-deadline"
HELPER = ROOT / "dragon-32/patterns/basic/framework/turn-deadline/routines.bas"
VARIANTS = A.VARIANTS


def canonical(text: str) -> str:
    lines = [l.split(maxsplit=1) for l in text.splitlines() if l.strip()]
    T.require(len({int(l[0]) for l in lines}) == len(lines), "Duplicate BASIC line")
    return "".join(
        f"{n} {body}\n" for n, body in sorted(lines, key=lambda l: int(l[0]))
    )


def fixture_listing(wrong: bool = False) -> str:
    driver = """5 POKE 106,124:GRAPHICS 0
10 O=32769:POKE 32768,165
20 FOR I=0 TO 11
30 READ DU,DC,DV:GOSUB 3000:GOSUB 3100:DC=DV:GOSUB 3200:GOSUB 2000
40 NEXT I
100 N=0:EX=0:DX=1:K=1:GOSUB 6000
110 POKE O,N:POKE O+1,EX
120 DX=1:K=2:GOSUB 6000
130 POKE O+2,N:POKE O+3,DA
140 DX=0:DA=0:K=1:GOSUB 6000
150 POKE O+4,N:POKE O+5,DA:POKE O+6,90:POKE O+7,239
160 END
2000 POKE O,DR-256*INT(DR/256):POKE O+1,INT(DR/256)
2010 POKE O+2,DA:POKE O+3,DX
2020 POKE O+4,DE-256*INT(DE/256):POKE O+5,INT(DE/256)
2030 POKE O+6,DP-256*INT(DP/256):POKE O+7,INT(DP/256)
2040 O=O+8:RETURN
"""
    helper = HELPER.read_text()
    if wrong:
        helper = helper.replace("IF DR>0 THEN", "IF DR>=0 THEN")
    data = "".join(
        f"{9100 + i} DATA " + ",".join(map(str, c)) + "\n"
        for i, c in enumerate(A.B.CASES)
    )
    return canonical(driver + helper + (F / "dispatch.bas").read_text() + data)


def listing(variant: str) -> str:
    if "boundar" in variant:
        return fixture_listing(variant == "wrong-boundary")
    names = [
        "customise.bas" if variant == "custom" else "caller.bas",
        "input.bas",
        "dispatch.bas",
        "presentation.bas",
        "monitor.bas",
        "mistakes/reset-baseline.bas" if variant == "wrong" else "clock.bas",
    ]
    return canonical("".join((F / n).read_text() for n in names) + HELPER.read_text())


def source_paths() -> list[Path]:
    return (
        [
            F / n
            for n in [
                "caller.bas",
                "customise.bas",
                "clock.bas",
                "input.bas",
                "dispatch.bas",
                "presentation.bas",
                "monitor.bas",
                "Makefile",
                "mistakes/reset-baseline.bas",
            ]
        ]
        + [HELPER, Path(__file__)]
        + A.source_paths()
    )


def layout(m: Any) -> dict[str, Any]:
    def chunk(addr: int, n: int) -> list[int]:
        return [
            b
            for i in range(0, n, 128)
            for b in m.call("memory_read", addr=addr + i, len=min(128, n - i))["bytes"]
        ]

    ptr = chunk(128, 18)
    w = lambda i: int.from_bytes(bytes(ptr[i : i + 2]), "little")
    nt, ne, vt, st, ar = w(2), w(4), w(6), w(8), w(12)
    T.require(
        0 < nt < ne <= vt < st < ar < 31744, "BASIC workspace outside reservation"
    )
    raw = chunk(st, ar - st)
    lines = []
    i = 0
    while i < len(raw):
        n = int.from_bytes(bytes(raw[i : i + 2]), "little")
        size = raw[i + 2]
        if n == 32768:
            T.require(
                size >= 3 and i + size == len(raw), "Invalid immediate-mode record"
            )
            break
        T.require(size >= 4 and i + size <= len(raw), "Invalid Atari native line")
        lines.append({"number": n, "bytes": size})
        i += size
    names = []
    name = ""
    for b in chunk(nt, ne - nt):
        if b == 0:
            break
        name += chr(b & 127)
        if b & 128:
            names.append(name)
            name = ""
    values = chunk(vt, st - vt)
    T.require(len(values) == 8 * len(names), "Variable table/name count mismatch")
    return {
        "pointers": ptr,
        "program_bytes": raw[:i],
        "lines": lines,
        "name_bytes": chunk(nt, ne - nt),
        "value_bytes": values,
        "names": names,
        "helper_token_bytes": sum(
            l["bytes"] for l in lines if 3000 <= l["number"] <= 3250
        ),
        "ramtop": chunk(106, 1),
        "savmsc": chunk(88, 2),
        "memtop": chunk(741, 2),
    }


def run(args: argparse.Namespace, variant: str) -> dict[str, Any]:
    text = listing(variant)
    out = F / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    (out / "demo.bas").write_text(text)
    m = T.Machine([str(args.emulator), "--mcp", "--rom-dir", str(args.firmware)])
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
        for _ in range(150):
            raw = read(32768, 19)
            if raw[16:19] == [165, 90, 202]:
                break
            advance(1)
        T.require(raw[16:19] == [165, 90, 202], "Incomplete native BASIC observer")
        state = {
            "stage": stage,
            "frames": frames,
            "raw": raw,
            "turn": raw[0],
            "expiries": raw[1],
            "active": raw[2],
            "event": raw[3],
        }
        for name, i in [
            ("remaining", 4),
            ("clock", 6),
            ("previous", 8),
            ("elapsed", 10),
            ("duration", 12),
        ]:
            state[name] = int.from_bytes(bytes(raw[i : i + 2]), "little")
        samples.append(state)
        print(variant, stage, state, flush=True)
        return state

    def control(name: str, pressed: bool, n: int) -> None:
        event = (
            {"Button": {"port": 1, "name": "fire", "pressed": pressed}}
            if name == "fire"
            else {"Key": {"name": name, "pressed": pressed}}
        )
        m.call("input", events=[event])
        advance(n)

    def tap(name: str) -> None:
        control(name, True, 35)
        control(name, False, 35)

    try:
        advance(900)
        for line in text.splitlines():
            reply = m.call("type_string", text=line + "\n", settle_frames=60)
            T.require(
                reply["chars_typed"] == len(line) + 1, "Incomplete keyboard entry"
            )
        before = layout(m)
        T.require(
            [l["number"] for l in before["lines"]]
            == [int(l.split()[0]) for l in text.splitlines()],
            "Native line inventory differs before RUN",
        )
        m.call("type_string", text="RUN\n", settle_frames=60)
        if "boundar" in variant:
            for _ in range(150):
                advance(10)
                raw = read(32768, 105)
                if raw[0] == 165 and raw[-2:] == [90, 239]:
                    break
            T.require(raw[0] == 165 and raw[-2:] == [90, 239], "Incomplete fixture")
            T.require(
                (raw == A.expected_fixture()) == (variant == "boundaries"),
                "Arithmetic/policy oracle mismatch",
            )
            result = {"bytes": raw, "oracle_matches": raw == A.expected_fixture()}
        else:
            advance(30)
            first = observe("initial")
            advance(60)
            idle = observe("untimed-idle")
            T.require(
                first["turn"] == idle["turn"] == 0 and first["clock"] != idle["clock"],
                "Untimed idle",
            )
            control("fire", True, 100)
            control("fire", False, 35)
            action = observe("untimed-action")
            T.require(
                action["turn"] == 1 and not action["active"], "Held action repeated"
            )
            tap("select")
            enabled = observe("enabled")
            advance(30)
            progress = observe("idle-progress")
            T.require(enabled["active"] == progress["active"] == 1, "Timer not enabled")
            if variant == "wrong":
                advance(300)
                expired = observe("wrong-never-expires")
                T.require(
                    expired["turn"] == 1
                    and expired["expiries"] == 0
                    and expired["remaining"] == 240,
                    "No baseline symptom",
                )
            else:
                T.require(
                    0 < progress["remaining"] < enabled["remaining"],
                    "No countdown progress",
                )
                tap("fire")
                restart = observe("action-restarts")
                T.require(
                    restart["turn"] == 2 and restart["active"] == 1, "Restart failed"
                )
                for _ in range(80):
                    advance(5)
                    expired = observe("await-expiry")
                    if expired["expiries"]:
                        break
                T.require(
                    expired["turn"] == 3 and expired["expiries"] == 1,
                    "No automatic turn",
                )
            advance(2)
            cap = A.capture(
                m,
                f"{expired['turn']:02X} {expired['expiries']:02X} {expired['active']:02X}",
            )
            image = F / "verification" / (variant + ".png")
            m.call("save_screenshot", path=str(image))
            memory = layout(m)
            tap("select")
            disabled = observe("disabled")
            advance(250)
            stopped = observe("disabled-idle")
            T.require(
                not stopped["active"] and stopped["turn"] == disabled["turn"],
                "Disable failed",
            )
            tap("option")
            advance(60)
            result = {"samples": samples, "capture": cap}
        if "boundar" in variant:
            memory = layout(m)
        T.require(
            memory["program_bytes"] == before["program_bytes"],
            "Native program changed during execution",
        )
        reply = m.call("type_string", text='PRINT "RETURNED";2+3\n', settle_frames=60)
        advance(60)
        ret = A.screen(m)
        T.require(
            "RETURNED5" in ret["text"].replace(" ", ""), "Return arithmetic failed"
        )
        image = F / "verification" / (variant + ".png")
        if "boundar" in variant:
            m.call("save_screenshot", path=str(image))
        return result | {
            "layout": memory,
            "before": before,
            "source_sha256": hashlib.sha256(text.encode()).hexdigest(),
            "return_screen": ret,
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
    p.add_argument("--firmware", type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    target = F / "verification/results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"machine": "atari-800xl", "language": "basic", "cases": {}}
    )
    for variant in args.variants.split(","):
        T.require(variant in VARIANTS, "Unknown variant")
        r["cases"][variant] = run(args, variant)
        r.update(
            sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
            emulator_sha256=T.sha(args.emulator),
            firmware_sha256={
                n: T.sha(args.firmware / n) for n in ["atarixl.rom", "ataribas.rom"]
            },
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(variant, "passed", flush=True)


if __name__ == "__main__":
    main()
