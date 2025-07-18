# Underground Assault - Lesson 3: Plasma Cannons

This lesson adds a complete sprite-based projectile system to the NES game "Underground Assault", allowing the player to fire plasma bolts using hardware sprites.

## What You'll Learn

- Hardware sprite-based projectile systems on the NES
- Object pooling for multiple simultaneous bullets
- OAM (Object Attribute Memory) management
- Sprite DMA transfers for smooth animation
- Frame-based collision detection foundations
- Controller input handling for firing

## Building

```bash
make        # Build the NES file
make run    # Build and run in FCEUX emulator
make test   # Build and verify NES file creation
make clean  # Clean build files
```

Or manually:
```bash
ca65 -g -o build/underground-assault-03.o underground-assault-03.s
ld65 -C nes.cfg -o build/underground-assault-03.nes build/underground-assault-03.o
```

## Controls

- **D-Pad Up** - Move ship up
- **D-Pad Down** - Move ship down  
- **D-Pad Left** - Move ship left
- **D-Pad Right** - Move ship right
- **A Button** - Fire plasma bolt

## Features

- Hardware sprite-based player ship from Lesson 2
- Up to 8 simultaneous plasma bolts using hardware sprites
- Custom bullet sprite with distinctive plasma appearance
- Bullet cooldown system (prevents spamming)
- Automatic bullet cleanup when off-screen
- Preserved starfield animation from Lesson 1
- Smooth 60Hz game loop timing with sprite DMA

## Technical Details

**Projectile System:**
- Object pool of 8 bullets maximum
- Hardware sprite rendering for smooth movement
- Bright white/cyan bullet color for high visibility
- 4-pixel-per-frame movement speed
- Automatic sprite deactivation when bullets leave screen

**Memory Layout:**
- Bullet data stored in parallel arrays in zero page
- `bullet_active[]` - Activity flags (0/1)
- `bullet_x[]` - X coordinates
- `bullet_y[]` - Y coordinates  
- OAM sprites 1-8 reserved for bullets (sprite 0 is player)

**Input System:**
- A button detection for firing
- 8-frame cooldown timer prevents rapid-fire abuse
- Continues to support all movement controls from Lesson 2

**Sprite System:**
- Player uses sprite 0
- Bullets use sprites 1-8
- Automatic sprite DMA transfer each frame
- Off-screen sprite hiding by moving to Y position $FE

## Game Mechanics

**Firing System:**
- Press A button to fire plasma bolt
- 8-frame cooldown between shots (about 1/7 second at 60Hz)
- Bullets spawn centered on player ship position
- Bullets travel upward at 4 pixels per frame

**Bullet Lifecycle:**
1. **Spawn** - Find free slot in object pool
2. **Move** - Update position each frame
3. **Draw** - Update OAM sprite data
4. **Cleanup** - Hide sprite when off-screen

**Visual Effects:**
- Bright plasma bolts with distinctive sprite design
- Smooth 60Hz sprite movement via hardware acceleration
- Sprite DMA for flicker-free animation

## Files

- `underground-assault-03.s` - Main 6502 assembly source
- `Makefile` - Build automation
- `build/underground-assault-03.nes` - NES ROM file
- `build/underground-assault-03.o` - Object file

## Requirements

- ca65/ld65 assembler and linker (part of cc65 suite)
- FCEUX NES emulator (recommended)
- Nestopia or Mesen emulator (alternatives)
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 2 by adding:
- Complete sprite-based projectile firing system
- Object pooling for efficient sprite management
- OAM sprite manipulation and DMA transfers
- Frame-based timing for smooth animation
- Controller input handling for combat actions

Next lesson will add enemy ships and collision detection!

## Technical Notes

**Hardware Sprite Advantages:**
- Smooth movement without background corruption
- Automatic priority handling by PPU
- Flicker-free animation with sprite DMA
- Efficient rendering without CPU intervention

**NES Specific Features:**
- Uses hardware sprites for all projectiles
- OAM (Object Attribute Memory) management
- Sprite DMA transfers during VBlank
- 60Hz frame timing via NMI interrupts

**Performance Considerations:**
- Object pooling prevents sprite allocation overhead
- Sprite DMA transfers all sprite data in one operation
- Parallel arrays for cache-friendly bullet data access
- Efficient sprite hiding for inactive bullets

**CHR-ROM Graphics:**
- Custom bullet tile with plasma bolt appearance
- 8x8 pixel sprite resolution
- Two-bitplane graphics for 4-color sprites
- Palette 2 used for bright bullet colors

This lesson demonstrates professional NES sprite programming techniques while maintaining the classic shoot-em-up gameplay feel that made NES games legendary.