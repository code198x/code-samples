#!/bin/bash

# Build script for ZX Spectrum Pixel Pulse examples
# Requires PASMO assembler

if [ $# -eq 0 ]; then
    echo "Usage: $0 <source.z80>"
    echo "Example: $0 complete.z80"
    exit 1
fi

SOURCE="$1"
BASENAME=$(basename "$SOURCE" .z80)

echo "Building $SOURCE..."

# Check if PASMO is installed
if ! command -v pasmo &> /dev/null; then
    echo "PASMO assembler not found. Install with:"
    echo "  brew install pasmo"
    exit 1
fi

# Assemble to TAP file for emulators
pasmo --tap "$SOURCE" "${BASENAME}.tap"

if [ $? -eq 0 ]; then
    echo "Successfully created ${BASENAME}.tap"
    echo "Load in Fuse emulator with: fuse ${BASENAME}.tap"
    
    # Also create binary for advanced use
    pasmo "$SOURCE" "${BASENAME}.bin"
    echo "Binary file: ${BASENAME}.bin"
    
    # Create SNA snapshot if possible (requires additional tools)
    if command -v makesna &> /dev/null; then
        makesna -o 32768 "${BASENAME}.bin" "${BASENAME}.sna"
        echo "Snapshot file: ${BASENAME}.sna"
    fi
else
    echo "Assembly failed!"
    exit 1
fi