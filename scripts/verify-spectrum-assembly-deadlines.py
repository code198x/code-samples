"""ROM-tape-load Spectrum countdowns and check actual bytes, keys and pixels."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from collections.abc import Callable
from functools import reduce
from operator import xor
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


T = module("transport", "verify-game-loops.py")
A = module("fixture", "verify-msx-assembly-deadlines.py")
F = ROOT / "sinclair-zx-spectrum/patterns/assembly/framework/turn-deadline"
VARIANTS = (
    "working",
    "custom",
    "wrong",
    "repaired",
    "boundaries",
    "wrong-boundary",
    "no-entry",
)


def source_paths() -> list[Path]:
    return (
        [
            F / n
            for n in (
                "demo.asm",
                "customise.asm",
                "caller.inc",
                "clock.inc",
                "input.inc",
                "dispatch.inc",
                "wrong-baseline.asm",
                "mistakes/reset-baseline.inc",
                "no-entry.asm",
                "Makefile",
            )
        ]
        + [
            ROOT / "cross-platform/patterns/framework/elapsed-deadline/z80.inc",
            ROOT / "msx/patterns/assembly/framework/turn-deadline/dispatch.inc",
            Path(__file__),
        ]
        + [
            ROOT / "scripts" / p
            for p in (
                "verify-msx-assembly-deadlines.py",
                "verify-dragon-basic-deadlines.py",
                "verify-basic-deadlines.py",
                "verify-game-loops.py",
            )
        ]
    )


def expected_fixture() -> list[int]:
    return A.expected_fixture()


def fixture(wrong: bool = False) -> str:
    # The independent existing second caller uses the identical dispatcher.
    T.require(
        (F / "dispatch.inc").read_bytes() == (A.F / "dispatch.inc").read_bytes(),
        "Dispatcher reuse changed",
    )
    return A.fixture(wrong).replace("org $C000", "org $8000") + "    end start\n"


def blocks(path: Path, expected: int = 4) -> list[bytes]:
    data = path.read_bytes()
    offset = 0
    result = []
    while offset < len(data):
        length = int.from_bytes(data[offset : offset + 2], "little")
        block = data[offset + 2 : offset + 2 + length]
        T.require(
            length >= 2 and len(block) == length and reduce(xor, block, 0) == 0,
            "Invalid TAP block",
        )
        result.append(block)
        offset += length + 2
    T.require(
        offset == len(data) and len(result) == expected, "Unexpected TAP block count"
    )
    return result


def build(assembler: Path, variant: str) -> tuple[Path, list[int], list[int]]:
    out = F / "build" / variant
    out.mkdir(parents=True, exist_ok=True)
    src = (
        fixture(variant == "wrong-boundary")
        if "boundar" in variant
        else (
            F
            / {
                "custom": "customise.asm",
                "wrong": "wrong-baseline.asm",
                "no-entry": "no-entry.asm",
            }.get(variant, "demo.asm")
        ).read_text()
    )
    (out / "demo.asm").write_text(src)
    subprocess.run(
        [
            str(assembler),
            "--dialect",
            "pasmo",
            "--cpu",
            "z80",
            "-I",
            str(F),
            "--tapbas",
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.tap"),
        ],
        check=True,
        timeout=30,
        capture_output=True,
    )
    b = blocks(out / "demo.tap")
    payload = list(b[3][1:-1])
    loader = list(b[1][1:-1])
    T.require(len(payload) < 700, "Payload reservation")
    T.require(
        (b"\xf9\xc0" in bytes(loader)) == (variant != "no-entry"),
        "Unexpected RANDOMIZE USR loader entry",
    )
    return out, payload, loader


def pixels(m: Any, row: int, expected: str) -> dict[str, Any]:
    chars = m.call("memory_read", addr=23606, len=2)["bytes"]
    base = int.from_bytes(bytes(chars), "little")
    glyphs = {
        str(ord(c)): m.call("memory_read", addr=base + ord(c) * 8, len=8)["bytes"]
        for c in set(expected)
    }
    native = [
        m.call("memory_read", addr=0x4000 + row * 32 + 256 * y, len=len(expected))[
            "bytes"
        ]
        for y in range(8)
    ]
    oracle = [[glyphs[str(ord(c))][y] for c in expected] for y in range(8)]
    T.require(native == oracle, "Native pixels differ from rendered state")
    return {
        "row": row,
        "text": expected,
        "font_base": base,
        "glyphs": glyphs,
        "scanlines": native,
    }


def returned(m: Any, advance: Callable[[int], None]) -> list[int]:
    def press(*keys: str) -> None:
        m.call(
            "press_key" if len(keys) == 1 else "press_keys",
            **({"key": keys[0]} if len(keys) == 1 else {"keys": list(keys)}),
            hold_frames=3,
        )
        advance(8)

    press("p")
    for c in '"RETURNED";2+3':
        if c in {'"', ";", "+"}:
            press("symbol", {'"': "p", ";": "o", "+": "k"}[c])
        elif c.isupper():
            press("caps", c.lower())
        else:
            press(c)
    press("enter")
    advance(60)
    lines = m.call("query", path="screen.text.lines")["result"]["value"]
    T.require(
        re.search(r"RETURNED\s*5", "".join(lines)) is not None,
        "No interpreter arithmetic after return",
    )
    return list("".join(lines).encode("ascii"))


def run(args: argparse.Namespace, variant: str) -> dict[str, Any]:
    out, data, loader = build(args.assembler, variant)
    sym = T.symbols(out / "demo.sym")
    m = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.rom)])
    frames = 0
    samples = []

    def advance(n: int) -> None:
        nonlocal frames
        for i in range(0, n, 200):
            count = min(200, n - i)
            m.call("run_frames", frames=count)
            frames += count

    def read(addr: int, n: int) -> list[int]:
        return m.call("memory_read", addr=addr, len=n)["bytes"]

    def observe(stage: str) -> dict[str, Any]:
        raw = read(sym["TURN"], 14)
        s = {
            "stage": stage,
            "frames": frames,
            "raw": raw,
            "turn": raw[0],
            "expiries": raw[1],
            "active": raw[8],
            "remaining": int.from_bytes(bytes(raw[6:8]), "little"),
            "clock": int.from_bytes(bytes(raw[12:14]), "little"),
        }
        samples.append(s)
        print(variant, stage, s, flush=True)
        return s

    def key(name: str, pressed: bool, n: int = 8) -> None:
        m.call("input", events=[{"Key": {"name": name, "pressed": pressed}}])
        advance(n)

    def tap(name: str) -> None:
        key(name, True)
        key(name, False)

    try:
        m.call("load_media", slot="tape-1", kind="tape", path=str(out / "demo.tap"))
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        startup = []
        if variant != "no-entry":
            for _ in range(20):
                stop = m.call("run_until_pc", addr=0x8000, max_steps=1000000)
                startup.append(stop)
                if stop["reached"]:
                    break
            T.require(
                stop["reached"], "USR entry was not reached within bounded execution"
            )
            loaded = [
                byte
                for i in range(0, len(data), 128)
                for byte in read(0x8000 + i, min(128, len(data) - i))
            ]
        else:
            for _ in range(40):
                advance(100)
                loaded = [
                    byte
                    for i in range(0, len(data), 128)
                    for byte in read(0x8000 + i, min(128, len(data) - i))
                ]
                if loaded == data:
                    break
        T.require(
            loaded == data, "ROM-loaded CODE bytes differ before the first instruction"
        )
        if variant == "no-entry":
            advance(60)
            text = m.call("query", path="screen.text.lines")["result"]["value"]
            ready = read(sym["READY"], 2)
            T.require(
                ready == [0, 0] and any("0 OK, 30:1" in line for line in text),
                "Missing-entry negative control did not reproduce",
            )
            result = {"ready": ready, "screen": text}
        elif "boundar" in variant:
            for _ in range(100):
                advance(2)
                raw = read(sym["output"], len(expected_fixture()))
                if raw[0] == 165 and raw[-2:] == [90, 239]:
                    break
            T.require(raw[0] == 165 and raw[-2:] == [90, 239], "Fixture incomplete")
            T.require(
                (raw == expected_fixture()) == (variant == "boundaries"),
                "Unsigned oracle mismatch",
            )
            result = {
                "bytes": raw,
                "oracle_matches": raw == expected_fixture(),
                "return_screen": returned(m, advance),
            }
        else:
            for _ in range(60):
                advance(1)
                if read(sym["READY"], 2) == [254, 202]:
                    break
            T.require(
                read(sym["READY"], 2) == [254, 202], "USR did not reach ready marker"
            )
            first = observe("initial")
            advance(60)
            idle = observe("untimed-idle")
            T.require(
                first["turn"] == idle["turn"] == 0 and first["clock"] != idle["clock"],
                "Untimed idle/clock",
            )
            key("1", True, 60)
            key("1", False, 8)
            action = observe("untimed-action")
            T.require(
                action["turn"] == 1 and not action["active"],
                "Held untimed action repeated or enabled time",
            )
            tap("2")
            enabled = observe("enabled")
            advance(30)
            progress = observe("idle-progress")
            T.require(enabled["active"] == progress["active"] == 1, "No timer")
            if variant == "wrong":
                advance(300)
                expired = observe("wrong-never-expires")
                T.require(
                    expired["turn"] == 1
                    and expired["expiries"] == 0
                    and expired["remaining"] == 200,
                    "No baseline fault",
                )
            else:
                T.require(
                    0 < progress["remaining"] < enabled["remaining"], "No countdown"
                )
                tap("1")
                restart = observe("action-restarts")
                T.require(
                    restart["turn"] == 2
                    and restart["remaining"] > progress["remaining"],
                    "No restart",
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
            render = pixels(
                m,
                0,
                f"{expired['turn']:02X} {expired['expiries']:02X} {expired['active']:02X}",
            )
            image = F / "verification" / (variant + ".png")
            m.call("save_screenshot", path=str(image))
            tap("2")
            disabled = observe("disabled")
            advance(250)
            stopped = observe("disabled-idle")
            T.require(
                not stopped["active"] and stopped["turn"] == disabled["turn"],
                "Disable failed",
            )
            key("q", True)
            key("q", False, 60)
            result = {
                "samples": samples,
                "pixels": render,
                "return_screen": returned(m, advance),
            }
        image = F / "verification" / (variant + ".png")
        if variant == "no-entry" or "boundar" in variant:
            m.call("save_screenshot", path=str(image))
        return result | {
            "startup": startup,
            "loaded_bytes": loaded,
            "loaded_sha256": hashlib.sha256(bytes(data)).hexdigest(),
            "entered_source_sha256": T.sha(out / "demo.asm"),
            "loader_bytes": loader,
            "tap_sha256": T.sha(out / "demo.tap"),
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
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--emulator", type=Path, required=True)
    p.add_argument("--rom", type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    args = p.parse_args()
    out = F / "verification"
    out.mkdir(parents=True, exist_ok=True)
    target = out / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"machine": "sinclair-zx-spectrum", "language": "assembly", "cases": {}}
    )
    for v in args.variants.split(","):
        T.require(v in VARIANTS, "Unknown variant")
        r["cases"][v] = run(args, v)
        r.update(
            sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
            emulator_sha256=T.sha(args.emulator),
            assembler_sha256=T.sha(args.assembler),
            firmware_sha256={args.rom.name: T.sha(args.rom)},
        )
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(v, "passed", flush=True)


if __name__ == "__main__":
    main()
