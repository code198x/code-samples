#!/usr/bin/env bash
# Capture an audio recording (WAV) from a Spectrum unit's .sna file using
# emu198x-spectrum in headless / script mode.
#
# Usage:
#   capture-spectrum-audio.sh <game-dir> <unit-number> <name> [--frames N] [--settle N]
#
# Example:
#   capture-spectrum-audio.sh game-01-shadowkeep 8 title-theme --frames 3000
#
# Resolves:
#   .sna input        code-samples/sinclair-zx-spectrum/<game-dir>/unit-NN/<game>.sna
#   .wav output       website/public/audio/sinclair-zx-spectrum/<game-dir>/unit-NN/<name>.wav
#
# Captures the audio stream only (beeper, or AY on 128K builds), written as a
# 16-bit PCM WAV. No video, no ffmpeg — the WAV is written directly.
#
# Options:
#   --frames N    duration of the capture in native 50Hz frames
#                 (default: 1500 = 30 seconds, enough for a beeper title loop)
#   --settle N    frames between snapshot restore and capture start, to skip
#                 any silent boot beats (default: 0)
#
# Requires:
#   - emu198x-spectrum built at $EMU198X_BIN (default: target/release in $EMU198X)
#     For a fast headless build that skips winit/wgpu/muda:
#       cd $EMU198X && cargo build --release --no-default-features --bin emu198x-spectrum
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

FRAMES=1500
SETTLE=0
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
OUT_DIR="$CODE198X/website/public/audio/sinclair-zx-spectrum/$GAME_DIR/unit-$UNIT"
OUT="$OUT_DIR/$NAME.wav"

if [[ ! -x "$EMU198X_BIN" ]]; then
    echo "error: emu198x-spectrum not found at $EMU198X_BIN" >&2
    echo "       build with: cd \$EMU198X && cargo build --release --bin emu198x-spectrum" >&2
    echo "       (or --no-default-features for a headless-only build that skips the GUI deps)" >&2
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

# JSON script: restore the .sna, optionally settle past silent boot beats,
# run the capture window (the binary captures audio during run automatically),
# then write the accumulated buffer to a WAV.
SCRIPT_TMP="$(mktemp -t emu198x-capture.XXXXXX.json)"
trap 'rm -f "$SCRIPT_TMP"' EXIT

cat > "$SCRIPT_TMP" <<EOF
[
  { "action": "load_snapshot",      "path": "$SNA" },
  { "action": "run_frames",         "frames": $SETTLE },
  { "action": "run_frames",         "frames": $FRAMES },
  { "action": "save_audio_capture", "path": "$OUT" }
]
EOF

"$EMU198X_BIN" --headless --script "$SCRIPT_TMP" >/dev/null

echo "captured: $OUT"
