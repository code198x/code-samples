# Pixel Patrol - Lesson 3: Joystick Control

This lesson adds joystick and keyboard control to your sprite, making it fully interactive and responsive to player input.

## What You'll Learn

- CIA chip input handling for joystick and keyboard
- Joystick input bit patterns and reading
- Keyboard matrix scanning techniques
- Responsive sprite movement with boundary checking
- Game loop structure for interactive programs
- Professional input handling methods

## Building

```bash
make        # Build the PRG file
make run    # Build and run in VICE
make disk   # Create D64 disk image
make clean  # Clean build files
```

Or manually:
```bash
acme -f cbm -o build/pixel-patrol-03.prg --cpu 6502 --format cbm pixel-patrol-03.asm
```

## Controls

- **Joystick Port 2** - Move sprite in all directions
- **Q** - Move sprite up
- **A** - Move sprite down  
- **O** - Move sprite left
- **P** - Move sprite right

## Features

- Interactive sprite control with joystick or keyboard
- Yellow spaceship sprite with smooth movement
- Boundary checking prevents sprite from leaving screen
- Responsive controls with 2-pixel movement per frame
- Support for both joystick and QAOP keyboard controls
- Instructions displayed on screen
- Smooth 50Hz game loop timing

## Technical Details

**Input System:**
- CIA1 chip ($DC00/$DC01) for joystick and keyboard input
- Joystick Port 2 connected to CIA1 Port A ($DC00)
- Keyboard matrix scanning via CIA1 for QAOP keys
- Bit patterns: 0=Up, 1=Down, 2=Left, 3=Right, 4=Fire

**Movement System:**
- 2-pixel movement per frame for smooth, responsive control
- Boundary checking: X range 24-296, Y range 50-200
- Proper handling of sprite X coordinate MSB for wide screen
- Raster synchronization for smooth animation

**Sprite Control:**
- Yellow spaceship sprite (24x21 pixels)
- Centered starting position (160, 120)
- Hardware sprite system for flicker-free movement
- Sprite data stored at $0340, pointer at $07F8

## What You'll See

When you run this program, you'll experience:
- Blue background with white border (from previous lessons)
- "PIXEL PATROL - LESSON 3" title display
- "USE JOYSTICK OR QAOP KEYS" instruction text
- Yellow spaceship sprite that responds to your input
- Smooth, responsive movement in all directions
- Sprite stays within screen boundaries

## Files

- `pixel-patrol-03.asm` - Main 6502 assembly source
- `Makefile` - Build automation
- `build/pixel-patrol-03.prg` - C64 executable
- `build/pixel-patrol-03.d64` - C64 disk image

## Requirements

- ACME cross-assembler (6502)
- VICE C64 emulator (optional)
- c1541 tool for disk image creation
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 2 by adding:
- Complete joystick and keyboard input handling
- Interactive sprite movement system
- Boundary checking and collision detection
- Professional game loop structure

Next lesson will add projectile firing and more game mechanics!

## Technical Notes

**CIA Chip Architecture:**
- CIA1 handles keyboard matrix and joystick input
- CIA2 handles serial bus and user port
- Each CIA has two 8-bit I/O ports (Port A and Port B)
- Keyboard matrix uses row/column scanning technique

**Input Handling Best Practices:**
- Combine joystick and keyboard for maximum compatibility
- Use bit masking for efficient input processing
- Implement proper boundary checking for sprite movement
- Synchronize input reading with display refresh

This lesson demonstrates professional input handling techniques used in commercial C64 games, providing the foundation for creating responsive, interactive programs.