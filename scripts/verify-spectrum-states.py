"""Boot the maintained state caller through ROM tape loading and real keys."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "sinclair-zx-spectrum/patterns/assembly/framework/state-machine-loop"
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").unlink(missing_ok=True)
    subprocess.run(
        ["make"], cwd=FOLDER, capture_output=True, text=True, timeout=30, check=True
    )
    sym = T.symbols(FOLDER / "build/demo.sym")
    m = T.Machine([args.emulator, "--mcp"])
    observations = []

    def read(name: str, size: int = 1) -> int:
        return T.memory(m, sym[name], size)

    def advance(frames: int) -> None:
        m.call("run_frames", frames=frames)

    def state(expected: int) -> None:
        value = read("game_state")
        T.require(value == expected, f"Expected state {expected}, observed {value}")
        observations.append({"state": value, "game_ticks": read("game_ticks", 2)})

    def key(name: str, pressed: bool) -> None:
        m.call("input", events=[{"Key": {"name": name, "pressed": pressed}}])
        advance(8)

    try:
        m.call(
            "load_media",
            slot="tape-1",
            kind="tape",
            path=str(FOLDER / "build/demo.tap"),
        )
        m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        for _ in range(40):
            advance(100)
            if read("ready", 2) == 0xCAFE:
                break
        T.require(read("ready", 2) == 0xCAFE, "State caller did not start from tape")
        state(0)
        advance(20)
        T.require(read("game_ticks", 2) == 0, "Title advanced gameplay")
        key("space", True)
        state(1)
        before = read("game_ticks", 2)
        advance(20)
        state(1)
        T.require(read("game_ticks", 2) > before, "Playing did not advance")
        key("space", False)
        key("space", True)
        state(3)
        before = read("game_ticks", 2)
        advance(20)
        state(3)
        T.require(read("game_ticks", 2) == before, "Pause advanced gameplay")
        key("space", False)
        key("space", True)
        state(1)
        T.require(read("game_ticks", 2) >= before, "Resume reset the session")
        key("space", False)
        key("q", True)
        state(2)
        before = read("game_ticks", 2)
        advance(20)
        T.require(read("game_ticks", 2) == before, "Game over advanced gameplay")
        key("q", False)
        key("space", True)
        state(0)
        advance(20)
        state(0)
        key("space", False)
        key("space", True)
        state(1)
        T.require(
            read("game_ticks", 2) < before,
            "Fresh session did not reset gameplay counter",
        )
        m.call("save_screenshot", path=str(args.output / "playing.png"))
    finally:
        m.close()
    result = {
        "status": "passed",
        "observations": observations,
        "sources": {
            str(p.resolve().relative_to(ROOT)): sha(p)
            for p in [
                FOLDER / "demo.asm",
                FOLDER / "../game-loop/frame.inc",
                FOLDER / "../input-to-sound/input.inc",
            ]
        },
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "limits": "48K ROM TAP loading, real Q/Space, state transitions and held/released behaviour. Not a complete game, elapsed-time clock, OS-return or original-hardware qualification.",
    }
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(
        "PASS title, play, pause, resume, loss, held transition keys and fresh session"
    )


if __name__ == "__main__":
    main()
