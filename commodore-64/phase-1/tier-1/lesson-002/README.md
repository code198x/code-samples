# Pixel Patrol - Lesson 2: First Hardware Sprite

This lesson introduces the legendary C64 sprite system by creating your first hardware sprite that moves automatically across the screen.

## What You'll Learn

- C64 hardware sprite system fundamentals
- Sprite data format (24x21 pixels)
- VIC-II sprite registers and controls
- Sprite positioning and color
- Smooth animation with raster synchronization
- Sprite coordinate wraparound handling

## Building

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

Or manually:
```bash
acme -f cbm -o build/pixel-patrol-02.prg pixel-patrol-02.asm
x64sc build/pixel-patrol-02.prg
```

## What You'll See

- Blue background with white border (from Lesson 1)
- "PIXEL PATROL - LESSON 2" text display
- A yellow smiley face sprite moving smoothly across the screen
- Sprite wraps around from right to left automatically

## Features

- Your first hardware sprite (24x21 pixels)
- Automatic sprite movement animation
- Smooth raster-synchronized movement
- Sprite coordinate wraparound
- Yellow sprite color
- Combined with previous lesson's screen setup

## Files

- `pixel-patrol-02.asm` - Main assembly source code
- `Makefile` - Build automation
- `build/` - Compiled PRG files (generated)

## Requirements

- ACME cross-assembler
- VICE emulator (x64sc)
- Make (optional, for build automation)