#!/usr/bin/env bash
# Capture a screenshot from a Spectrum unit's .sna file using emu198x-spectrum
# in headless / script mode.
#
# Usage:
#   capture-spectrum-screenshot.sh <game-dir> <unit-number>
#
# Example:
#   capture-spectrum-screenshot.sh game-01-shadowkeep 1
#
# Resolves:
#   .sna input        code-samples/sinclair-zx-spectrum/<game-dir>/unit-NN/<game>.sna
#   .png output       website/public/images/sinclair-zx-spectrum/<game-dir>/unit-NN/screenshot.png
#
# Requires:
#   - emu198x-spectrum built at $EMU198X_BIN (default: target/release in $EMU198X)
#     For a fast headless build that skips winit/wgpu/muda:
#       cd $EMU198X && cargo build --release --no-default-features --bin emu198x-spectrum
#   - 48K ROM at the conventional path: $HOME/.emu198x/roms/sinclair-zx-spectrum-48k/48.rom
#     The binary's eager 48K boot picks it up from there automatically — no
#     `--rom` flag needed in script mode.
#   - .sna built first (run `make` in the unit's directory)
#
# What changed (2026-05-14):
# Previous pipeline used .tap + autoload-tape + wait-for-tape-stop. Emu198x's
# LoadSnapshot script step now accepts portable .sna / .z80 / .zip directly
# (commit ff02827, "LoadSnapshot: route .sna / .z80 / .zip through portable
# parsers"), so we skip the tape loader entirely: instant restore from the
# pasmonext-built .sna, no "Bytes: shadowkeep" header in the resulting PNG,
# and the capture finishes in tens of frames rather than thousands.

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <game-dir> <unit-number>" >&2
    exit 1
fi

GAME_DIR="$1"
UNIT="$(printf '%02d' "$2")"

# Game name = strip leading "game-NN-" from GAME_DIR
GAME_NAME="${GAME_DIR#game-*-}"
SNA_BASENAME="$GAME_NAME"

EMU198X="${EMU198X:-/Users/stevehill/Projects/198x/Emu198x}"
EMU198X_BIN="${EMU198X_BIN:-$EMU198X/target/release/emu198x-spectrum}"
SPECTRUM_ROM="${SPECTRUM_ROM:-$HOME/.emu198x/roms/sinclair-zx-spectrum-48k/48.rom}"
CODE198X="${CODE198X:-/Users/stevehill/Projects/198x/Code198x}"

SNA="$CODE198X/code-samples/sinclair-zx-spectrum/$GAME_DIR/unit-$UNIT/$SNA_BASENAME.sna"
OUT_DIR="$CODE198X/website/public/images/sinclair-zx-spectrum/$GAME_DIR/unit-$UNIT"
OUT="$OUT_DIR/screenshot.png"

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

# JSON script: restore the .sna directly into the live machine (skipping the
# tape-loader animation entirely), run a handful of frames so the code has
# time to execute and the screen to settle, save the PNG. All machine-state
# verbs live in this JSON; the binary's CLI flags only select the mode.
SCRIPT_TMP="$(mktemp -t emu198x-capture.XXXXXX.json)"
trap 'rm -f "$SCRIPT_TMP"' EXIT

cat > "$SCRIPT_TMP" <<EOF
[
  { "action": "load_snapshot",   "path": "$SNA" },
  { "action": "run_frames",      "frames": 10 },
  { "action": "save_screenshot", "path": "$OUT" }
]
EOF

"$EMU198X_BIN" --headless --script "$SCRIPT_TMP" >/dev/null

echo "captured: $OUT"
