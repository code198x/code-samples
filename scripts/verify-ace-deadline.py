"""Run reusable deadline words through the stock Ace ROM and real keyboard."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "jupiter-ace/patterns/forth/framework/turn-deadline"
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def screen(machine: T.Machine) -> tuple[list[int], str]:
    raw = []
    for offset in range(0, 768, 128):
        data = machine.call("memory_read", addr=0x2400 + offset, len=128)["bytes"]
        T.require(len(data) == 128, "Truncated screen")
        raw += data
    return raw, "".join(chr(c & 127) if 32 <= (c & 127) < 127 else " " for c in raw)


def enter(machine: T.Machine, line: str) -> None:
    result = machine.call("type_string", text=line + "\n", settle_frames=20)
    T.require(result["chars_typed"] == len(line) + 1, "Incomplete typed source")
    _, text = screen(machine)
    T.require("ERROR" not in text.upper(), f"ROM error after {line}: {text}")


def value(machine: T.Machine, expression: str) -> int:
    enter(machine, expression + " NUMBER")
    _, text = screen(machine)
    match = re.match(r"\s*(\d+)\s", text)
    T.require(match is not None, f"No numeric response to {expression}: {text}")
    return int(match[1])


def read(machine: T.Machine, addr: int, length: int = 2) -> int:
    raw = machine.call("memory_read", addr=addr, len=length)["bytes"]
    T.require(len(raw) == length, "Truncated state")
    return int.from_bytes(bytes(raw), "little")


def capture_check(machine: T.Machine, image: Path) -> dict:
    spec = importlib.util.spec_from_file_location(
        "png", ROOT / "scripts/check-amiga-command-loops.py"
    )
    assert spec and spec.loader
    pixels_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(pixels_module)
    video, _ = screen(machine)
    font = []
    for offset in range(0, 1024, 128):
        part = machine.call("memory_read", addr=0x2C00 + offset, len=128)["bytes"]
        T.require(len(part) == 128, "Truncated character RAM")
        font += part
    width, height, channels, pixels = pixels_module.png(image)
    T.require(
        (width, height, channels) == (320, 288, 4), "Unexpected Ace capture geometry"
    )
    glyphs = {
        str(code & 127): font[(code & 127) * 8 : (code & 127) * 8 + 8] for code in video
    }
    for y in range(192):
        for x in range(256):
            code = video[(y // 8) * 32 + x // 8]
            bits = glyphs[str(code & 127)][y % 8]
            expected = bool(bits & (128 >> (x % 8))) ^ bool(code & 128)
            pos = ((y + 48) * width + x + 32) * channels
            actual = min(pixels[pos : pos + 3]) > 180 and pixels[pos + 3] == 255
            T.require(
                actual == expected, "Capture disagrees with native screen/font RAM"
            )
    return {"video_hex": bytes(video).hex(), "glyphs": glyphs, "pixel_match": True}


def qualify(args: argparse.Namespace, variant: str) -> dict:
    command = [str(args.emulator), "--mcp", "--rom", str(args.firmware)]
    machine = T.Machine(command)
    out = FOLDER / "verification"
    out.mkdir(exist_ok=True)
    files = [
        "routines.fth",
        "clock.fth",
        "mistakes/reset-baseline.fth" if variant == "wrong" else "service.fth",
        "input.fth",
        "caller.fth",
        "customise.fth" if variant == "custom" else "settings.fth",
    ]
    sources = {file: (FOLDER / file).read_text() for file in files}
    try:
        machine.call("run_frames", frames=150)
        enter(machine, ": NUMBER CLS U. ;")
        before = value(machine, "HERE")
        sizes = {}
        for file, text in sources.items():
            for line in text.splitlines():
                enter(machine, line)
            sizes[file] = value(machine, "HERE")
            print(variant, file, sizes[file], flush=True)
        addresses = {
            word: value(machine, word) for word in ["DU", "DR", "DA", "DP", "DE", "KP"]
        }
        top = value(machine, "15384 @")
        T.require(top == 16384, "Not the stock unexpanded Ace")
        enter(machine, "TURNS")
        samples = []

        def observe(stage: str) -> dict:
            for _ in range(12):
                raw, text = screen(machine)
                T.require("ERROR" not in text.upper(), f"Runtime error: {text}")
                match = re.match(
                    r"\s*TURN\s+(\d+)\s+TIMER\s+(\d+)", text, re.IGNORECASE
                )
                if match is not None:
                    break
                machine.call("run_frames", frames=1)
            T.require(match is not None, f"Missing running caller: {text}")
            state = {
                "stage": stage,
                "turn": int(match[1]),
                "timer_screen": int(match[2]),
                "screen_hex": bytes(raw).hex(),
                "clock": read(machine, 15403),
                "state": {
                    word: read(machine, addr) for word, addr in addresses.items()
                },
                "dictionary": read(machine, 15415),
                "data_top": read(machine, 15419),
                "cpu_sp": int(
                    machine.call("query_cpu")["registers"]["sp"].lstrip("$"), 16
                ),
            }
            samples.append(state)
            print(variant, stage, state["turn"], state["state"], flush=True)
            return state

        def frames(n: int) -> None:
            while n:
                count = min(200, n)
                machine.call("run_frames", frames=count)
                n -= count

        def key(name: str, n: int = 4) -> None:
            machine.call("input", events=[{"Key": {"name": name, "pressed": True}}])
            frames(n)
            machine.call("input", events=[{"Key": {"name": name, "pressed": False}}])
            frames(8)

        first = observe("initial")
        T.require(
            first["turn"] == 0 and first["state"]["DA"] == 0, "Must start untimed"
        )
        frames(100)
        idle = observe("untimed-idle")
        T.require(
            idle["turn"] == 0 and idle["clock"] != first["clock"], "Untimed idle failed"
        )
        key("1", 120)
        action = observe("untimed-action")
        T.require(
            action["turn"] == 1 and action["state"]["DA"] == 0,
            "Action repeated or enabled timing",
        )
        frames(100)
        T.require(observe("held-released-idle")["turn"] == 1, "Unexpected extra turn")
        key("2")
        enabled = observe("enabled")
        T.require(enabled["state"]["DA"] == 1, "Timing did not enable")
        frames(30)
        progress = observe("progress")
        if variant == "wrong":
            frames(250)
            expired = observe("wrong-no-expiry")
            T.require(
                expired["turn"] == 1
                and expired["state"]["DR"] == 200
                and expired["state"]["DE"] == 0,
                "Baseline fault was not demonstrated",
            )
        else:
            T.require(
                progress["state"]["DR"] < enabled["state"]["DR"],
                "No-input timer did not progress",
            )
            key("1")
            restarted = observe("restart")
            T.require(
                restarted["turn"] == 2
                and restarted["state"]["DR"] > progress["state"]["DR"],
                "Active action did not restart",
            )
            for _ in range(60):
                frames(5)
                expired = observe("await-expiry")
                if expired["turn"] != 2:
                    break
            T.require(
                expired["turn"] == 3 and expired["state"]["DA"] == 1,
                "No-input expiry did not commit one turn",
            )
        frames(2)
        image = out / f"{variant}-expiry.png"
        machine.call("save_screenshot", path=str(image))
        capture = capture_check(machine, image)
        key("2")
        disabled = observe("disabled")
        frames(250)
        stopped = observe("disabled-idle")
        T.require(
            disabled["state"]["DA"] == stopped["state"]["DA"] == 0
            and disabled["turn"] == stopped["turn"],
            "Disabled game advanced",
        )
        key("0")
        _, ended = screen(machine)
        T.require("ERROR" not in ended.upper(), "Exit broke the stack")
        after_exit = read(machine, 15419)
        T.require(
            after_exit == read(machine, 15415) + 12, "Exit leaked a data-stack cell"
        )
        return {
            "sources": {file: T.sha(FOLDER / file) for file in files},
            "here_before": before,
            "here_after_files": sizes,
            "addresses": addresses,
            "ram_top": top,
            "samples": samples,
            "data_top_after_exit": after_exit,
            "capture": capture,
            "image": image.name,
            "image_sha256": T.sha(image),
        }
    except Exception:
        machine.call("save_screenshot", path=str(out / f"{variant}-failure.png"))
        raise
    finally:
        machine.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--emulator", required=True, type=Path)
    p.add_argument(
        "--firmware",
        type=Path,
        default=Path.home() / ".emu198x/roms/jupiter-ace/ace.rom",
    )
    p.add_argument("--variants", default="working,custom,wrong,repaired")
    args = p.parse_args()
    target = FOLDER / "verification/native.json"
    records = json.loads(target.read_text())["cases"] if target.exists() else {}
    for variant in args.variants.split(","):
        records[variant] = qualify(args, variant)
    result = {
        "status": "passed",
        "machine": "jupiter-ace",
        "language": "forth",
        "emulator_sha256": T.sha(args.emulator),
        "firmware_sha256": T.sha(args.firmware),
        "cases": records,
    }
    (FOLDER / "verification/native.json").write_text(
        json.dumps(result, indent=2) + "\n"
    )
