"""Execute three independent language routes with real firmware/controller input."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


T = module("transport", "verify-game-loops.py")
B = module("build", "build-msx-gameboy-loops.py")


def verify(args) -> None:
    system, track = args.system, args.track
    gb = system == "nintendo-game-boy"
    asm = track == "assembly"
    T.require(not gb or asm, "No stock Game Boy BASIC route supplied")
    folder = ROOT / system / "patterns" / track / "framework/command-loop"
    retained = folder / "verification"
    retained.mkdir(exist_ok=True)
    exe = args.native / ("emu198x-game-boy" if gb else "emu198x-msx")
    lock = json.loads(
        (
            args.native / (exe.name + "-aarch64-apple-darwin-source-lock.json")
        ).read_text()
    )
    alock = json.loads(
        (args.native / "asm198x-aarch64-apple-darwin-source-lock.json").read_text()
    )
    for binary, producer, version in [
        (exe, lock, "0.44.1"),
        (args.assembler, alock, "0.0.71"),
    ]:
        T.require(
            T.sha(binary) == producer["executable_sha256"]
            and producer["version"] == version,
            "Unqualified tool",
        )
        T.require(
            producer["before_lock_sha256"]
            == producer["after_lock_sha256"]
            == producer["committed_lock_sha256"],
            "Changed producer lock",
        )
    variants = [
        v
        for v in B.VARIANTS
        if (asm or v not in ("no-edge", "no-wait")) and (gb or v != "no-wait")
    ]
    if args.variant:
        variants = [args.variant]
    cases = {}
    for variant in variants:
        out = folder / "build" / variant
        out.mkdir(parents=True, exist_ok=True)
        data = b""
        symbols = {}
        lines = []
        if asm:
            out, data, lines = B.build(system, args.assembler, variant)
            symbols = T.symbols(out / "demo.sym")
        else:
            file = {
                "step-three": "customise.bas",
                "wrong-reset": "mistakes/reset-each-command.bas",
            }.get(variant, "reusable.bas")
            source = (folder / file).read_text()
            if variant == "wrap":
                source = source.replace("N=0", "N=254")
            if variant == "nonzero":
                source = source.replace("N=0", "N=100").replace("S=1", "S=255")
            # Diagnostic only: copy actual SCREEN 0 cells, not N, out of VDP RAM.
            source = source.replace(
                "30 INPUT", "25 FOR J=0 TO 959:POKE 53248+J,VPEEK(J):NEXT J\n30 INPUT"
            )
            lines = ["1 CLEAR 200,53247"] + source.splitlines() + ["RUN"]
        command = [str(exe), "--mcp"] + (
            ["--rom", str(out / "demo.gb")]
            if gb
            else ["--bios", str(args.firmware_root / "microsoft-msx/msx.rom")]
        )
        m = T.Machine(command)
        observations = []
        traces = {}

        def ram(addr: int, size: int, m=m) -> list[int]:
            return [
                b
                for offset in range(0, size, 256)
                for b in m.call(
                    "memory_read", addr=addr + offset, len=min(256, size - offset)
                )["bytes"]
            ]

        def enter(text: str, m=m) -> None:
            r = m.call("type_string", text=text + "\n", hold_frames=2, settle_frames=60)
            T.require(r["chars_typed"] == len(text) + 1, "Incomplete keyboard entry")

        def action(pressed: bool, m=m) -> None:
            event = (
                {"Button": {"port": 1, "name": "a", "pressed": pressed}}
                if gb
                else {"Key": {"name": "space", "pressed": pressed}}
            )
            m.call("input", events=[event])

        def observe(
            stage: str,
            m=m,
            ram=ram,
            symbols=symbols,
            variant=variant,
            observations=observations,
        ) -> int:
            raw = ram(
                0xC000 if gb else symbols["turn_count"] if asm else 0xD000,
                4 if gb else 1 if asm else 960,
            )
            if asm:
                count = raw[0]
            else:
                matches = re.findall(
                    r"TURN\s*(\d+)", "".join(chr(c & 127) for c in raw), re.IGNORECASE
                )
                T.require(len(matches) == 1, "Missing rendered BASIC count")
                count = int(matches[0])
            path = retained / variant / (stage + ".png")
            path.parent.mkdir(exist_ok=True)
            m.call("save_screenshot", path=str(path))
            observations.append(
                {
                    "stage": stage,
                    "count": count,
                    "memory": raw,
                    "ticks": raw[2] + 256 * raw[3] if gb else None,
                    "capture": str(path.relative_to(ROOT)),
                    "capture_sha256": T.sha(path),
                }
            )
            return count

        try:
            m.call("run_frames", frames=300)
            for line in lines:
                enter(line)
            # READ/POKE and the diagnostic VPEEK loop must actually finish.
            m.call("run_frames", frames=600)
            loaded = ram(0, len(data)) if gb else ram(0xC000, len(data)) if asm else []
            if asm:
                T.require(
                    bytes(loaded) == data, "Loaded payload differs from assembled bytes"
                )
            if asm and not gb:
                enter("SCREEN 0:WIDTH 40:CLS:A=USR(0)")
                m.call("run_frames", frames=30)
            observe("initial")
            m.call("run_frames", frames=120)
            observe("idle")
            if asm:
                action(True)
                if not gb:
                    traces["first"] = m.call("io_trace", frames=1, limit=4096)
                    m.call("run_frames", frames=29)
                else:
                    m.call("run_frames", frames=30)
                observe("first")
                m.call("run_frames", frames=120)
                observe("held")
                action(False)
                m.call("run_frames", frames=10)
                if not gb:
                    enter("0")
                m.call("run_frames", frames=20)
                observe("ignored")
                action(True)
                if not gb:
                    traces["second"] = m.call("io_trace", frames=1, limit=4096)
                    m.call("run_frames", frames=29)
                else:
                    m.call("run_frames", frames=30)
                action(False)
                m.call("run_frames", frames=10)
                observe("second")
            else:
                enter("GO")
                m.call("run_frames", frames=600)
                observe("first")
                m.call("run_frames", frames=120)
                observe("held")
                enter("NO")
                m.call("run_frames", frames=600)
                observe("ignored")
                enter("GO")
                m.call("run_frames", frames=600)
                observe("second")
            returned = None
            if asm and not gb:
                m.call("input", events=[{"Key": {"name": "escape", "pressed": True}}])
                m.call("run_frames", frames=10)
                m.call("input", events=[{"Key": {"name": "escape", "pressed": False}}])
                m.call("run_frames", frames=10)
                enter('PRINT "RETURNED";2+3')
                enter("FOR J=0 TO 959:POKE 53248+J,VPEEK(J):NEXT J")
                m.call("run_frames", frames=600)
                returned = ram(0xD000, 960)
                T.require(
                    re.search(
                        r"RETURNED\s*5",
                        "".join(chr(c & 127) for c in returned),
                        re.IGNORECASE,
                    )
                    is not None,
                    "No working BASIC arithmetic after USR",
                )
            initial = 254 if variant == "wrap" else 100 if variant == "nonzero" else 0
            step = 3 if variant == "step-three" else 255 if variant == "nonzero" else 1
            expected = [
                initial,
                initial,
                (initial + step) % 256,
                (initial + step) % 256,
                (initial + step) % 256,
                (initial + 2 * step) % 256,
            ]
            if variant == "wrong-reset":
                expected = [0] * 6
            counts = [o["count"] for o in observations]
            if variant == "no-edge":
                T.require(
                    counts != [0, 0, 1, 1, 1, 2], "No-edge passed normal press guard"
                )
            else:
                T.require(
                    counts == expected,
                    f"{system}/{track}/{variant}: {counts} != {expected}",
                )
            if gb:
                delta = (observations[1]["ticks"] - observations[0]["ticks"]) % 65536
                T.require(
                    not 118 <= delta <= 122
                    if variant == "no-wait"
                    else 118 <= delta <= 122,
                    "Wait/service control disagrees with native fields",
                )
            for stage, trace in traces.items():
                (out / (stage + "-io-trace.json")).write_text(
                    json.dumps(trace, indent=2) + "\n"
                )
            traces = {
                stage: {
                    "sample_limit": 4096,
                    "frames": 1,
                    "filter": "VDP writes from the bounded native I/O trace",
                    "events": [
                        e
                        for e in trace["events"]
                        if e["dir"] == "out" and e["port"] in ("$0098", "$0099")
                    ],
                }
                for stage, trace in traces.items()
            }
            cases[variant] = {
                "observations": observations,
                "entered_source": "\n".join(lines),
                "loaded_bytes": loaded,
                "loaded_sha256": __import__("hashlib")
                .sha256(bytes(loaded))
                .hexdigest(),
                "returned_screen": returned,
                "io_traces": traces,
            }
            print("PASS", system, track, variant, counts, flush=True)
            server = m.server["serverInfo"]
        except Exception:
            m.call("save_screenshot", path=str(out / "failure.png"))
            raise
        finally:
            m.close()
    paths = [
        p
        for p in folder.rglob("*")
        if p.suffix in (".bas", ".asm", ".inc")
        and "build" not in p.relative_to(folder).parts
        and p.name != "demo.bas"
    ]
    record = {
        "status": "partial" if args.variant else "passed",
        "system": system,
        "track": track,
        "server": server,
        "producer_source_lock": lock,
        "assembler_source_lock": alock,
        "firmware_sha256": {}
        if gb
        else {"msx.rom": T.sha(args.firmware_root / "microsoft-msx/msx.rom")},
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in paths},
        "observer_sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [
                Path(__file__),
                ROOT / "scripts/build-msx-gameboy-loops.py",
                ROOT / "scripts/verify-game-loops.py",
            ]
        },
        "cases": cases,
        "configuration": "DMG reset, 32 KiB ROM-only cartridge, no boot ROM"
        if gb
        else "MSX1 NTSC, stock BIOS/BASIC, SCREEN 0 width 40, keyboard-entered BASIC/USR loader",
        "limits": "Separate machine/language observations, not full I/O/audio, cassette, original-hardware or whole-emulator qualification. BASIC uses an observer-only VPEEK name-table copy. MSX assembly uses BIOS services and returns; DMG owns LCD/JOYP/stack with interrupts disabled.",
    }
    (
        retained / ("smoke-results.json" if args.variant else "reusable-results.json")
    ).write_text(json.dumps(record, indent=2) + "\n")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--system", choices=["msx", "nintendo-game-boy"], required=True)
    p.add_argument("--track", choices=["basic", "assembly"], required=True)
    p.add_argument("--variant", choices=B.VARIANTS)
    p.add_argument("--firmware-root", type=Path, default=Path.home() / ".emu198x/roms")
    a = p.parse_args()
    a.native = a.native.resolve()
    a.assembler = a.assembler.resolve()
    verify(a)


if __name__ == "__main__":
    main()
