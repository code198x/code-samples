"""Execute four CPU-native pool ports using stock BASIC keyboard loaders."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/framework/additional-object-pools"


def module(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(str(path))
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


T = module("pool_transport", ROOT / "scripts/verify-game-loops.py")
B = module("pool_build", SHARED / "build.py")
O = module("pool_oracle", SHARED / "oracle.py")
CONFIG = json.loads((SHARED / "machines.json").read_text())


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def folder(system: str) -> Path:
    return ROOT / system / "patterns/assembly/framework/object-pool"


def sources(system: str) -> list[Path]:
    f = folder(system)
    return (
        sorted(f.glob("*.asm"))
        + sorted(f.glob("*.inc"))
        + [
            f / "Makefile",
            f / "build.py",
            *sorted(SHARED.glob("*.py")),
            *sorted(SHARED.glob("*.json")),
            *sorted(SHARED.glob("*.inc")),
            Path(__file__),
            ROOT / "scripts/check-additional-object-pools.py",
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-atari-xl-assembly-deadlines.py",
            ROOT / "scripts/verify-dragon-basic-deadlines.py",
            ROOT / "scripts/verify-basic-deadlines.py",
            ROOT / "scripts/check-amiga-command-loops.py",
        ]
    )


def execute(
    system: str, variant: str, tools: Path, assembler: Path, draft: bool = False
) -> dict:
    f = folder(system)
    c = CONFIG[system]
    subprocess.run(
        ["python3", "build.py", variant],
        cwd=f,
        env=os.environ | {"ASM198X": str(assembler)},
        check=True,
        timeout=60,
    )
    data = (f / "build" / (variant + ".bin")).read_bytes()
    sym = B.symbols(f / "build" / (variant + ".sym"))
    lines = B.listing(system, data, c)
    rom = Path.home() / ".emu198x/roms"
    if system == "bbc-micro":
        exe = next((tools / "6").rglob("emu198x-acorn-bbc-micro"))
        firmware = [
            rom / "acorn-bbc-micro" / n for n in ["os.rom", "basic.rom", "saa5050.rom"]
        ]
        command = [
            str(exe),
            "--mcp",
            "--mos",
            str(firmware[0]),
            "--rom",
            "acorn-bbc-basic=" + str(firmware[1]),
        ]
    elif system == "dragon-32":
        exe = next((tools / "8").rglob("emu198x-dragon"))
        firmware = [rom / "dragon/dragon32.rom"]
        command = [str(exe), "--mcp", "--rom", str(firmware[0])]
    else:
        ident = "amstrad-cpc" if system == "amstrad-cpc" else "atari-800xl"
        exe = next(
            (tools / ("7" if system == "amstrad-cpc" else "9")).rglob(
                "emu198x-" + ident
            )
        )
        firmware = sorted((rom / ident).glob("*.rom"))
        command = [str(exe), "--mcp", "--rom-dir", str(rom / ident)]
    if not firmware or any(not p.is_file() for p in firmware):
        raise RuntimeError("Required configured firmware is unavailable")
    out = f / ("build/draft" if draft else "verification")
    out.mkdir(parents=True, exist_ok=True)
    m = T.Machine(command)
    frames = 0
    transcript = []

    def advance(count: int) -> None:
        nonlocal frames
        for i in range(0, count, 100):
            n = min(100, count - i)
            m.call("run_frames", frames=n)
            frames += n

    def read(addr: int, count: int) -> list[int]:
        return [
            v
            for off in range(0, count, 128)
            for v in m.call("memory_read", addr=addr + off, len=min(128, count - off))[
                "bytes"
            ]
        ]

    def typed(text: str, settle: int = 8) -> None:
        r = m.call(
            "type_string",
            text=text + "\n",
            hold_frames=2,
            settle_frames=max(settle, 60) if system == "dragon-32" else settle,
        )
        T.require(r["chars_typed"] == len(text) + 1, "Incomplete keyboard input")
        transcript.append({"text": text, "chars_typed": r["chars_typed"]})

    try:
        T.require(
            m.server["serverInfo"]["version"] == "0.44.2",
            "Unexpected actual emulator version",
        )
        advance(900 if system == "atari-800xl" else 150)
        for line in lines[:-2]:
            typed(line)
        if system == "dragon-32":
            D = module(
                "dragon_lines", ROOT / "scripts/verify-dragon-basic-deadlines.py"
            )
            layout = D.memory_layout(m, system)
            wanted_lines = sorted(
                int(line.split()[0]) for line in lines[:-2] if line[0].isdigit()
            )
            T.require(
                [line["number"] for line in layout["lines"]] == wanted_lines,
                "Native Dragon stored-line inventory differs from entered loader",
            )
        typed("RUN", 120)
        for _ in range(100):
            loaded = read(c["origin"], len(data))
            if bytes(loaded) == data:
                break
            advance(10)
        T.require(
            bytes(loaded) == data,
            "Keyboard loader did not install exact assembled bytes",
        )
        advance(10)
        reservation = {}
        if system == "atari-800xl":
            A = module(
                "atari_screen", ROOT / "scripts/verify-atari-xl-assembly-deadlines.py"
            )
            for _ in range(100):
                s = A.screen(m)
                rows = [
                    s["text"][i : i + 40].strip()
                    for i in range(0, 960, 40)
                    if s["text"][i : i + 40].strip()
                ]
                if rows and rows[-1] == "READY":
                    break
                advance(2)
            T.require(
                rows and rows[-1] == "READY", "Loader did not return to Atari editor"
            )
            reservation = {
                "ramtop": read(106, 1),
                "memtop": read(741, 2),
                "savmsc": read(88, 2),
            }
            T.require(
                reservation["ramtop"] == [124]
                and int.from_bytes(bytes(reservation["memtop"]), "little") < 31744
                and int.from_bytes(bytes(reservation["savmsc"]), "little") < 31744,
                "Atari reservation failed",
            )
        elif system == "bbc-micro":
            T.require(
                ">" in "".join(chr(b & 127) for b in read(0x7C00, 1000)),
                "Loader did not return BBC prompt",
            )
        ready = sym["ready"]
        end = sym["end_ptr"]
        v = c["vars"]
        aa = sym["check_a"]
        bb = sym["check_b"]
        if system == "bbc-micro":
            typed(f"?{ready}=0:?{end}=0:?{end + 1}=0:CALL {c['origin']}", 30)
        else:
            typed(f"POKE {ready},0:POKE {end},0:POKE {end + 1},0:" + lines[-1], 30)
        for _ in range(100):
            advance(10)
            if read(ready, 1) == [239]:
                break
        T.require(read(ready, 1) == [239], "Native routine did not complete")
        expected = O.packet(variant)
        T.require(
            c["output"] + len(expected) <= c["packet_limit"],
            "State packet overlaps reservation",
        )
        packet = read(c["output"], len(expected))
        T.require(
            packet == expected,
            "Native packet mismatch at "
            + str(
                next(
                    (i for i, (a, b) in enumerate(zip(packet, expected)) if a != b),
                    None,
                )
            ),
        )
        pointer = read(end, 2)
        T.require(
            int.from_bytes(bytes(pointer), "big" if c["cpu"] == "6809" else "little")
            == c["output"] + len(expected),
            "Wrong actual emitted extent",
        )
        T.require(
            bytes(read(c["origin"], len(data))) == data,
            "Native caller modified executable code",
        )
        advance(4)
        if system == "bbc-micro":
            typed(f"Z=6*7:?{v + 30}=Z", 20)
        else:
            typed(
                f"Z=6*7:POKE {v + 30},Z"
                + (f":POKE {v + 31},X" if system == "atari-800xl" else ""),
                20,
            )
        T.require(
            read(v + 30, 1) == [42], "Stock BASIC arithmetic failed after native return"
        )
        if system == "atari-800xl":
            T.require(read(v + 31, 1) == [0], "USR did not return numeric zero")
        if system == "bbc-micro":
            typed(f'A=?{aa}:B=?{bb}:CLS:PRINT"POOL";CHR$(48+A);CHR$(48+B);"  "', 20)
        elif system == "dragon-32":
            typed("RUN 30", 60)
            for _ in range(100):
                if read(v + 32, 1) == [42]:
                    break
                advance(5)
            T.require(read(v + 32, 1) == [42], "Dragon marker program did not complete")
        else:
            typed(f"A=PEEK({aa}):B=PEEK({bb})", 10)
            base = 240 if system == "amstrad-cpc" else 48
            clear = "? CHR$(125)" if system == "atari-800xl" else "CLS"
            typed(clear + f':PRINT"POOL";CHR$({base}+A);CHR$({base}+B);"  "', 20)
        T.require(
            read(c["output"], len(expected)) == expected
            and bytes(read(c["origin"], len(data))) == data,
            "BASIC presentation changed reserved native state/code",
        )
        advance(2)
        image = out / (variant + ".png")
        m.call("save_screenshot", path=str(image))
        capture = {}
        if system == "bbc-micro":
            capture = {"display_prefix": read(0x7C00, 40)}
        elif system == "atari-800xl":
            A = module(
                "atari_capture", ROOT / "scripts/verify-atari-xl-assembly-deadlines.py"
            )
            screen = A.screen(m)
            text = "POOL" + "".join(map(str, O.checks(variant))) + "  "
            codes = [ord(ch) - 32 for ch in text]
            positions = [
                i
                for i in range(953)
                if i % 40 <= 32 and screen["bytes"][i : i + 8] == codes
            ]
            T.require(len(positions) == 1, "Missing/duplicate Atari banner")
            font = read(756, 1)[0] * 256
            capture = {
                "text": text,
                "codes": codes,
                "screen_bytes": screen["bytes"],
                "screen_base": screen["base"],
                "offset": positions[0],
                "font_base": font,
                "glyphs": {str(code): read(font + code * 8, 8) for code in set(codes)},
            }
        result = {
            "machine": system,
            "language": "assembly",
            "variant": variant,
            "capacity": B.capacity((f / (variant + ".asm")).read_text()),
            "server": m.server["serverInfo"],
            "sources": {str(p.relative_to(ROOT)): sha(p) for p in sources(system)},
            "program_sha256": hashlib.sha256(data).hexdigest(),
            "loaded_program": loaded,
            "loaded_sha256": hashlib.sha256(bytes(loaded)).hexdigest(),
            "origin": c["origin"],
            "end_pointer": pointer,
            "packet": packet,
            "checks": read(aa, 2),
            "ready": read(ready, 1),
            "arithmetic": read(v + 30, 2 if system == "atari-800xl" else 1),
            "frames_after_positive_completion": 2,
            "observer_frames": frames,
            "transcript": transcript,
            "reservation": reservation,
            "capture": capture,
            "image": image.name,
            "image_sha256": sha(image),
            "emulator_sha256": sha(exe),
            "assembler_sha256": sha(assembler),
            "firmware_sha256": {p.name: sha(p) for p in firmware},
        }
        target = out / (variant + ("-draft.json" if draft else ".json"))
        target.write_text(json.dumps(result, indent=2) + "\n")
        print(system, variant, "native packet/return passed", len(packet), flush=True)
        return result
    except Exception:
        m.call("save_screenshot", path=str(out / (variant + "-failure.png")))
        if system == "dragon-32" and draft:
            D = module(
                "dragon_layout", ROOT / "scripts/verify-dragon-basic-deadlines.py"
            )
            (out / (variant + "-diagnostic.json")).write_text(
                json.dumps(
                    {
                        "loaded": read(c["origin"], len(data)),
                        "wanted": list(data),
                        "layout": D.memory_layout(m, system),
                        "transcript": transcript,
                    },
                    indent=2,
                )
                + "\n"
            )
        raise
    finally:
        m.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("system", choices=CONFIG)
    p.add_argument("--tools", type=Path, required=True)
    p.add_argument("--assembler", type=Path, required=True)
    p.add_argument("--variants", default=",".join(B.VARIANTS))
    p.add_argument("--draft", action="store_true")
    a = p.parse_args()
    for variant in a.variants.split(","):
        execute(a.system, variant, a.tools.resolve(), a.assembler.resolve(), a.draft)
