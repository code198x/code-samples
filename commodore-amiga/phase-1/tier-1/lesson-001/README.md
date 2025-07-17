# Turbo Horizon - Lesson 1: Creating Your First Game World

This lesson creates an animated starfield for the Amiga game "Turbo Horizon".

## What You'll Learn

- Amiga custom chip architecture (Agnus, Denise, Paula)
- Copper list programming for display control
- Bitplane graphics fundamentals
- 68000 assembly for the Amiga
- Hardware-level programming without OS
- Creating smooth animations at 50Hz

## Building

```bash
make        # Build the executable
make run    # Instructions for running
make clean  # Clean build files
```

Or manually:
```bash
vasmm68k_mot -Fhunkexe -nosym -kick1hunks -o build/turbo-horizon-01 turbo-horizon-01.s
```

## Features

- Black background with 10 white pixels as stars
- Stars cycle through white, light gray, light blue, and light purple
- Hardware-synchronized 50Hz animation using raster position
- Direct hardware access (no OS calls during main loop)
- Copper list for display setup
- Single bitplane for simplicity

## Technical Details

The Amiga's custom chip architecture:
- **Agnus**: DMA controller, handles bitplane data fetching
- **Denise**: Display encoder, converts bitplane data to video
- **Paula**: Audio and I/O, not used in this lesson
- **Copper**: Co-processor for display timing and register changes

Display system:
- Planar graphics (separate bitplanes for each color bit)
- Up to 5 bitplanes in low-res (32 colors)
- Copper list controls display parameters per scanline
- 50Hz PAL timing (312 scanlines)

## Files

- `turbo-horizon-01.s` - Main 68000 assembly source
- `Makefile` - Build automation
- `build/turbo-horizon-01` - Amiga executable (Hunk format)

## Requirements

- vasm assembler (68k Motorola syntax)
- FS-UAE or WinUAE emulator
- Kickstart 1.3 ROM (for emulator)
- ADF creation tools (to make bootable disk)
- Make (optional, for build automation)

## Running the Program

1. Build the executable with `make`
2. Create an ADF disk image containing the executable
3. Boot the emulator with the ADF
4. From CLI/Shell: `turbo-horizon-01`
5. Click left mouse button to exit

## Memory Map

- `$DFF000-$DFF1FF` - Custom chip registers
- `$000000-$080000` - Chip RAM (512KB on A500)
- Our code loads wherever AmigaDOS places it