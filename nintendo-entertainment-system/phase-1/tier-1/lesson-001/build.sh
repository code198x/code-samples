#!/usr/bin/env zsh
#
# Build NES ROM from assembly source
#
# Usage: ./build.sh

set -e

# Assemble
ca65 hello-nes.asm -o hello-nes.o

# Link
ld65 -C nes.cfg hello-nes.o -o hello-nes.nes

# Clean up object file
rm hello-nes.o

echo "✓ Built: hello-nes.nes"
