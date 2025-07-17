# Cosmic Harvester - Lesson 2: Adding the Player Ship

This lesson adds a controllable player ship to the animated starfield from Lesson 1.

## What You'll Learn

- C64 sprite system and hardware sprites
- Keyboard input handling using the CIA chip
- Q/A/O/P control scheme (authentic C64-era layout)
- Combining animations (starfield + ship movement)
- Game loop structure

## Building

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

Or manually:
```bash
acme -f cbm -o build/cosmic-harvester-02.prg cosmic-harvester-02.asm
x64sc build/cosmic-harvester-02.prg
```

## Controls

```
    Q (Up)
      |
O (Left) -- P (Right)
      |
   A (Down)
```

## Features

- Animated twinkling starfield background
- Cyan retro-style ship with twin engines
- Smooth movement with boundary detection
- Vertical sync timing for smooth animation
- Classic Q/A/O/P keyboard controls

## Files

- `cosmic-harvester-02.asm` - Main assembly source code
- `Makefile` - Build automation
- `build/` - Compiled PRG files (generated)

## Requirements

- ACME cross-assembler
- VICE emulator (x64sc)
- Make (optional, for build automation)