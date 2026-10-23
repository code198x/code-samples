"""Run original Blitz 2.10 source imports; observe native pixels and guarded state."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "commodore-amiga/patterns/blitz/framework/turn-deadline"
PHASES = FOLDER / "verification/phases"


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = load("transport", ROOT / "scripts/verify-game-loops.py")
C = load("pixels", ROOT / "scripts/check-amiga-command-loops.py")
B = load("builder", FOLDER / "build.py")
DIGITS = {**C.DIGITS, "7": (252, 12, 12, 24, 48, 48, 48, 0)}


def number(path: Path, x: int, y: int, count: int = 8) -> int:
    w, h, c, p = C.png(path)
    T.require((w, h) == (1536, 576), "Wrong native geometry")
    found = ""
    for col in range(count):
        rows = []
        for yy in range(8):
            row = 0
            for xx in range(8):
                at = ((y + yy * 2) * w + x + col * 16 + xx * 2) * c
                if min(p[at : at + 3]) > 180:
                    row |= 128 >> xx
            rows.append(row)
        mask = 0
        for row in rows:
            mask |= row
        if not mask:
            break
        shape = tuple((row << (8 - mask.bit_length())) & 255 for row in rows)
        hits = [digit for digit, glyph in DIGITS.items() if glyph == shape]
        T.require(len(hits) == 1, f"Unknown native digit in {path.name}: {shape}")
        found += hits[0]
    T.require(bool(found), "Missing native number")
    return int(found)


def command(a: argparse.Namespace) -> list[str]:
    return [
        str(a.emulator),
        "--model",
        "a1200",
        "--kickstart",
        str(a.kickstart),
        "--drives",
        "3",
        "--mcp",
    ]


def config() -> dict[str, Any]:
    return json.loads((FOLDER / "verification/configuration.json").read_text())


def fixture(a: argparse.Namespace) -> dict[str, Any]:
    return {
        "disk_sha256": T.sha(a.private / "cases.adf"),
        "builder_sha256": config()["builder_sha256"],
        "program_sha256": {
            v: hashlib.sha256(B.program(v).encode("ascii")).hexdigest()
            for v in B.VARIANTS
        },
    }


def require_fixture(a: argparse.Namespace) -> None:
    T.require(
        json.loads((a.private / "fixture.json").read_text()) == fixture(a),
        "Stale fixture; prepare a fresh private run",
    )


def phase(m: Any, a: argparse.Namespace, name: str) -> None:
    steps = json.loads((PHASES / name).read_text())
    T.require(bool(steps), "Empty phase")
    for original in steps:
        text = json.dumps(original)
        for old, new in {
            "${RUN}": a.private,
            "${BLITZ}": a.blitz,
            "${BLITZ_LIBS}": a.blitz_libs,
        }.items():
            text = text.replace(old, str(new))
        fields = json.loads(text)
        action = fields.pop("action")
        r = m.call(action, **fields)
        if action == "run_frames":
            T.require(
                r["frames"] == fields["frames"] and r["stop_reason"] == "ReachedTarget",
                "Incomplete native phase",
            )
        if action == "type_string":
            T.require(
                r["chars_typed"] == len(fields["text"]), "Incomplete keyboard entry"
            )


def prepare(a: argparse.Namespace) -> None:
    T.require(
        a.builder is not None and T.sha(a.builder) == config()["builder_sha256"],
        "Different fixture builder",
    )
    a.private.mkdir(parents=True, exist_ok=True)
    target = a.private / "cases.adf"
    T.require(
        not target.exists(),
        "Refusing to replace fixture; use a fresh private directory",
    )
    subprocess.run(["make"], cwd=FOLDER, check=True, timeout=30)
    cmd = [str(a.builder), "create", str(target), "--label", "Cases"]
    for v in B.VARIANTS:
        cmd += ["--add", f"{FOLDER}/build/{v}.asc={v}.asc"]
    subprocess.run(cmd, check=True, timeout=30)
    subprocess.run([str(a.builder), "verify", str(target)], check=True, timeout=30)
    (a.private / "fixture.json").write_text(json.dumps(fixture(a), indent=2) + "\n")


def boot(a: argparse.Namespace) -> None:
    require_fixture(a)
    for name in [
        "boot",
        "drawer",
        "pointer",
        "open",
        "ide",
        "ide-later",
        "blank",
        "edit",
        "empty",
        "settled",
    ] + ["insert-requester"]:
        m = T.Machine(command(a))
        try:
            phase(
                m,
                a,
                name + ".json"
                if name == "insert-requester"
                else "blitz-" + name + ".json",
            )
        finally:
            m.close()
        print("Completed native phase", name, flush=True)


def qualify(a: argparse.Namespace, variant: str) -> dict[str, Any]:
    m = T.Machine(command(a))
    out = FOLDER / "verification"
    samples = []
    total = 0
    try:
        m.call("load_snapshot", path=str(a.private / "insert-requester.state"))
        text = "Cases:" + variant + ".asc\n"
        r = m.call("type_string", text=text, hold_frames=2)
        T.require(r["chars_typed"] == len(text), "Incomplete file selection")

        def frames(n: int) -> None:
            nonlocal total
            while n:
                part = min(n, 200)
                r = m.call("run_frames", frames=part)
                T.require(
                    r["frames"] == part and r["stop_reason"] == "ReachedTarget",
                    "Incomplete behaviour window",
                )
                total += part
                n -= part

        def key(name: str, down: bool) -> None:
            m.call("input", events=[{"Key": {"name": name, "pressed": down}}])

        def tap(name: str) -> None:
            key(name, True)
            frames(4)
            key(name, False)
            frames(8)

        frames(300)
        m.call(
            "input",
            events=[{"PointerMotion": {"device": "mouse-1", "dx": 100, "dy": 0}}],
        )
        frames(3)
        key("ramiga", True)
        frames(4)
        key("x", True)
        frames(4)
        key("x", False)
        frames(4)
        key("ramiga", False)
        frames(100)
        first = out / (variant + "-initial.png")
        m.call("save_screenshot", path=str(first))
        base = number(first, 288, 200)
        size = 272 if variant in {"boundaries", "wrong-boundary"} else 40
        T.require(0 < base < 2 * 1024 * 1024 - size, "Bad observed bank address")
        T.require(number(first, 288, 240) == size, "Wrong native bank allocation")
        T.require(
            number(first, 192, 280, 10) == 123456789, "Unexpected native font fixture"
        )
        record = {
            "program_sha256": hashlib.sha256(
                B.program(variant).encode("ascii")
            ).hexdigest(),
            "bank_address": base,
            "bank_length": size,
            "initial_image": first.name,
            "initial_sha256": T.sha(first),
        }
        if size == 272:
            raw = []
            for offset in range(0, size, 256):
                count = min(256, size - offset)
                part = m.call("memory_read", addr=base + offset, len=count)["bytes"]
                T.require(len(part) == count, "Truncated native results chunk")
                raw.extend(part)
            T.require(
                len(raw) == size
                and raw[264:268] == [26, 43, 60, 77]
                and int.from_bytes(bytes(raw[268:272]), "big") == 239,
                "Incomplete arithmetic bank",
            )
            T.require(number(first, 304, 120) == 16, "Missing arithmetic completion")
            record.update(raw=raw)
        else:

            def observe(stage: str) -> dict[str, Any]:
                for _ in range(20):
                    raw = m.call("memory_read", addr=base, len=40)["bytes"]
                    T.require(
                        len(raw) == 40 and raw[32:36] == [26, 43, 60, 77],
                        "Bad observation guard",
                    )
                    if int.from_bytes(bytes(raw[36:40]), "big") == 239:
                        break
                    frames(1)
                T.require(
                    int.from_bytes(bytes(raw[36:40]), "big") == 239,
                    "No completed observation",
                )
                fields = {
                    k: int.from_bytes(bytes(raw[i * 4 : i * 4 + 4]), "big")
                    for i, k in enumerate(
                        [
                            "turn",
                            "expiries",
                            "active",
                            "remaining",
                            "clock",
                            "duration",
                            "elapsed",
                        ]
                    )
                }
                image = out / f"{variant}-{len(samples):02d}-{stage}.png"
                m.call("save_screenshot", path=str(image))
                T.require(
                    number(image, 304, 120) == fields["turn"]
                    and number(image, 304, 160) == fields["active"],
                    "Native pixels disagree with bank",
                )
                s = {
                    "stage": stage,
                    "frames": total,
                    **fields,
                    "bank": raw,
                    "image": image.name,
                    "image_sha256": T.sha(image),
                }
                samples.append(s)
                print(variant, stage, fields, flush=True)
                return s

            observe("initial")
            frames(120)
            observe("idle")
            tap("a")
            observe("action")
            tap("t")
            observe("enabled")
            frames(30)
            observe("progress")
            if variant == "wrong":
                frames(220)
                observe("wrong-no-expiry")
            else:
                tap("a")
                observe("restart")
                for _ in range(35):
                    frames(10)
                    raw = m.call("memory_read", addr=base, len=40)["bytes"]
                    done = int.from_bytes(bytes(raw[36:40]), "big") == 239
                    if done and int.from_bytes(bytes(raw[4:8]), "big") == 1:
                        break
                observe("expiry")
            tap("t")
            observe("disabled")
            frames(250)
            observe("disabled-idle")
            record["samples"] = samples
        tap("q")
        frames(30)
        end = out / (variant + "-quit.png")
        m.call("save_screenshot", path=str(end))
        record.update(quit_image=end.name, quit_sha256=T.sha(end))
        return record
    finally:
        m.close()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    for name in ["emulator", "kickstart", "blitz", "blitz-libs", "private"]:
        p.add_argument("--" + name, type=Path, required=True)
    p.add_argument("--builder", type=Path)
    p.add_argument("--prepare", action="store_true")
    p.add_argument("--boot", action="store_true")
    p.add_argument("--variants")
    a = p.parse_args()
    cfg = config()
    for path, expected in [
        (a.emulator, cfg["emulator_sha256"]),
        (a.kickstart, cfg["firmware_sha256"]),
        (a.blitz, cfg["runtime_media_sha256"]["system"]),
        (a.blitz_libs, cfg["runtime_media_sha256"]["libs"]),
    ]:
        T.require(T.sha(path) == expected, "Different named tool/firmware/runtime")
    if a.prepare:
        prepare(a)
    if a.boot:
        boot(a)
    if a.variants:
        require_fixture(a)
        variants = a.variants.split(",")
        T.require(
            bool(variants) and all(v in B.VARIANTS for v in variants), "Unknown variant"
        )
        path = FOLDER / "verification/results.json"
        record = (
            json.loads(path.read_text())
            if path.exists()
            else {
                "status": "native-checked",
                "machine": "commodore-amiga",
                "language": "blitz",
                "toolchain": cfg,
                "configuration": cfg["configuration"],
                "fixture": fixture(a),
                "cases": {},
            }
        )
        T.require(record["fixture"] == fixture(a), "Changed fixture between cases")
        for variant in variants:
            record["cases"][variant] = qualify(a, variant)
            path.write_text(json.dumps(record, indent=2) + "\n")


if __name__ == "__main__":
    main()
