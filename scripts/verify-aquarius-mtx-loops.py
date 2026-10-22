"""Execute separate BASIC and Z80 loops through each machine's real firmware."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = module("transport", "verify-game-loops.py")
B = module("build", "build-aquarius-mtx-loops.py")


def verify(args, system: str, track: str) -> None:
    aq = system == "mattel-aquarius"
    asm = track == "assembly"
    folder = ROOT / system / "patterns" / track / "framework/command-loop"
    retained = folder / "verification"
    retained.mkdir(exist_ok=True)
    exe = args.native / ("emu198x-" + system)
    lock = json.loads(
        (
            args.native / f"emu198x-{system}-aarch64-apple-darwin-source-lock.json"
        ).read_text()
    )
    alock = json.loads(
        (args.native / "asm198x-aarch64-apple-darwin-source-lock.json").read_text()
    )
    for executable, producer, version in [
        (exe, lock, "0.44.1"),
        (args.assembler, alock, "0.0.71"),
    ]:
        T.require(
            T.sha(executable) == producer["executable_sha256"]
            and producer["version"] == version,
            "Wrong executable/producer",
        )
        T.require(
            producer["before_lock_sha256"]
            == producer["after_lock_sha256"]
            == producer["committed_lock_sha256"],
            "Changed producer lock",
        )
    rom = args.firmware_root / system
    command = [str(exe), "--mcp"] + (
        ["--rom-dir", str(rom)] if aq else ["--rom", str(rom / "mtx.rom")]
    )
    variants = list(B.VARIANTS) if asm else [v for v in B.VARIANTS if v != "no-edge"]
    cases = {}
    for variant in variants:
        out = folder / "build" / variant
        out.mkdir(parents=True, exist_ok=True)
        data = None
        lines = []
        program = None
        reader = None
        if asm:
            out, data, lines = B.build(system, args.assembler, variant)
        else:
            name = {
                "working": "reusable.bas",
                "step-three": "customise.bas",
                "wrong-reset": "mistakes/reset-each-command.bas",
                "repaired": "reusable.bas",
            }.get(variant, "reusable.bas")
            program = (folder / name).read_text()
            if variant == "wrap":
                program = program.replace("N=0", "N=254")
            if variant == "nonzero":
                program = program.replace("N=0", "N=100").replace("S=1", "S=255")
            if not aq:
                binary = out / "read-screen.bin"
                binary.unlink(missing_ok=True)
                subprocess.run(
                    [
                        str(args.assembler),
                        "--dialect",
                        "pasmo",
                        str(retained / "read-screen.asm"),
                        "-o",
                        str(binary),
                    ],
                    check=True,
                    timeout=30,
                )
                reader = binary.read_bytes()
                T.require(len(reader) == 44, "Changed reader shape")
                lines = [
                    f"1 FOR J=57344 TO {57343 + len(reader)}",
                    "2 READ B:POKE J,B:NEXT J",
                    "3 GOTO 10",
                ]
                program = program.replace("30 INPUT", "25 LET V=USR(57344)\n30 INPUT")
            lines += program.splitlines()
            if reader:
                lines += [
                    f"{3000 + i} DATA " + ",".join(map(str, reader[i : i + 12]))
                    for i in range(0, len(reader), 12)
                ]
            lines += ["RUN"]
        m = T.Machine(command)
        observations = []

        def enter(text: str, m=m) -> None:
            if aq:
                reply = m.call(
                    "type_string", text=text, hold_frames=2, settle_frames=60
                )
                T.require(
                    reply["chars_typed"] == len(text), "Incomplete keyboard input"
                )
                return
            legends = {
                "=": "-",
                '"': "2",
                "#": "3",
                "(": "8",
                ")": "9",
                "+": ";",
                "<": ",",
                ">": ".",
            }
            for char in text:
                if char in legends:
                    for key, down in [
                        ("shift", True),
                        (legends[char], True),
                        (legends[char], False),
                        ("shift", False),
                    ]:
                        m.call(
                            "input", events=[{"Key": {"name": key, "pressed": down}}]
                        )
                        m.call("run_frames", frames=5)
                else:
                    reply = m.call(
                        "type_string", text=char, hold_frames=3, settle_frames=6
                    )
                    T.require(
                        reply["chars_typed"] == 1, "Incomplete MTX keyboard input"
                    )
                if char == "\n":
                    m.call("run_frames", frames=60)

        def ram(addr: int, size: int, m=m) -> list[int]:
            return m.call("memory_read", addr=addr, len=size)["bytes"]

        def observe(
            stage: str, m=m, ram=ram, observations=observations, variant=variant
        ) -> int:
            raw = []
            if aq or not asm:
                base, size = (0x3000, 1000) if aq else (0xD000, 960)
                for offset in range(0, size, 256):
                    raw += ram(base + offset, min(256, size - offset))
                text = "".join(
                    chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw
                )
                matches = re.findall(
                    r"TURN\s+\$([0-9A-F]{2})" if asm else r"TURN\s*(\d+)",
                    text,
                    re.IGNORECASE,
                )
                T.require(
                    len(matches) == 1, f"Missing/unexpected rendered counter: {text}"
                )
                count = int(matches[0], 16 if asm else 10)
                ticks = None
            else:
                raw = ram(0xDF00, 4)
                count = raw[0]
                ticks = raw[2] + 256 * raw[3]
            path = retained / variant
            path.mkdir(exist_ok=True)
            image = path / (stage + ".png")
            m.call("save_screenshot", path=str(image))
            observations.append(
                {
                    "stage": stage,
                    "count": count,
                    "memory": raw,
                    "ticks": ticks,
                    "capture": str(image.relative_to(ROOT)),
                    "capture_sha256": T.sha(image),
                }
            )
            return count

        try:
            m.call("run_frames", frames=300)
            if aq:
                enter("\n")
            for line in lines:
                enter(line + "\n")
            m.call("run_frames", frames=120)
            if data:
                base = 0x3E00 if aq else 0xE000
                actual = bytes(ram(base, len(data)))
                T.require(
                    actual == data, "Loader did not install exact assembled bytes"
                )
                enter(("PRINT CHR$(11):X=USR(0)" if aq else "LET X=USR(57344)") + "\n")
                m.call("run_frames", frames=30)
            if reader:
                T.require(
                    bytes(ram(0xE000, len(reader))) == reader,
                    "Verification-only reader loader mismatch",
                )
            observe("initial")
            m.call("run_frames", frames=120)
            observe("idle")
            if asm:
                key = "1" if aq else "space"
                m.call("input", events=[{"Key": {"name": key, "pressed": True}}])
                m.call("run_frames", frames=30)
                observe("first")
                m.call("run_frames", frames=120)
                observe("held")
                m.call("input", events=[{"Key": {"name": key, "pressed": False}}])
                m.call("run_frames", frames=10)
                enter("0")
                m.call("run_frames", frames=20)
                observe("ignored")
                m.call("input", events=[{"Key": {"name": key, "pressed": True}}])
                m.call("run_frames", frames=30)
                m.call("input", events=[{"Key": {"name": key, "pressed": False}}])
                m.call("run_frames", frames=10)
                observe("second")
                returned = None
                if aq:
                    enter("Q")
                    enter('PRINT "RETURNED";2+3\n')
                    raw = []
                    for offset in range(0, 1000, 250):
                        raw += ram(0x3000 + offset, 250)
                    text = "".join(chr(c & 127) for c in raw)
                    T.require(
                        re.search(r"RETURNED\s*5", text, re.IGNORECASE) is not None,
                        "USR did not return to working BASIC",
                    )
                    returned = raw
            else:
                enter("GO\n" if aq else "1\n")
                observe("first")
                m.call("run_frames", frames=120)
                observe("held")
                enter("NO\n" if aq else "0\n")
                observe("ignored")
                enter("GO\n" if aq else "1\n")
                observe("second")
                returned = None
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
                    counts != [0, 0, 1, 1, 1, 2],
                    "Disabled edge detection passed normal guard",
                )
            else:
                T.require(
                    counts == expected,
                    f"{system}/{track}/{variant}: {counts} != {expected}",
                )
            if asm and not aq:
                ticks = [o["ticks"] for o in observations]
                delta = (ticks[1] - ticks[0]) % 65536
                T.require(
                    118 <= delta <= 122,
                    f"Display service not one tick per frame: {delta}",
                )
            cases[variant] = {
                "observations": observations,
                "entered_source": "\n".join(lines),
                "loaded_bytes": list(data or reader or b""),
                "loaded_sha256": __import__("hashlib")
                .sha256(data or reader or b"")
                .hexdigest(),
                "returned_screen": returned,
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
        "status": "passed",
        "system": system,
        "track": track,
        "server": server,
        "emulator_release": "v0.44.1",
        "producer_source_lock": lock,
        "assembler_source_lock": alock,
        "firmware_sha256": {p.name: T.sha(p) for p in sorted(rom.glob("*.rom"))},
        "sources": {str(p.relative_to(ROOT)): T.sha(p) for p in paths},
        "observer_sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [
                Path(__file__),
                ROOT / "scripts/build-aquarius-mtx-loops.py",
                ROOT / "scripts/verify-game-loops.py",
            ]
        },
        "cases": cases,
        "configuration": "Unexpanded Aquarius, stock S2 BASIC and character ROM; or MTX500 PAL stock OS/BASIC; keyboard-loaded callers, no cassette claim",
        "limits": "BASIC submitted commands differ from assembly press edges. MTX assembly takes over until reset. MTX BASIC only: verification reader copies actual VS5 name-table bytes to $D000 and does not supply rule state. No whole-emulator or original-hardware claim.",
    }
    (retained / "reusable-results.json").write_text(json.dumps(record, indent=2) + "\n")


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", required=True, type=Path)
    p.add_argument("--assembler", required=True, type=Path)
    p.add_argument(
        "--system", choices=["mattel-aquarius", "memotech-mtx"], required=True
    )
    p.add_argument("--track", choices=["basic", "assembly"], required=True)
    p.add_argument("--firmware-root", type=Path, default=Path.home() / ".emu198x/roms")
    a = p.parse_args()
    a.native = a.native.resolve()
    a.assembler = a.assembler.resolve()
    verify(a, a.system, a.track)


if __name__ == "__main__":
    main()
