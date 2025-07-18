# Cosmic Harvester - Lesson 3: Laser Weaponry

This lesson adds a complete projectile system to the C64 game "Cosmic Harvester", allowing the player to fire laser bolts at enemies.

## What You'll Learn

- Character-based projectile systems on the C64
- Object pooling for multiple simultaneous bullets
- Collision detection foundations
- Screen coordinate calculations
- Frame-based animation timing
- Keyboard input handling for firing

## Building

```bash
make        # Build the PRG file
make run    # Build and run in VICE
make disk   # Create D64 disk image
make clean  # Clean build files
```

Or manually:
```bash
acme -f cbm -o build/cosmic-harvester-03.prg --cpu 6502 --format cbm cosmic-harvester-03.asm
```

## Controls

- **Q** - Move ship up
- **A** - Move ship down  
- **O** - Move ship left
- **P** - Move ship right
- **SPACE** - Fire laser bolt

## Features

- Hardware sprite player ship from Lesson 2
- Up to 8 simultaneous laser bolts
- Character-based projectile rendering
- Bullet cooldown system (prevents spamming)
- Automatic bullet cleanup when off-screen
- Preserved starfield animation from Lesson 1
- Smooth 50Hz game loop timing

## Technical Details

**Projectile System:**
- Object pool of 8 bullets maximum
- Character-based rendering using PETSCII vertical bar (|)
- Bright red bullet color for visibility
- 3-pixel-per-frame movement speed
- Automatic deactivation when bullets leave screen

**Memory Layout:**
- Bullet data stored in parallel arrays
- `bullet_active[]` - Activity flags (0/1)
- `bullet_x[]` - X coordinates
- `bullet_y[]` - Y coordinates  
- `bullet_char[]` - Screen positions for erasing

**Input System:**
- SPACE key detection for firing
- Cooldown timer prevents rapid-fire abuse
- Continues to support all movement keys from Lesson 2

**Screen Coordinate System:**
- Converts sprite coordinates to character positions
- Handles screen memory addressing ($0400-$07E7)
- Manages color memory for bullet appearance

## Game Mechanics

**Firing System:**
- Press SPACE to fire laser bolt
- 5-frame cooldown between shots
- Bullets spawn centered on ship position
- Bullets travel upward at constant speed

**Bullet Lifecycle:**
1. **Spawn** - Find free slot in object pool
2. **Move** - Update position each frame
3. **Draw** - Render character at new position
4. **Cleanup** - Remove when off-screen

**Visual Effects:**
- Bright red laser bolts for high visibility
- Smooth bullet movement synchronized with game loop
- Automatic bullet trail erasing

## Files

- `cosmic-harvester-03.asm` - Main 6502 assembly source
- `Makefile` - Build automation
- `build/cosmic-harvester-03.prg` - C64 executable
- `build/cosmic-harvester-03.d64` - C64 disk image

## Requirements

- ACME cross-assembler (6502)
- VICE C64 emulator (optional)
- c1541 tool for disk image creation
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 2 by adding:
- Complete projectile firing system
- Object pooling for resource management
- Frame-based timing for smooth animation
- Input handling for combat actions

Next lesson will add enemy ships and collision detection!

## Technical Notes

**Character vs Sprite Trade-offs:**
- Bullets use character mode for simplicity
- Lower memory usage than sprites
- Easier collision detection with screen boundaries
- Sufficient for small, fast-moving projectiles

**Performance Considerations:**
- Object pooling prevents memory allocation overhead
- Parallel arrays for cache-friendly data access
- Minimal screen memory updates per frame
- Efficient coordinate conversion routines

This lesson demonstrates essential game programming concepts while maintaining the classic C64 aesthetic and performance characteristics.