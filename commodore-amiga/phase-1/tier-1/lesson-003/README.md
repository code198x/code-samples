# Turbo Horizon - Lesson 3: Quantum Blasters

This lesson adds a complete hardware sprite-based projectile system to the Amiga game "Turbo Horizon", allowing the player to fire quantum energy bolts using the Amiga's legendary sprite hardware.

## What You'll Learn

- Hardware sprite-based projectile systems on the Amiga
- Multiple sprite management (8 sprites total)
- Copper list programming for sprites
- Object pooling for sprite resources
- Frame-based collision detection foundations
- Joystick fire button input handling

## Building

```bash
make        # Build the executable
make adf    # Build and create ADF disk image
make run    # Build ADF and run in FS-UAE emulator
make test   # Build and verify executable creation
make clean  # Clean build files
```

Or manually:
```bash
vasmm68k_mot -Fhunkexe -nosym -kick1hunks -o build/turbo-horizon-03 turbo-horizon-03.s
```

## Controls

- **Joystick Up** - Move ship up
- **Joystick Down** - Move ship down  
- **Joystick Left** - Move ship left
- **Joystick Right** - Move ship right
- **Fire Button** - Fire quantum energy bolt
- **Left Mouse Button** - Exit program

## Features

- Hardware sprite-based player ship from Lesson 2
- Up to 7 simultaneous quantum energy bolts using sprites 1-7
- Custom bullet sprite with quantum energy appearance
- Bullet cooldown system (prevents spamming)
- Automatic sprite cleanup when off-screen
- Preserved starfield animation from Lesson 1
- Smooth 50Hz game loop timing with hardware acceleration

## Technical Details

**Projectile System:**
- Object pool of 7 bullets maximum (sprites 1-7)
- Hardware sprite rendering for flicker-free movement
- Bright yellow/red bullet colors for high visibility
- 3-pixel-per-frame movement speed
- Automatic sprite hiding when bullets leave screen

**Memory Layout:**
- Bullet data stored in parallel arrays
- `bulletActive[]` - Activity flags (0/1)
- `bulletX[]` - X coordinates
- `bulletY[]` - Y coordinates  
- Sprites 1-7 reserved for bullets (sprite 0 is player)

**Input System:**
- Fire button detection via POTGOR register
- 12-frame cooldown timer prevents rapid-fire abuse
- Continues to support all movement controls from Lesson 2

**Sprite System:**
- Player uses sprite 0
- Bullets use sprites 1-7
- Copper list manages all sprite pointers
- Real-time sprite position updates

## Game Mechanics

**Firing System:**
- Press fire button to launch quantum energy bolt
- 12-frame cooldown between shots (about 1/4 second at 50Hz)
- Bullets spawn centered on player ship position
- Bullets travel upward at 3 pixels per frame

**Bullet Lifecycle:**
1. **Spawn** - Find free slot in object pool
2. **Move** - Update position each frame
3. **Draw** - Update sprite registers via copper list
4. **Cleanup** - Hide sprite when off-screen

**Visual Effects:**
- Bright quantum energy bolts with distinctive sprite design
- Smooth 50Hz sprite movement via hardware acceleration
- Multi-bitplane sprites for detailed appearance

## Files

- `turbo-horizon-03.s` - Main 68000 assembly source
- `Makefile` - Build automation
- `make-adf.sh` - ADF creation script
- `create_adf.py` - Python ADF fallback
- `build/turbo-horizon-03` - Amiga executable
- `build/turbo-horizon-03.adf` - Amiga disk image

## Requirements

- vasmm68k_mot (68k assembler)
- amitools (optional, for proper ADF creation)
- FS-UAE or WinUAE emulator
- Kickstart ROM for emulator
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 2 by adding:
- Complete sprite-based projectile firing system
- Multiple sprite management and coordination
- Copper list programming for sprite control
- Frame-based timing for smooth animation
- Joystick fire button input handling

Next lesson will add enemy ships and collision detection!

## Technical Notes

**Hardware Sprite Advantages:**
- Independent movement without background corruption
- Automatic priority handling by hardware
- Flicker-free animation with DMA
- Efficient rendering without CPU intervention

**Amiga Specific Features:**
- Uses 8 of the Amiga's hardware sprites
- Copper list manages all sprite pointers automatically
- Multi-bitplane sprites for detailed graphics
- 50Hz frame timing via custom hardware

**Performance Considerations:**
- Object pooling prevents sprite allocation overhead
- Copper list handles sprite updates automatically
- Parallel arrays for cache-friendly bullet data access
- Efficient sprite hiding for inactive bullets

**Sprite Graphics Design:**
- Custom 8x8 quantum energy bolt sprite
- Two-bitplane graphics for 4-color sprites
- Bright yellow core with red outer glow
- Distinctive appearance that stands out against starfield

**Memory Management:**
- Sprite data in CHIP RAM for DMA access
- Copper list in CHIP RAM for custom chips
- Efficient data structures for bullet management
- Minimal CPU overhead for sprite updates

This lesson demonstrates professional Amiga sprite programming techniques while showcasing the unique capabilities that made the Amiga legendary for its smooth, colorful graphics.