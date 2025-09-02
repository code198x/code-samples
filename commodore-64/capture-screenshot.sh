#!/bin/bash
# Automated screenshot capture for C64 programs using VICE
# Usage: ./capture-screenshot.sh program.prg output.png

if [ $# -ne 2 ]; then
    echo "Usage: $0 <program.prg> <output.png>"
    exit 1
fi

PRG_FILE="$1"
OUTPUT_FILE="$2"

# Get absolute paths
PRG_PATH=$(realpath "$PRG_FILE")
OUTPUT_PATH=$(realpath "$OUTPUT_FILE" 2>/dev/null || echo "$(pwd)/$OUTPUT_FILE")
OUTPUT_DIR=$(dirname "$OUTPUT_PATH")
OUTPUT_NAME=$(basename "$OUTPUT_PATH")

# Create temp directory for VICE to run in
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "Running $PRG_FILE for screenshot..."
echo "Working directory: $TEMP_DIR"

# Run emulator with exitscreenshot flag
# VICE will save the screenshot in current directory
timeout 2 x64sc \
    -autostartprgmode 1 \
    -autostart "$PRG_PATH" \
    -exitscreenshot "$OUTPUT_NAME" \
    -warp \
    +sound \
    2>/dev/null || true

# Check if screenshot was created in temp directory
if [ -f "$OUTPUT_NAME" ]; then
    # Move to final destination
    mv "$OUTPUT_NAME" "$OUTPUT_PATH"
    echo "Screenshot saved as $OUTPUT_PATH"
    ls -lh "$OUTPUT_PATH" | awk '{print "Size: " $5}'
else
    echo "Looking for VICE auto-generated screenshots..."
    # VICE might use its own naming
    SCREENSHOT=$(ls -t *.png 2>/dev/null | head -1)
    
    if [ -n "$SCREENSHOT" ]; then
        mv "$SCREENSHOT" "$OUTPUT_PATH"
        echo "Screenshot saved as $OUTPUT_PATH"
        ls -lh "$OUTPUT_PATH" | awk '{print "Size: " $5}'
    else
        echo "Error: No screenshot was generated"
        echo "Files in temp directory:"
        ls -la
    fi
fi

# Clean up temp directory
cd - > /dev/null
rm -rf "$TEMP_DIR"