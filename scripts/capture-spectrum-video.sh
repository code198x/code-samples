#!/usr/bin/env bash
# Capture a video from a Spectrum unit's .sna file using emu198x-spectrum
# in headless / script mode.
#
# Usage:
#   capture-spectrum-video.sh <game-dir> <unit-number> <name> [--frames N] [--settle N]
#
# Example:
#   capture-spectrum-video.sh game-01-shadowkeep 4 flash-demo --frames 400
#
# Resolves:
#   .sna input        code-samples/sinclair-zx-spectrum/<game-dir>/unit-NN/<game>.sna
#   .mp4 output       website/public/videos/sinclair-zx-spectrum/<game-dir>/unit-NN/<name>.mp4
#
# The recording captures both video and audio; the resulting MP4 is H.264 +
# AAC, browser-embeddable and ffprobe-clean. Emu198x spawns ffmpeg for the mux.
#
# Options:
#   --frames N    duration of the recording in native 50Hz frames
#                 (default: 500 = 10 seconds of PAL video)
#   --settle N    frames between snapshot restore and recording start, to let
#                 the program initialise and the screen settle (default: 10)
#
# Requires:
#   - emu198x-spectrum built at $EMU198X_BIN (default: target/release in $EMU198X)
#     For a fast headless build that skips winit/wgpu/muda:
#       cd $EMU198X && cargo build --release --no-default-features --bin emu198x-spectrum
#   - ffmpeg on PATH (Emu198x spawns it for the H.264 + AAC mux)
#   - 48K ROM at the conventional path: $HOME/.emu198x/roms/sinclair-zx-spectrum-48k/48.rom
#   - .sna built first (run `make` in the unit's directory)

set -euo pipefail

if [[ $# -lt 3 ]]; then
    echo "usage: $0 <game-dir> <unit-number> <name> [--frames N] [--settle N]" >&2
    exit 1
fi

GAME_DIR="$1"
UNIT="$(printf '%02d' "$2")"
NAME="$3"
shift 3

FRAMES=500
SETTLE=10
while [[ $# -gt 0 ]]; do
    case "$1" in
        --frames) FRAMES="$2"; shift 2 ;;
        --settle) SETTLE="$2"; shift 2 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

# Game name = strip leading "game-NN-" from GAME_DIR
GAME_NAME="${GAME_DIR#game-*-}"
SNA_BASENAME="$GAME_NAME"

EMU198X="${EMU198X:-/Users/stevehill/Projects/198x/Emu198x}"
EMU198X_BIN="${EMU198X_BIN:-$EMU198X/target/release/emu198x-spectrum}"
SPECTRUM_ROM="${SPECTRUM_ROM:-$HOME/.emu198x/roms/sinclair-zx-spectrum-48k/48.rom}"
CODE198X="${CODE198X:-/Users/stevehill/Projects/198x/Code198x}"

SNA="$CODE198X/code-samples/sinclair-zx-spectrum/$GAME_DIR/unit-$UNIT/$SNA_BASENAME.sna"
OUT_DIR="$CODE198X/website/public/videos/sinclair-zx-spectrum/$GAME_DIR/unit-$UNIT"
OUT="$OUT_DIR/$NAME.mp4"

if [[ ! -x "$EMU198X_BIN" ]]; then
    echo "error: emu198x-spectrum not found at $EMU198X_BIN" >&2
    echo "       build with: cd \$EMU198X && cargo build --release --bin emu198x-spectrum" >&2
    echo "       (or --no-default-features for a headless-only build that skips the GUI deps)" >&2
    exit 1
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "error: ffmpeg not on PATH (required for video capture)" >&2
    exit 1
fi

if [[ ! -f "$SPECTRUM_ROM" ]]; then
    echo "error: ROM not found at $SPECTRUM_ROM" >&2
    exit 1
fi

if [[ ! -f "$SNA" ]]; then
    echo "error: SNA not found at $SNA" >&2
    echo "       build it: (cd $(dirname "$SNA") && make)" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

# JSON script: restore the .sna directly into the live machine (skipping the
# tape-loader animation), settle, then record a fixed-length window. All
# machine-state verbs live in this JSON; the binary's CLI flags only select
# the mode.
SCRIPT_TMP="$(mktemp -t emu198x-capture.XXXXXX.json)"
trap 'rm -f "$SCRIPT_TMP"' EXIT

cat > "$SCRIPT_TMP" <<EOF
[
  { "action": "load_snapshot",         "path": "$SNA" },
  { "action": "run_frames",            "frames": $SETTLE },
  { "action": "start_video_recording", "path": "$OUT" },
  { "action": "run_frames",            "frames": $FRAMES },
  { "action": "stop_video_recording" }
]
EOF

"$EMU198X_BIN" --headless --script "$SCRIPT_TMP" >/dev/null

echo "captured: $OUT"
