# Underground Assault - Lesson 2: Adding the Player Ship

This lesson adds a sprite-based player ship to the NES game "Underground Assault".

## What You'll Learn

- NES sprite system and hardware sprites
- Controller input handling and button reading
- Sprite movement with smooth physics
- OAM (Object Attribute Memory) management
- Sprite DMA transfers for efficient rendering

## Building

```bash
make        # Build the ROM
make run    # Build and run in emulator
make clean  # Clean build files
```

Or manually:
```bash
ca65 underground-assault-02.s -o build/underground-assault-02.o
ld65 -C nes.cfg -o build/underground-assault-02.nes build/underground-assault-02.o
```

## Controls

- **D-Pad Up** - Move ship up
- **D-Pad Down** - Move ship down
- **D-Pad Left** - Move ship left
- **D-Pad Right** - Move ship right

## Features

- Hardware sprite-based player ship
- Smooth movement with configurable speed
- Boundary checking to keep ship on screen
- Preserved starfield animation from Lesson 1
- Authentic NES controller input handling
- Sprite DMA for efficient graphics updates

## Technical Details

**Sprite System:**
- Player ship uses hardware sprite 0
- 8x8 pixel sprite with custom graphics
- Stored in OAM at $0200
- Updated via DMA transfer during NMI

**Controller Input:**
- Standard NES controller reading via $4016
- Button states stored in zero page
- Strobe and shift method for all 8 buttons

**Movement System:**
- Configurable movement speed (PLAYER_SPEED = 2)
- Boundary checking prevents ship from leaving screen
- Smooth 60Hz movement synchronized with NMI

**Graphics:**
- Custom ship sprite pattern in CHR-ROM
- Orange/green color palette for player
- Sprite priority over background

## Files

- `underground-assault-02.s` - Main 6502 assembly source (ca65 format)
- `nes.cfg` - Linker configuration for ca65
- `Makefile` - Build automation
- `build/underground-assault-02.nes` - NES ROM file

## Requirements

- ca65/ld65 assembler (part of cc65 suite)
- FCEUX or other NES emulator
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 1 by adding:
- Interactive player ship with sprites
- Controller input handling
- Smooth movement physics
- OAM management and sprite DMA

Next lesson will add shooting mechanics and projectile systems!