# Quantum Shatter - Lesson 2: Adding the Player Ship

This lesson adds a controllable player ship to the ZX Spectrum game "Quantum Shatter".

## What You'll Learn

- Character-based sprite system on the ZX Spectrum
- Keyboard input handling using port reading
- Movement physics with boundary checking
- Screen and attribute memory calculations
- Game loop structure with input, update, and draw phases

## Building

```bash
make        # Build the TAP file
make run    # Build and run in emulator
make clean  # Clean build files
```

Or manually:
```bash
sjasmplus quantum-shatter-02.asm
```

## Controls

- **Q** - Move ship up
- **A** - Move ship down
- **O** - Move ship left
- **P** - Move ship right

## Features

- Custom ship character created in memory
- Smooth movement with boundary checking
- Ship appears in cyan color
- Preserved starfield animation from Lesson 1
- Authentic QAOP control scheme from the 1980s

## Technical Details

**Character Graphics:**
- Custom 8x8 pixel ship character stored at $4000 + (SHIP_CHAR * 8)
- Character mode graphics for simple sprite display
- Attribute memory for color control

**Input System:**
- Direct keyboard matrix reading via ports
- Q/A keys: $FEFE/$FDFE ports
- O/P keys: $DFFE port
- Bit manipulation for key detection

**Movement System:**
- Boundary checking prevents ship from leaving screen
- Efficient screen position calculation
- Separate attribute position calculation for colors

## Files

- `quantum-shatter-02.asm` - Main Z80 assembly source
- `Makefile` - Build automation
- `build/quantum-shatter-02.tap` - TAP file for loading into Spectrum

## Requirements

- sjasmplus assembler
- Fuse or other ZX Spectrum emulator
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 1 by adding:
- Player ship with custom graphics
- Responsive keyboard controls
- Movement boundaries
- Game loop structure

Next lesson will add shooting mechanics and collision detection!