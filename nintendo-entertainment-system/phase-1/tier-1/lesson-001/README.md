# Underground Assault - Lesson 1: Creating Your First Game World

This lesson creates an animated starfield for the NES game "Underground Assault".

## What You'll Learn

- NES PPU (Picture Processing Unit) basics
- Nametable and pattern table organization
- 6502 assembly for the NES
- NMI (Non-Maskable Interrupt) timing
- Creating animated backgrounds with palette cycling

## Building

```bash
make        # Build the ROM
make run    # Build and run in emulator
make clean  # Clean build files
```

Or manually:
```bash
ca65 underground-assault-01.s -o build/underground-assault-01.o
ld65 -C nes.cfg -o build/underground-assault-01.nes build/underground-assault-01.o
```

## Features

- Black background with 10 twinkling stars
- Stars cycle through white, light gray, light blue, and light purple
- Synchronized to 60Hz NMI timing
- Uses background tiles for star graphics
- Palette-based color animation

## Technical Details

The NES display system:
- PPU renders 256x240 pixels (NTSC)
- Nametables hold 32x30 tiles (8x8 pixels each)
- Pattern tables store tile graphics
- Palette updates during NMI for smooth animation
- 60Hz refresh rate on NTSC systems

## Files

- `underground-assault-01.s` - Main 6502 assembly source (ca65 format)
- `nes.cfg` - Linker configuration for ca65
- `Makefile` - Build automation
- `build/underground-assault-01.nes` - NES ROM file

## Requirements

- ca65/ld65 assembler (part of cc65 suite)
- FCEUX or other NES emulator
- Make (optional, for build automation)