#!/bin/bash

# Build script for NES Byte Blaster examples
# Requires CC65 development tools

if [ $# -eq 0 ]; then
    echo "Usage: $0 <source.s>"
    echo "Example: $0 complete.s"
    exit 1
fi

SOURCE="$1"
BASENAME=$(basename "$SOURCE" .s)

echo "Building $SOURCE..."

# Check if CC65 is installed
if ! command -v ca65 &> /dev/null; then
    echo "CC65 not found. Install with:"
    echo "  brew install cc65"
    exit 1
fi

# Check if required files exist
if [ ! -f "nes.inc" ]; then
    echo "Error: nes.inc not found"
    exit 1
fi

if [ ! -f "graphics.chr" ]; then
    echo "Warning: graphics.chr not found - creating placeholder"
    # Create a minimal 8KB CHR file filled with simple patterns
    dd if=/dev/zero of=graphics.chr bs=8192 count=1 2>/dev/null
fi

# Create NES linker configuration if it doesn't exist
if [ ! -f "nes.cfg" ]; then
    echo "Creating nes.cfg linker configuration..."
    cat > nes.cfg << 'EOF'
MEMORY {
    ZP:     start = $0000, size = $0100, type = rw, file = "";
    HEADER: start = $0000, size = $0010, type = ro, file = %O, fill = yes;
    PRG:    start = $8000, size = $8000, type = ro, file = %O, fill = yes;
    CHR:    start = $0000, size = $2000, type = ro, file = %O, fill = yes;
}

SEGMENTS {
    ZEROPAGE: load = ZP, type = zp;
    HEADER:   load = HEADER, type = ro;
    CODE:     load = PRG, type = ro, start = $8000;
    VECTORS:  load = PRG, type = ro, start = $FFFA;
    CHARS:    load = CHR, type = ro;
}
EOF
fi

# Assemble source file
ca65 "$SOURCE" -o "${BASENAME}.o"

if [ $? -ne 0 ]; then
    echo "Assembly failed!"
    exit 1
fi

# Link to create NES ROM
ld65 "${BASENAME}.o" -C nes.cfg -o "${BASENAME}.nes"

if [ $? -eq 0 ]; then
    echo "Successfully created ${BASENAME}.nes"
    echo "ROM size: $(wc -c < "${BASENAME}.nes") bytes"
    
    # Check ROM size (should be around 40KB for NROM)
    SIZE=$(wc -c < "${BASENAME}.nes")
    if [ $SIZE -eq 40976 ]; then
        echo "✓ Correct NROM size (32KB PRG + 8KB CHR + 16 byte header)"
    else
        echo "⚠ Unexpected ROM size (expected 40976 bytes)"
    fi
    
    # Suggest emulators
    echo ""
    echo "Run with an NES emulator:"
    echo "  mesen ${BASENAME}.nes     (recommended)"
    echo "  fceux ${BASENAME}.nes     (alternative)"
    echo "  nestopia ${BASENAME}.nes  (alternative)"
    
    # Clean up object file
    rm -f "${BASENAME}.o"
else
    echo "Linking failed!"
    rm -f "${BASENAME}.o"
    exit 1
fi