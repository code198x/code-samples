"""Cold-boot the four-voice caller; check row/hold timing and actual stereo PCM."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
import wave
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATTERN = ROOT / "commodore-amiga/patterns/assembly/audio/four-channel-music"
SPEC = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
assert SPEC and SPEC.loader
T = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(T)
# Expected musical events, independent of table byte offsets or register math.
ROWS = [
    (428, 339, 285, 856),
    (339, None, None, None),
    (285, 428, 339, 856),
    (339, None, None, None),
] * 2


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def execute(args: argparse.Namespace, negative: bool) -> dict:
    out = args.output / ("dma-disabled" if negative else "playing")
    out.mkdir(parents=True, exist_ok=True)
    source = (PATTERN / "music.inc").read_text()
    if negative:
        T.require(source.count("move.w #$820f,$096(a5)") == 1, "Ambiguous DMA control")
        source = source.replace("move.w #$820f,$096(a5)", "move.w #$000f,$096(a5)")
    (out / "music.inc").write_text(source)
    shutil.copy2(PATTERN / "../../framework/game-loop/frame.inc", out / "frame.inc")
    (out / "demo.asm").write_text(
        (PATTERN / "demo.asm")
        .read_text()
        .replace("../../framework/game-loop/frame.inc", "frame.inc")
    )
    for cmd in [
        [
            args.assembler,
            "--dialect",
            "vasm",
            "--exe",
            "--sym=demo.sym",
            "demo.asm",
            "-o",
            "demo",
        ],
        [args.build198x, "adf", "demo", "-o", "demo.adf", "--name", "demo"],
    ]:
        r = subprocess.run(
            cmd, cwd=out, capture_output=True, text=True, timeout=40, check=False
        )
        T.require(r.returncode == 0, r.stderr or r.stdout)
    sym = T.symbols(out / "demo.sym")
    m = T.Machine(
        [
            args.emulator,
            "--mcp",
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(out / "demo.adf"),
        ]
    )
    try:
        found = []
        for _ in range(20):
            m.call("run_frames", frames=100)
            scan = m.call("memory_scan", start=0, end=0x80000, value=0x31393858)
            T.require(not scan["truncated"], "Marker scan truncated")
            for hit in scan["hits"]:
                base = int(hit["addr"][1:], 16) - sym["signature"]
                if T.memory(m, base + sym["ready"], 2, True) == 0xCAFE:
                    found.append(base)
            if found:
                break
        T.require(len(found) == 1, "Music caller did not reach ready state")
        base = found[0]
        m.call("clear_audio_capture")
        m.call(
            "input", events=[{"Button": {"port": 2, "name": "fire", "pressed": True}}]
        )
        observations = []
        seen = set()
        for _ in range(56):
            m.call("run_frames", frames=1)
            updates = T.memory(m, base + sym["updates"], 2, True)
            if updates == 0:
                continue
            event = (updates - 1) // 6
            row = event % 8
            expected = [856] * 4
            for n in range(event + 1):
                for c, value in enumerate(ROWS[n % 8]):
                    if value is not None:
                        expected[c] = value
            actual = []
            for c in range(4):
                channel = m.call("query", path=f"paula.audio.channels.channel{c}")[
                    "result"
                ]["value"]
                T.require(
                    channel["period"] == expected[c] and channel["volume"] == 64,
                    f"Wrong channel {c} period/volume at update {updates}",
                )
                T.require(
                    channel["programmed_length_words"] == 8
                    and channel["location"] == base + sym["instrument"],
                    "Sample pointer/word length mismatch",
                )
                T.require(
                    not channel["period_modulation_enabled"]
                    and not channel["volume_modulation_enabled"],
                    "Audio modulation was not disabled",
                )
                actual.append(channel["period"])
            T.require(
                T.memory(m, base + sym["music_row"], 2, True) == (row + 1) % 8,
                "Wrong next row or wrap",
            )
            seen.add(row)
            observations.append({"updates": updates, "periods": actual})
        T.require(seen == set(range(8)), "Did not exercise all eight rows and holds")
        audio = out / "music.wav"
        m.call("save_audio_capture", path=str(audio))
    finally:
        m.close()
    with wave.open(str(audio)) as stream:
        T.require(
            stream.getsampwidth() == 2 and stream.getnchannels() == 2,
            "Expected16-bit stereo PCM",
        )
        pcm = array("h", stream.readframes(stream.getnframes()))
        channels = [pcm[c::2] for c in range(2)]
    T.require(
        all(max(values) - min(values) > 500 for values in channels),
        "Audio is flat on a stereo side",
    )
    return {
        "observations": observations,
        "audio_sha256": sha(audio),
        "binary_sha256": sha(out / "demo"),
    }


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", required=True)
    p.add_argument("--build198x", required=True)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument(
        "--kickstart",
        type=Path,
        default=Path.home() / ".emu198x/roms/commodore-amiga/kick13.rom",
    )
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "results.json").unlink(missing_ok=True)
    positive = execute(args, False)
    try:
        execute(args, True)
    except AssertionError as error:
        T.require(
            str(error) == "Audio is flat on a stereo side",
            f"Unrelated control failure: {error}",
        )
    else:
        raise AssertionError("Disabled DMA passed the audio guard")
    result = {
        "status": "passed",
        "configuration": "A500 OCS PAL, Kickstart1.3, cold-boot ADF, Fire on physical port2",
        "rows_checked": 8,
        "negative_dma_rejected": True,
        "positive": positive,
        "sources": {
            str(p.relative_to(ROOT)): sha(p)
            for p in [
                PATTERN / "demo.asm",
                PATTERN / "music.inc",
                ROOT
                / "commodore-amiga/patterns/assembly/framework/game-loop/frame.inc",
            ]
        },
        "observer_sha256": sha(Path(__file__)),
        "emulator_sha256": sha(Path(args.emulator)),
        "firmware_sha256": sha(args.kickstart),
        "limits": "Named configuration and bounded waveform sequencer only. No MOD-format, tracker effects, original-hardware or pitch-accuracy qualification.",
    }
    (args.output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(
        "PASS eight rows, four real channels, holds, wrap, stereo PCM and disabled-DMA control"
    )


if __name__ == "__main__":
    main()
