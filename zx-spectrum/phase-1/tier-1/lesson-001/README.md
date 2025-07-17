# Quantum Shatter - Lesson 1: Creating Your First Game World

This lesson creates an animated starfield for the ZX Spectrum game "Quantum Shatter".

## What You'll Learn

- ZX Spectrum screen memory layout ($4000-$57FF)
- Attribute memory for colors ($5800-$5AFF)
- Z80 assembly basics and syntax
- Using HALT for 50Hz timing
- Creating animated effects with attribute cycling

## Building

```bash
make        # Build the TAP file
make run    # Build and run in emulator
make clean  # Clean build files
```

Or manually:
```bash
sjasmplus quantum-shatter-01.asm
```

## Features

- Black screen with 10 twinkling stars
- Stars cycle through white, bright white, cyan, and yellow
- Synchronized to 50Hz screen refresh using HALT
- Simple pixel plotting for star positions
- Attribute-based color animation

## Technical Details

The ZX Spectrum has a unique display system:
- Bitmap display at $4000-$57FF (non-linear addressing)
- Attribute memory at $5800-$5AFF (8x8 blocks)
- Each attribute byte controls: FLASH, BRIGHT, PAPER, INK
- Animation is achieved by changing attribute values

## Files

- `quantum-shatter-01.asm` - Main Z80 assembly source
- `Makefile` - Build automation
- `build/quantum-shatter-01.tap` - TAP file for loading into Spectrum

## Requirements

- sjasmplus assembler
- Fuse or other ZX Spectrum emulator
- Make (optional, for build automation)