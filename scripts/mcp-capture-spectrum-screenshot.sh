#!/usr/bin/env bash
# Capture a Spectrum unit screenshot by driving emu198x-spectrum --mcp
# over stdio JSON-RPC. Proof of concept for Emu198x's SOLID criterion 5
# ("MCP server functional, exercised by Code198x"); same CLI surface
# as capture-spectrum-screenshot.sh but uses MCP rather than the
# --script JSON-file transport.
#
# Usage:
#   mcp-capture-spectrum-screenshot.sh <game-dir> <unit-number>
#
# Example:
#   mcp-capture-spectrum-screenshot.sh game-01-shadowkeep 14
#
# Resolves:
#   .tap input        code-samples/sinclair-zx-spectrum/<game-dir>/unit-NN/<game>.tap
#   .png output       website/public/images/sinclair-zx-spectrum/<game-dir>/unit-NN/screenshot.png
#
# Requires:
#   - emu198x-spectrum built at $EMU198X_BIN (default: target/release in $EMU198X)
#   - Python 3 on PATH (used to walk the JSON-RPC responses)
#   - 48K ROM at the conventional path
#   - .tap built first (run `make` in the unit's directory)

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <game-dir> <unit-number>" >&2
    exit 1
fi

GAME_DIR="$1"
UNIT="$(printf '%02d' "$2")"
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

if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 not on PATH" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

# JSON-RPC stream. Newline-delimited per the MCP stdio transport.
# initialize → notifications/initialized → tools/call×5 (load_media,
# autoload_tape, wait for tape stop, settle frames, save_screenshot).
REQUESTS_FILE="$(mktemp -t mcp-screenshot.XXXXXX.jsonl)"
RESPONSES_FILE="$(mktemp -t mcp-screenshot-out.XXXXXX.jsonl)"
trap 'rm -f "$REQUESTS_FILE" "$RESPONSES_FILE"' EXIT

cat > "$REQUESTS_FILE" <<EOF
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"code198x-mcp-screenshot","version":"0"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"load_media","arguments":{"slot":"tape-1","kind":"tape","path":"$TAP"}}}
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"autoload_tape","arguments":{"slot":"tape-1","max_boot_frames":250}}}
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"wait_for_query_bool","arguments":{"path":"spectrum.tape.playing","value":false,"max_frames":2000}}}
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"run_frames","arguments":{"frames":100}}}
{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"save_screenshot","arguments":{"path":"$OUT"}}}
EOF

"$EMU198X_BIN" --mcp <"$REQUESTS_FILE" >"$RESPONSES_FILE"

# Walk the responses; surface any JSON-RPC error or tool-execution
# error (isError: true) as a non-zero exit.
python3 - "$RESPONSES_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        obj = json.loads(line)
        rid = obj.get("id")
        err = obj.get("error")
        if err:
            print(f"json-rpc error (id={rid}): {err.get('message')}", file=sys.stderr)
            sys.exit(2)
        result = obj.get("result")
        if isinstance(result, dict) and result.get("isError"):
            text = result.get("content", [{}])[0].get("text", "<no text>")
            print(f"tool error (id={rid}): {text}", file=sys.stderr)
            sys.exit(2)
PY

echo "captured: $OUT"
