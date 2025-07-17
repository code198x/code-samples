# Turbo Horizon - Lesson 2: Adding the Player Ship

This lesson adds a hardware sprite-based player ship to the Amiga game "Turbo Horizon".

## What You'll Learn

- Amiga hardware sprite system and sprite DMA
- Joystick input handling via hardware registers
- 16x16 sprite graphics with two bitplanes
- Copper list sprite management
- Real-time sprite position updates
- Sprite collision boundaries

## Building

```bash
make        # Build the executable
make run    # Build and prepare for emulator
make clean  # Clean build files
```

Or manually:
```bash
vasmm68k_mot -Fhunkexe -nosym -kick1hunks -o build/turbo-horizon-02 turbo-horizon-02.s
```

## Controls

- **Joystick Up** - Move ship up
- **Joystick Down** - Move ship down
- **Joystick Left** - Move ship left
- **Joystick Right** - Move ship right
- **Left Mouse Button** - Exit program

## Features

- Hardware sprite 0 for player ship
- 16x16 pixel sprite with 2 bitplanes (4 colors)
- Smooth joystick movement with configurable speed
- Boundary checking to keep ship on screen
- Preserved starfield animation from Lesson 1
- Copper list management for sprites
- Real-time position updates

## Technical Details

**Hardware Sprites:**
- Uses sprite 0 (registers SPR0PTH/SPR0PTL, SPR0POS, SPR0CTL)
- 16x16 pixels with 2 bitplanes
- Orange and green color scheme
- Attached sprite mode for 4 colors

**Joystick Input:**
- Direct hardware register reading (JOY1DAT)
- XOR decoding for direction detection
- Boundary checking for screen limits

**Sprite Management:**
- Copper list sets sprite pointers
- Real-time position updates via SPR0POS/SPR0CTL
- Automatic sprite DMA handling

**Graphics:**
- Custom 16x16 racing ship design
- Two bitplanes for orange body and green details
- Sprite priority over background

## Files

- `turbo-horizon-02.s` - Main 68000 assembly source
- `Makefile` - Build automation
- `make-adf.sh` - ADF creation script
- `create_adf.py` - Python ADF fallback
- `TOOLS.md` - Tool installation guide
- `build/turbo-horizon-02` - Amiga executable

## Requirements

- vasmm68k_mot (68k assembler)
- amitools (optional, for proper ADF creation)
- FS-UAE or WinUAE emulator
- Kickstart ROM for emulator
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 1 by adding:
- Interactive player ship using hardware sprites
- Joystick input handling
- Smooth movement physics
- Real-time sprite management

Next lesson will add shooting mechanics and sprite-based projectiles!