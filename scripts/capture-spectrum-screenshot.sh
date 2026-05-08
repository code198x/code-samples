#!/usr/bin/env bash
# Capture a screenshot from a Spectrum unit's .tap file using emu198x-spectrum
# in headless / script mode.
#
# Usage:
#   capture-spectrum-screenshot.sh <game-dir> <unit-number>
#
# Example:
#   capture-spectrum-screenshot.sh game-01-shadowkeep 1
#
# Resolves:
#   .tap input        code-samples/sinclair-zx-spectrum/<game-dir>/unit-NN/<game>.tap
#   .png output       website/public/images/sinclair-zx-spectrum/<game-dir>/unit-NN/screenshot.png
#
# Requires:
#   - emu198x-spectrum built at $EMU198X_BIN (default: target/release in $EMU198X)
#     For a fast headless build that skips winit/wgpu/muda:
#       cd $EMU198X && cargo build --release --no-default-features --bin emu198x-spectrum
#   - 48K ROM at the conventional path: $HOME/.emu198x/roms/sinclair-zx-spectrum-48k/48.rom
#     The binary's eager 48K boot picks it up from there automatically — no
#     `--rom` flag needed in script mode.
#   - .tap built first (run `make` in the unit's directory)
#
# Why script mode (not the old --tape/--autoload-tape/--screenshot/--frames
# flag soup): the new emu198x-spectrum binary expresses machine-state verbs
# as JSON script steps. Flags can't carry ordering or composition; script
# steps can, and the same vocabulary serves the upcoming MCP server.

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <game-dir> <unit-number>" >&2
    exit 1
fi

GAME_DIR="$1"
UNIT="$(printf '%02d' "$2")"

# Game name = strip leading "game-NN-" from GAME_DIR
GAME_NAME="${GAME_DIR#game-*-}"
TAP_BASENAME="$GAME_NAME"

EMU198X="${EMU198X:-/Users/stevehill/Projects/Emu198x}"
EMU198X_BIN="${EMU198X_BIN:-$EMU198X/target/release/emu198x-spectrum}"
SPECTRUM_ROM="${SPECTRUM_ROM:-$HOME/.emu198x/roms/sinclair-zx-spectrum-48k/48.rom}"
CODE198X="${CODE198X:-/Users/stevehill/Projects/Code198x}"

TAP="$CODE198X/code-samples/sinclair-zx-spectrum/$GAME_DIR/unit-$UNIT/$TAP_BASENAME.tap"
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

if [[ ! -f "$TAP" ]]; then
    echo "error: TAP not found at $TAP" >&2
    echo "       build it: (cd $(dirname "$TAP") && make)" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

# JSON script: load tape into slot tape-1, autoload BASIC, wait for
# tape-stop, run a few extra frames so the screen settles, save PNG.
# All machine-state verbs live in this JSON now — the binary's surviving
# CLI flags are for mode selection (--headless / --script / --mcp) and
# convenience aliases.
SCRIPT_TMP="$(mktemp -t emu198x-capture.XXXXXX.json)"
trap 'rm -f "$SCRIPT_TMP"' EXIT

cat > "$SCRIPT_TMP" <<EOF
[
  { "action": "load_media",            "slot": "tape-1", "kind": "tape", "path": "$TAP" },
  { "action": "autoload_tape",         "slot": "tape-1", "max_boot_frames": 250 },
  { "action": "wait_for_query_bool",   "path": "spectrum.tape.playing", "value": false, "max_frames": 2000 },
  { "action": "run_frames",            "frames": 100 },
  { "action": "save_screenshot",       "path": "$OUT" }
]
EOF

"$EMU198X_BIN" --headless --script "$SCRIPT_TMP" >/dev/null

echo "captured: $OUT"
