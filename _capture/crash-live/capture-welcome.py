#!/usr/bin/env python3
"""Capture the CRASH! Live welcome: a 48K typing its own greeting, then running it.

Produces one MP4 of the whole session. The typing is left at real speed here;
the website's copy speeds that stretch up in post, because the colour cycle
afterwards has to keep its true rhythm and the typing does not.

    python3 capture-welcome.py --emulator PATH --rom PATH --out welcome.mp4
"""

import argparse
import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from typewriter import script_for  # noqa: E402

HERE = Path(__file__).resolve().parent


def build_script(listing, out_mp4, run_frames):
    steps = [
        {"action": "wait_for_boot", "max_frames": 800},
        # Boot detection fires while the copyright banner is still up; one
        # ENTER clears it and exposes the K prompt the typing needs.
        {"action": "press_key", "key": "Enter", "hold_frames": 4},
        {"action": "run_frames", "frames": 30},
        {"action": "start_video_recording", "path": str(out_mp4)},
    ]
    steps += script_for(listing)
    steps += script_for('RUN\n')
    steps += [
        {"action": "run_frames", "frames": run_frames},
        {"action": "stop_video_recording"},
    ]
    return steps


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--emulator', required=True, help='path to emu198x-spectrum')
    ap.add_argument('--rom', required=True, help='path to the 48K ROM')
    ap.add_argument('--listing', default=HERE / 'welcome.bas')
    ap.add_argument('--out', default=HERE / 'welcome.mp4')
    ap.add_argument('--run-frames', type=int, default=700,
                    help='frames of the running program to record (50 = 1s)')
    args = ap.parse_args()

    listing = Path(args.listing).read_text()
    steps = build_script(listing, Path(args.out).resolve(), args.run_frames)

    # The script is written next to the listing on purpose: read it and you
    # can see every key that was pressed to reach the recorded state.
    script_path = HERE / 'welcome.script.json'
    script_path.write_text(json.dumps(steps, indent=1) + '\n')

    result = subprocess.run(
        [args.emulator, '--rom', str(args.rom), '--script', str(script_path)],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        sys.exit(f'emulator failed:\n{result.stderr or result.stdout}')
    print(f'wrote {args.out}')


if __name__ == '__main__':
    main()
