#!/usr/bin/env python3
"""Manifest-driven media capture for Code198x units.

One command rebuilds every still, clip, and audio recording a unit needs,
straight from the unit's runnable `step-NN` programs — no staging, no
monitor pokes. Each capture is expanded into an Emu198x `--script` JSON that
is *saved next to the manifest* (the honesty artifact: read the script and
see exactly how the state was reached and what input was injected), then run
against a cold-booted machine. Media lands in the website's public image dir.

Two machines are supported, chosen by the manifest's top-level `"machine"`
field (default `commodore-64`):

  * `commodore-64`       — assemble `.asm` → `.prg` with local ACME, load with
                           `--load`, type RUN at the cold-boot prompt.
  * `sinclair-zx-spectrum` — assemble `.asm` → `.sna` with pasmonext in the
                           `sinclair-zx-spectrum` Docker image (then load the
                           snapshot), or load a `.bas` text program directly
                           with `load_basic_program`.

Why a manifest (and why it is WASM-aware):
    Each capture names a runnable program (assembled from a `step-NN.asm`, or
    a `.bas`) plus a `timeline` of boot + input + record actions. That same
    runnable step is exactly what an in-page Emu198x (WASM) needs to make a
    step a run-it / tweak-a-value widget — so the manifest is the single
    source for both the captured media now and the in-page runner later.

Usage:
    capture.py <manifest.json> [--emu PATH] [--keep-build]

The Emu198x binary is resolved per machine from --emu, then the machine's env
var ($EMU198X_C64 / $EMU198X_SPECTRUM), then a default sibling-checkout path.

Timeline actions (each a JSON object) — shared vocabulary, mapped per machine:
    {"boot_run": true}            C64 only: wait for boot, type RUN + RETURN
    {"wait": N}                   run N frames
    {"press": "fire", "frames": N}   C64 joystick: button down, N frames, up
    {"hold": "up"} / {"release": "up"}   button/key down / up (held across steps)
    {"key": "SPACE", "frames": N}    key down, run N frames, key up
    {"type": "ZOG\n"}             Spectrum only: type a string (\n = ENTER)
    {"screenshot": "name.png"}    save the current frame as PNG
    {"record_video": "name.mp4"}  start video recording
    {"stop_video": true}          finish + mux the MP4
    {"record_audio": "name.wav"}  start audio recording
    {"stop_audio": true}          finish the WAV

C64 joystick control names: up, down, left, right, fire — on port 0.
Spectrum key names: A-Z, 0-9, Space, Enter, CapsShift, SymbolShift.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# Frame gaps for the C64 RUN-typing sequence — long enough for the editor to
# register each keystroke, matching what a learner sees when they type it.
KEY_DOWN_FRAMES = 4
KEY_UP_FRAMES = 3
BOOT_SETTLE_FRAMES = 30

CODE_SAMPLES = Path(__file__).resolve().parents[1]   # the code-samples repo
REPO_ROOT = Path(__file__).resolve().parents[2]      # the Code198x container

EMU_DEFAULTS = {
    "commodore-64": "/Users/stevehill/Projects/198x/Emu198x/target/debug/emu198x-c64",
    "sinclair-zx-spectrum": "/Users/stevehill/Projects/198x/Emu198x/target/debug/emu198x-spectrum",
    "commodore-amiga": "/Users/stevehill/Projects/198x/Emu198x/target/release/emu198x-amiga",
    # Blitz BASIC 2 runs on the same Amiga binary; only the disk/editor differs.
    "commodore-amiga-blitz": "/Users/stevehill/Projects/198x/Emu198x/target/release/emu198x-amiga",
}
EMU_ENV = {
    "commodore-64": "EMU198X_C64",
    "sinclair-zx-spectrum": "EMU198X_SPECTRUM",
    "commodore-amiga": "EMU198X_AMIGA",
    "commodore-amiga-blitz": "EMU198X_AMIGA",
}
SPECTRUM_IMAGE = "ghcr.io/code198x/sinclair-zx-spectrum:latest"

# AMOS (Commodore Amiga) capture: there is no host build — the learner's ASCII
# AMOS source is *typed* into the AMOS Pro editor via `type_string`, then run
# with F1. The work disk is a prepared AMOS Pro System ADF whose startup loads
# the US keymap (`SetMap usa1`) so the US `type_string` table matches.
AMOS_KICKSTART = str(Path.home() / ".emu198x/roms/commodore-amiga/kick204.rom")
AMOS_DISK = str(Path.home() / ".emu198x/media/commodore-amiga/amospro-system-usa.adf")
AMOS_MODEL = "a500-plus"
AMOS_BOOT_FRAMES = 2500   # frames to reach the AMOS Pro editor
AMOS_TYPE_SETTLE = 20     # frames after typing, before F1 runs the program

# Blitz BASIC 2 (Commodore Amiga) capture: same as AMOS — no host build, the
# learner's plain-text Blitz source is *typed* into the Ted editor via
# `type_string`, then compiled-and-run with the Compiler menu's command key
# right-Amiga+X. The work disk is the BB2 v1.60 Amiga Format single disk with its
# startup-sequence edited to launch `blitz2` straight into Ted. Needs KS2.04 (the
# editor's console needs the 2.0+ ROM console; KS1.3 fails to open it).
BLITZ_KICKSTART = str(Path.home() / ".emu198x/roms/commodore-amiga/kick204.rom")
BLITZ_DISK = str(Path.home() / ".emu198x/media/commodore-amiga/bb2-af-blitz.adf")
BLITZ_MODEL = "a500-plus"
BLITZ_BOOT_FRAMES = 2100   # frames to reach the Ted editor (with the startup requester up)
BLITZ_TYPE_SETTLE = 30     # frames after typing, before the compile-and-run trigger
RAMIGA_RAW = "raw-67"      # right-Amiga qualifier (the menu command-key modifier)


def resolve_emu(machine: str, arg: str | None) -> str:
    cand = arg or os.environ.get(EMU_ENV[machine]) or EMU_DEFAULTS[machine]
    if not Path(cand).exists():
        sys.exit(f"Emu198x binary not found for {machine}: {cand}\n"
                 f"Pass --emu PATH or set {EMU_ENV[machine]}.")
    return cand


def container_path(host: Path) -> str:
    """Translate a host path under code-samples to its /code-samples mount path."""
    return "/code-samples/" + str(host.resolve().relative_to(CODE_SAMPLES))


def frame_screenshot(path: Path, border: int = 24) -> None:
    """Re-frame a raw framebuffer PNG so the picture is centred.

    The emulator saves the whole hardware raster, so a normal-sized screen
    sits wherever the display window lands — off-centre, floating in the
    overscan border. This crops to the active (non-black) picture and pastes
    it back onto a canvas with a uniform `border` all round, so the result is
    tight and centred rather than lopsided. A no-op if Pillow is unavailable
    or the frame is entirely black."""
    try:
        from PIL import Image
    except ImportError:
        return
    im = Image.open(path).convert("RGB")
    bbox = im.getbbox()  # tightest box around the non-black picture
    if not bbox:
        return
    content = im.crop(bbox)
    w, h = content.size
    canvas = Image.new("RGB", (w + 2 * border, h + 2 * border), (0, 0, 0))
    canvas.paste(content, (border, border))
    canvas.save(path)


# --------------------------------------------------------------------------
# Commodore 64
# --------------------------------------------------------------------------

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


def expand_timeline_c64(timeline: list[dict], image_dir: Path) -> list[dict]:
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
            sys.exit(f"Unknown C64 timeline action: {action!r}")
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


def run_c64(manifest, capture_dir, unit_dir, image_dir, emu, keep_build):
    for cap in manifest["captures"]:
        cap_id = cap["id"]
        prg = ensure_prg((unit_dir / cap["prg"]).resolve())
        script = expand_timeline_c64(cap["timeline"], image_dir)

        script_path = capture_dir / f"{cap_id}.script.json"
        script_path.write_text(json.dumps(script, indent=1) + "\n")

        result = subprocess.run([emu, "--script", str(script_path), "--load", str(prg)],
                                capture_output=True, text=True)
        report_capture(cap, result)
    if not keep_build:
        for cap in manifest["captures"]:
            prg = (unit_dir / cap["prg"]).resolve().with_suffix(".prg")
            if prg.exists():
                prg.unlink()


# --------------------------------------------------------------------------
# Sinclair ZX Spectrum
# --------------------------------------------------------------------------

def ensure_sna(asm_or_sna: Path) -> Path:
    """Return a .sna path, assembling the matching .asm with pasmonext (Docker)
    if needed. The .sna is written next to the .asm so it sits inside the
    /code-samples mount."""
    if asm_or_sna.suffix == ".sna":
        sna = asm_or_sna
        asm = asm_or_sna.with_suffix(".asm")
    else:
        asm = asm_or_sna
        sna = asm_or_sna.with_suffix(".sna")
    if asm.exists():
        stale = (not sna.exists()) or sna.stat().st_mtime < asm.stat().st_mtime
        if stale:
            subprocess.run(
                ["docker", "run", "--rm",
                 "-v", f"{CODE_SAMPLES}:/code-samples",
                 SPECTRUM_IMAGE,
                 "pasmonext", "--sna",
                 container_path(asm), container_path(sna)],
                check=True)
    if not sna.exists():
        sys.exit(f"No program to run: {sna}")
    return sna


def ensure_tap(asm_or_tap: Path) -> Path:
    """Return a .tap path, assembling the matching .asm with `pasmonext
    --tapbas` (a real tape image with an auto-running BASIC loader) if needed.
    Written next to the .asm so it sits inside the /code-samples mount."""
    if asm_or_tap.suffix == ".tap":
        tap = asm_or_tap
        asm = asm_or_tap.with_suffix(".asm")
    else:
        asm = asm_or_tap
        tap = asm_or_tap.with_suffix(".tap")
    if asm.exists():
        stale = (not tap.exists()) or tap.stat().st_mtime < asm.stat().st_mtime
        if stale:
            subprocess.run(
                ["docker", "run", "--rm",
                 "-v", f"{CODE_SAMPLES}:/code-samples",
                 SPECTRUM_IMAGE,
                 "pasmonext", "--tapbas",
                 container_path(asm), container_path(tap)],
                check=True)
    if not tap.exists():
        sys.exit(f"No program to run: {tap}")
    return tap


TAPE_SLOT = "tape-1"


def spectrum_load_step(program: Path) -> dict:
    """The in-script step that installs the program. A .sna resumes a saved
    machine; a .bas is tokenised into a freshly booted BASIC and RUN; a .tap
    is inserted into the tape deck for a real, pulse-driven load (drive it
    from the timeline with {"autoload": frames})."""
    if program.suffix == ".sna":
        return {"action": "load_snapshot", "path": str(program)}
    if program.suffix == ".bas":
        return {"action": "load_basic_program", "path": str(program), "run": True}
    if program.suffix == ".tap":
        return {"action": "load_media", "slot": TAPE_SLOT, "kind": "tape",
                "path": str(program)}
    sys.exit(f"Unsupported Spectrum program: {program}")


def expand_timeline_spectrum(timeline: list[dict], image_dir: Path) -> list[dict]:
    out: list[dict] = []
    for action in timeline:
        if "wait" in action:
            out.append({"action": "run_frames", "frames": int(action["wait"])})
        elif "key" in action:
            step = {"action": "press_key", "key": action["key"]}
            if "frames" in action:
                step["hold_frames"] = int(action["frames"])
            out.append(step)
        elif "hold" in action:
            # Raw key-down that stays down (press_key auto-releases, so it
            # can't hold a key across a screenshot). Used to capture a
            # held-key state — a recoloured figure, a key-driven move.
            out.append({"action": "input", "events": [key_event(action["hold"], True)]})
        elif "release" in action:
            out.append({"action": "input", "events": [key_event(action["release"], False)]})
        elif "type" in action:
            step = {"action": "type_string", "text": action["type"]}
            if "settle" in action:
                step["settle_frames"] = int(action["settle"])
            out.append(step)
        elif "poke" in action:
            # Capture-setup write to CPU memory (binary-dispatched poke_byte).
            # Used to reach a state quickly before exercising the *real* game
            # logic — e.g. set lives to 1 so one engineered collision drives
            # the genuine lose path. Address accepts int or "0x.." string.
            addr = action["poke"]
            addr = int(addr, 0) if isinstance(addr, str) else int(addr)
            out.append({"action": "poke_byte", "addr": addr,
                        "value": int(action["value"]) & 0xFF})
        elif "autoload" in action:
            # Real pulse-driven tape load: type LOAD"", play the tape, and run
            # the ROM loader for up to N frames (the loading stripes show
            # during these). The auto-running BASIC loader then starts the
            # game. Pair with a .tap program and a record_video around it.
            out.append({"action": "autoload_tape", "slot": TAPE_SLOT,
                        "max_boot_frames": int(action["autoload"])})
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
            sys.exit(f"Unknown Spectrum timeline action: {action!r}")
    return out


def run_spectrum(manifest, capture_dir, unit_dir, image_dir, emu, keep_build):
    built: list[Path] = []
    for cap in manifest["captures"]:
        cap_id = cap["id"]
        program_ref = (unit_dir / cap["program"]).resolve()
        tape = cap.get("load") == "tape"
        if tape and program_ref.suffix in (".asm", ".tap"):
            program = ensure_tap(program_ref)        # real tape image (--tapbas)
            if program_ref.suffix == ".asm":
                built.append(program)
        elif program_ref.suffix in (".asm", ".sna"):
            program = ensure_sna(program_ref)
            if program_ref.suffix == ".asm":
                built.append(program)
        else:
            program = program_ref  # .bas, used as-is
            if not program.exists():
                sys.exit(f"No program to run: {program}")

        script = [spectrum_load_step(program)]
        script += expand_timeline_spectrum(cap["timeline"], image_dir)

        script_path = capture_dir / f"{cap_id}.script.json"
        script_path.write_text(json.dumps(script, indent=1) + "\n")

        result = subprocess.run([emu, "--script", str(script_path)],
                                capture_output=True, text=True)
        report_capture(cap, result)
    if not keep_build:
        for sna in built:
            if sna.exists():
                sna.unlink()


# --------------------------------------------------------------------------
# Commodore Amiga — AMOS Professional
# --------------------------------------------------------------------------

def _amos_key(name: str, pressed: bool) -> dict:
    return {"action": "input", "events": [key_event(name, pressed)]}


# The Amiga's canonical joystick is control port 2 (JOY1DAT); port 1 is the
# mouse (JOY0DAT). emu198x-amiga maps input port 2 (and 0 as an alias) onto
# JOY1DAT, which AMOS reads as port 1 — so inject on port 2, read Jright(1).
# Control names match the C64 set: up, down, left, right, fire.
AMOS_JOY_PORT = 2


def _amos_joy(name: str, pressed: bool, port: int = AMOS_JOY_PORT) -> dict:
    return {"action": "input",
            "events": [{"Button": {"port": port, "name": name, "pressed": pressed}}]}


def _amos_tap(name: str, hold: int = 3, up: int = 3) -> list[dict]:
    return [
        _amos_key(name, True),
        {"action": "run_frames", "frames": hold},
        _amos_key(name, False),
        {"action": "run_frames", "frames": up},
    ]


def expand_timeline_amiga(timeline: list[dict], image_dir: Path) -> list[dict]:
    out: list[dict] = []
    for action in timeline:
        if "wait" in action:
            out.append({"action": "run_frames", "frames": int(action["wait"])})
        elif "joy" in action:
            # Push the joystick, hold for `frames`, release. e.g. {"joy": "right", "frames": 60}
            port = int(action.get("port", AMOS_JOY_PORT))
            out.append(_amos_joy(action["joy"], True, port))
            out.append({"action": "run_frames", "frames": int(action.get("frames", 50))})
            out.append(_amos_joy(action["joy"], False, port))
        elif "joy_hold" in action:
            out.append(_amos_joy(action["joy_hold"], True, int(action.get("port", AMOS_JOY_PORT))))
        elif "joy_release" in action:
            out.append(_amos_joy(action["joy_release"], False, int(action.get("port", AMOS_JOY_PORT))))
        elif "screenshot" in action:
            out.append({"action": "save_screenshot",
                        "path": str(image_dir / action["screenshot"])})
        elif "record_audio" in action:
            out.append({"action": "start_audio_recording",
                        "path": str(image_dir / action["record_audio"])})
        elif action.get("stop_audio"):
            out.append({"action": "stop_audio_recording"})
        else:
            sys.exit(f"Unknown AMOS timeline action: {action!r}")
    return out


def run_amiga(manifest, capture_dir, unit_dir, image_dir, emu, keep_build):
    """Type each capture's ASCII AMOS source into AMOS Pro and run it (F1).

    No host build: the source is typed via `type_string`. The work disk is a
    prepared AMOS Pro System ADF (US keymap). `kickstart`, `disk`, and `model`
    may be overridden per manifest."""
    kickstart = manifest.get("kickstart", AMOS_KICKSTART)
    disk = manifest.get("disk", AMOS_DISK)
    model = manifest.get("model", AMOS_MODEL)
    for asset in (kickstart, disk):
        if not Path(asset).exists():
            sys.exit(f"AMOS capture asset not found: {asset}")

    for cap in manifest["captures"]:
        cap_id = cap["id"]
        source = (unit_dir / cap["program"]).resolve().read_text()

        script = [{"action": "run_frames", "frames": AMOS_BOOT_FRAMES}]
        # The AMOS Pro credits banner swallows the first keystroke; spend a
        # throwaway space+backspace before typing the real program.
        script += _amos_tap("space") + _amos_tap("backspace")
        script += [
            {"action": "run_frames", "frames": 10},
            {"action": "type_string", "text": source},
            {"action": "run_frames", "frames": AMOS_TYPE_SETTLE},
        ]
        script += _amos_tap("f1")              # F1 = Run the program
        script += expand_timeline_amiga(cap["timeline"], image_dir)

        script_path = capture_dir / f"{cap_id}.script.json"
        script_path.write_text(json.dumps(script, indent=1) + "\n")

        result = subprocess.run(
            [emu, "--headless", "--kickstart", kickstart, "--model", model,
             "--disk", disk, "--script", str(script_path)],
            capture_output=True, text=True)
        report_capture(cap, result)
        # Centre each screenshot in a clean border (the raw raster is off-centre).
        for action in cap["timeline"]:
            if "screenshot" in action:
                frame_screenshot(image_dir / action["screenshot"])


def _blitz_compile_run() -> list[dict]:
    """Compiler menu COMPILE/RUN, via its command key right-Amiga+X."""
    return [
        _amos_key(RAMIGA_RAW, True),
        {"action": "run_frames", "frames": 3},
        _amos_key("x", True),
        {"action": "run_frames", "frames": 3},
        _amos_key("x", False),
        _amos_key(RAMIGA_RAW, False),
    ]


def run_blitz(manifest, capture_dir, unit_dir, image_dir, emu, keep_build):
    """Type each capture's plain-text Blitz source into Ted and compile-and-run it.

    No host build: the source is typed via `type_string`, then compiled and run
    with right-Amiga+X. The work disk is the BB2 Amiga Format single disk, edited
    to boot straight into Ted. `kickstart`, `disk`, and `model` may be overridden
    per manifest."""
    kickstart = manifest.get("kickstart", BLITZ_KICKSTART)
    disk = manifest.get("disk", BLITZ_DISK)
    model = manifest.get("model", BLITZ_MODEL)
    for asset in (kickstart, disk):
        if not Path(asset).exists():
            sys.exit(f"Blitz capture asset not found: {asset}")

    for cap in manifest["captures"]:
        cap_id = cap["id"]
        source = (unit_dir / cap["program"]).resolve().read_text()

        script = [{"action": "run_frames", "frames": BLITZ_BOOT_FRAMES}]
        # The BB2 startup requester ("OKEE DOKEE") is dismissed with Return.
        script += _amos_tap("return")
        script += [
            {"action": "run_frames", "frames": 10},
            {"action": "type_string", "text": source},
            {"action": "run_frames", "frames": BLITZ_TYPE_SETTLE},
        ]
        script += _blitz_compile_run()         # right-Amiga+X = Compile & Run
        script += expand_timeline_amiga(cap["timeline"], image_dir)

        script_path = capture_dir / f"{cap_id}.script.json"
        script_path.write_text(json.dumps(script, indent=1) + "\n")

        result = subprocess.run(
            [emu, "--headless", "--kickstart", kickstart, "--model", model,
             "--disk", disk, "--script", str(script_path)],
            capture_output=True, text=True)
        report_capture(cap, result)
        # Centre each screenshot in a clean border (the raw raster is off-centre).
        for action in cap["timeline"]:
            if "screenshot" in action:
                frame_screenshot(image_dir / action["screenshot"])


# --------------------------------------------------------------------------
# Shared
# --------------------------------------------------------------------------

def report_capture(cap: dict, result: subprocess.CompletedProcess) -> None:
    cap_id = cap["id"]
    if result.returncode != 0:
        print(f"  ✗ {cap_id}: emu exited {result.returncode}\n{result.stderr}")
        return
    try:
        obs = json.loads(result.stdout)
        rec = [o for o in obs.get("observations", [])
               if o.get("kind") in ("stop_audio_recording", "stop_video_recording")]
        extra = f"  {rec}" if rec else ""
    except json.JSONDecodeError:
        extra = ""
    outputs = cap.get("outputs") or _declared_outputs(cap["timeline"])
    print(f"  ✓ {cap_id} -> {', '.join(outputs)}{extra}")


def _declared_outputs(timeline: list[dict]) -> list[str]:
    keys = ("screenshot", "record_video", "record_audio")
    return [action[k] for action in timeline for k in keys if k in action]


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("manifest", type=Path)
    ap.add_argument("--emu", default=None, help="Path to the Emu198x binary")
    ap.add_argument("--keep-build", action="store_true",
                    help="Keep assembled .prg/.sna files (default: remove them)")
    args = ap.parse_args()

    manifest_path = args.manifest.resolve()
    manifest = json.loads(manifest_path.read_text())
    machine = manifest.get("machine", "commodore-64")
    if machine not in EMU_DEFAULTS:
        sys.exit(f"Unknown machine in manifest: {machine!r}")

    emu = resolve_emu(machine, args.emu)
    unit_dir = manifest_path.parent.parent  # capture/ lives inside the unit dir
    capture_dir = manifest_path.parent
    image_dir = REPO_ROOT / "website" / "public" / "images" / manifest["image_dir"]
    image_dir.mkdir(parents=True, exist_ok=True)

    print(f"Manifest : {manifest_path}")
    print(f"Machine  : {machine}")
    print(f"Emu      : {emu}")
    print(f"Images   : {image_dir}\n")

    if machine == "commodore-64":
        run_c64(manifest, capture_dir, unit_dir, image_dir, emu, args.keep_build)
    elif machine == "commodore-amiga":
        run_amiga(manifest, capture_dir, unit_dir, image_dir, emu, args.keep_build)
    elif machine == "commodore-amiga-blitz":
        run_blitz(manifest, capture_dir, unit_dir, image_dir, emu, args.keep_build)
    else:
        run_spectrum(manifest, capture_dir, unit_dir, image_dir, emu, args.keep_build)

    print("\nDone. Saved scripts:", capture_dir)


if __name__ == "__main__":
    main()
