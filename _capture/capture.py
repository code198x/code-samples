#!/usr/bin/env python3
"""Manifest-driven media capture for Code198x units.

One command rebuilds every still, clip, and audio recording a unit needs,
straight from the unit's runnable `step-NN` programs — no staging, no
monitor pokes. Each capture is expanded into an Emu198x `--script` JSON that
is *saved next to the manifest* (the honesty artifact: read the script and
see exactly how the state was reached and what input was injected), then run
against a cold-booted machine. Media lands in the website's public image dir.

Why a manifest (and why it is WASM-aware):
    Each capture names a runnable `prg` (assembled from a `step-NN.asm`) plus
    a `timeline` of boot + input + record actions. That same runnable step is
    exactly what an in-page Emu198x (WASM) needs to make a step a
    run-it / tweak-a-value widget — so the manifest is the single source for
    both the captured media now and the in-page runner later.

Usage:
    capture.py <manifest.json> [--emu PATH] [--keep-prg]

The Emu198x C64 binary is resolved from --emu, then $EMU198X_C64, then a
default sibling-checkout path. Assembles each referenced `.asm` with ACME if
the matching `.prg` is missing or stale.

Timeline actions (each a JSON object):
    {"boot_run": true}            wait for boot, type RUN + RETURN, settle
    {"wait": N}                   run N frames
    {"press": "fire", "frames": N}   button down, run N frames, button up
    {"hold": "up"}                button down (stays down)
    {"release": "up"}             button up
    {"key": "SPACE", "frames": N} key down, run N frames, key up
    {"screenshot": "name.png"}    save the current frame as PNG
    {"record_video": "name.mp4"}  start video recording
    {"stop_video": true}          finish + mux the MP4
    {"record_audio": "name.wav"}  start audio recording
    {"stop_audio": true}          finish the WAV

Joystick control names (C64): up, down, left, right, fire — on port 0
(the primary stick, the main gameport).
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

# Frame gaps for the RUN-typing sequence — long enough for the editor to
# register each keystroke, matching what a learner sees when they type it.
KEY_DOWN_FRAMES = 4
KEY_UP_FRAMES = 3
BOOT_SETTLE_FRAMES = 30
DEFAULT_EMU = "/Users/stevehill/Projects/198x/Emu198x/target/debug/emu198x-c64"


def resolve_emu(arg: str | None) -> str:
    cand = arg or os.environ.get("EMU198X_C64") or DEFAULT_EMU
    if not Path(cand).exists():
        sys.exit(f"Emu198x C64 binary not found: {cand}\n"
                 f"Pass --emu PATH or set EMU198X_C64.")
    return cand


def key_event(name: str, pressed: bool) -> dict:
    return {"Key": {"name": name, "pressed": pressed}}


def button_event(name: str, pressed: bool) -> dict:
    return {"Button": {"port": 0, "name": name, "pressed": pressed}}


def type_run() -> list[dict]:
    """Cold-boot RUN sequence: wait for READY., then type R U N <RETURN>."""
    steps: list[dict] = [{"action": "wait_for_boot", "max_frames": 300}]
    for ch in ("R", "U", "N", "RETURN"):
        steps.append({"action": "input", "events": [key_event(ch, True)]})
        steps.append({"action": "run_frames", "frames": KEY_DOWN_FRAMES})
        steps.append({"action": "input", "events": [key_event(ch, False)]})
        steps.append({"action": "run_frames", "frames": KEY_UP_FRAMES})
    steps.append({"action": "run_frames", "frames": BOOT_SETTLE_FRAMES})
    return steps


def expand_timeline(timeline: list[dict], image_dir: Path) -> list[dict]:
    out: list[dict] = []
    for action in timeline:
        if action.get("boot_run"):
            out.extend(type_run())
        elif "wait" in action:
            out.append({"action": "run_frames", "frames": int(action["wait"])})
        elif "press" in action:
            name = action["press"]
            out.append({"action": "input", "events": [button_event(name, True)]})
            out.append({"action": "run_frames", "frames": int(action.get("frames", 4))})
            out.append({"action": "input", "events": [button_event(name, False)]})
        elif "hold" in action:
            out.append({"action": "input", "events": [button_event(action["hold"], True)]})
        elif "release" in action:
            out.append({"action": "input", "events": [button_event(action["release"], False)]})
        elif "key" in action:
            name = action["key"]
            out.append({"action": "input", "events": [key_event(name, True)]})
            out.append({"action": "run_frames", "frames": int(action.get("frames", 4))})
            out.append({"action": "input", "events": [key_event(name, False)]})
        elif "screenshot" in action:
            out.append({"action": "save_screenshot",
                        "path": str(image_dir / action["screenshot"])})
        elif "record_video" in action:
            out.append({"action": "start_video_recording",
                        "path": str(image_dir / action["record_video"])})
        elif action.get("stop_video"):
            out.append({"action": "stop_video_recording"})
        elif "record_audio" in action:
            out.append({"action": "start_audio_recording",
                        "path": str(image_dir / action["record_audio"])})
        elif action.get("stop_audio"):
            out.append({"action": "stop_audio_recording"})
        else:
            sys.exit(f"Unknown timeline action: {action!r}")
    return out


def ensure_prg(asm_or_prg: Path) -> Path:
    """Return a .prg path, assembling the matching .asm with ACME if needed."""
    if asm_or_prg.suffix == ".prg":
        prg = asm_or_prg
        asm = asm_or_prg.with_suffix(".asm")
    else:
        asm = asm_or_prg
        prg = asm_or_prg.with_suffix(".prg")
    if asm.exists():
        stale = (not prg.exists()) or prg.stat().st_mtime < asm.stat().st_mtime
        if stale:
            subprocess.run(["acme", "-f", "cbm", "-o", str(prg), str(asm)],
                           check=True, cwd=asm.parent)
    if not prg.exists():
        sys.exit(f"No program to run: {prg}")
    return prg


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("manifest", type=Path)
    ap.add_argument("--emu", default=None, help="Path to emu198x-c64")
    ap.add_argument("--keep-prg", action="store_true",
                    help="Keep assembled .prg files (default: leave them)")
    args = ap.parse_args()

    emu = resolve_emu(args.emu)
    manifest_path = args.manifest.resolve()
    manifest = json.loads(manifest_path.read_text())
    unit_dir = manifest_path.parent.parent  # capture/ lives inside the unit dir
    capture_dir = manifest_path.parent

    # website public image dir, computed from the repo layout
    repo_root = Path(__file__).resolve().parents[2]  # code-samples/_capture -> repo
    image_dir = repo_root / "website" / "public" / "images" / manifest["image_dir"]
    image_dir.mkdir(parents=True, exist_ok=True)

    print(f"Manifest : {manifest_path}")
    print(f"Emu      : {emu}")
    print(f"Images   : {image_dir}\n")

    for cap in manifest["captures"]:
        cap_id = cap["id"]
        prg = ensure_prg((unit_dir / cap["prg"]).resolve())
        script = expand_timeline(cap["timeline"], image_dir)

        script_path = capture_dir / f"{cap_id}.script.json"
        script_path.write_text(json.dumps(script, indent=1) + "\n")

        result = subprocess.run([emu, "--script", str(script_path), "--load", str(prg)],
                                capture_output=True, text=True)
        if result.returncode != 0:
            print(f"  ✗ {cap_id}: emu exited {result.returncode}\n{result.stderr}")
            continue

        try:
            obs = json.loads(result.stdout)
            rec = [o for o in obs.get("observations", [])
                   if o.get("kind") in ("stop_audio_recording", "stop_video_recording")]
            extra = f"  {rec}" if rec else ""
        except json.JSONDecodeError:
            extra = ""
        outputs = cap.get("outputs") or _declared_outputs(cap["timeline"])
        print(f"  ✓ {cap_id} -> {', '.join(outputs)}{extra}")

    print("\nDone. Saved scripts:", capture_dir)


def _declared_outputs(timeline: list[dict]) -> list[str]:
    keys = ("screenshot", "record_video", "record_audio")
    return [action[k] for action in timeline for k in keys if k in action]


if __name__ == "__main__":
    main()
