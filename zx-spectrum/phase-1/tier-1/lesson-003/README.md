# Quantum Shatter - Lesson 3: Laser Weaponry

This lesson adds a complete projectile system to the ZX Spectrum game "Quantum Shatter", allowing the player to fire energy bolts at enemies.

## What You'll Learn

- Character-based projectile systems on the ZX Spectrum
- Object pooling for multiple simultaneous bullets
- Custom character creation for bullets
- Collision detection foundations
- Frame-based animation timing
- Keyboard input handling for firing

## Building

```bash
make        # Build the TAP file
make run    # Build and run in Fuse emulator
make test   # Build and verify TAP file creation
make clean  # Clean build files
```

Or manually:
```bash
sjasmplus --lst=build/quantum-shatter-03.lst quantum-shatter-03.asm
```

## Controls

- **Q** - Move ship up
- **A** - Move ship down  
- **O** - Move ship left
- **P** - Move ship right
- **SPACE** - Fire energy bolt

## Features

- Custom character-based player ship from Lesson 2
- Up to 8 simultaneous energy bolts
- Custom bullet character with distinctive appearance
- Bullet cooldown system (prevents spamming)
- Automatic bullet cleanup when off-screen
- Preserved starfield animation from Lesson 1
- Smooth 50Hz game loop timing

## Technical Details

**Projectile System:**
- Object pool of 8 bullets maximum
- Custom character rendering for distinctive laser bolts
- Bright red bullet color for high visibility
- 2-character-per-frame movement speed
- Automatic deactivation when bullets leave screen

**Memory Layout:**
- Bullet data stored in parallel arrays
- `bullet_active[]` - Activity flags (0/1)
- `bullet_x[]` - X coordinates
- `bullet_y[]` - Y coordinates  
- Character data at $4000 + (BULLET_CHAR * 8)

**Input System:**
- SPACE key detection for firing
- 10-frame cooldown timer prevents rapid-fire abuse
- Continues to support all movement keys from Lesson 2

**Character System:**
- Ship character: Custom triangle design with engine flames
- Bullet character: Distinctive energy bolt appearance
- Both use 8x8 pixel character definitions

## Game Mechanics

**Firing System:**
- Press SPACE to fire energy bolt
- 10-frame cooldown between shots (1/5 second at 50Hz)
- Bullets spawn at ship position
- Bullets travel upward at 2 characters per frame

**Bullet Lifecycle:**
1. **Spawn** - Find free slot in object pool
2. **Move** - Update position each frame
3. **Draw** - Render character at new position
4. **Cleanup** - Remove when off-screen

**Visual Effects:**
- Bright red energy bolts for high visibility
- Smooth bullet movement synchronized with game loop
- Custom character design for professional appearance

## Files

- `quantum-shatter-03.asm` - Main Z80 assembly source
- `Makefile` - Build automation
- `build/quantum-shatter-03.tap` - ZX Spectrum tape image
- `build/quantum-shatter-03.lst` - Assembly listing

## Requirements

- sjasmplus cross-assembler (Z80)
- Fuse ZX Spectrum emulator (optional)
- ZEsarUX emulator (alternative)
- Make (optional, for build automation)

## Game Progression

This lesson builds on Lesson 2 by adding:
- Complete projectile firing system
- Object pooling for resource management
- Custom character creation for bullets
- Frame-based timing for smooth animation
- Input handling for combat actions

Next lesson will add enemy ships and collision detection!

## Technical Notes

**Character vs Pixel Trade-offs:**
- Bullets use character mode for speed and simplicity
- 8x8 character resolution sufficient for projectiles
- Easier collision detection with character boundaries
- Faster rendering than pixel-by-pixel updates

**ZX Spectrum Specific Features:**
- Uses character mode for both ship and bullets
- Attribute memory for color management
- Keyboard matrix scanning for input
- 50Hz frame timing via HALT instruction

**Performance Considerations:**
- Object pooling prevents memory allocation overhead
- Parallel arrays for efficient data access
- Minimal attribute memory updates per frame
- Efficient character-based coordinate system

This lesson demonstrates essential game programming concepts while taking advantage of the ZX Spectrum's character-based graphics system for maximum performance.