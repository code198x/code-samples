# Lesson 4: Hardware Collision Detection

## Turbo Horizon - Amiga Assembly Programming

In this lesson, we harness the Amiga's unique hardware collision detection capabilities to create engaging gameplay. The custom chips automatically detect when sprites overlap, eliminating the need for software collision calculations.

### What You'll Learn

- Using the Amiga's hardware collision detection registers
- Managing sprite collisions with CLXDAT and CLXCON
- Creating explosion effects with sprite animation
- Efficient sprite management for multiple objects
- Understanding collision groups and masks

### New Concepts Introduced

#### Hardware Collision Detection
```assembly
* Set up collision control
move.w  #$00c0,CLXCON(a5)   * Enable sprite collisions

* Read collision data
move.w  CLXDAT(a5),d0       * Get collision bits
```

The Amiga automatically detects when sprite pixels overlap, setting bits in CLXDAT.

#### Collision Register Bits
- Bit 0: Sprites 0 & 1 collided
- Bit 1: Sprites 0 & 2 collided
- Bit 2: Sprites 0 & 3 collided
- etc.

Each bit represents a specific sprite pair collision.

#### Sprite Organization
```assembly
* Sprite allocation:
* Sprite 0: Player ship
* Sprites 1-3: Bullets
* Sprites 4-7: Enemies/Explosions
```

Strategic sprite assignment simplifies collision detection logic.

#### Explosion Management
```assembly
explosion_sprite:
    dc.w    $6050,$7200     * Control words
    dc.w    $1008,$3018     * Explosion pattern
    dc.w    $783c,$fc7e
    ; ... more data
```

Dedicated explosion sprites with animation frames.

### Technical Details

#### CLXCON Register
Controls which sprites participate in collision detection:
- Bits 12-13: Sprite grouping options
- Bits 6-11: Enable specific sprite pairs
- Lower bits: Playfield collision options

#### CLXDAT Register
Read-only register containing collision results:
- Hardware sets bits when sprites overlap
- Reading clears the register
- Check specific bits for sprite pairs

#### Collision Detection Flow
1. Hardware continuously checks sprite overlap
2. Sets appropriate bits in CLXDAT
3. Software reads CLXDAT during game loop
4. Process collisions based on bit patterns
5. Clear register by reading

### Building and Running

```bash
make        # Build the executable
make disk   # Create bootable ADF (requires xdftool)
```

Run in FS-UAE or similar Amiga emulator, or on real hardware.

### Controls
- **Joystick Up/Down**: Move ship
- **Fire Button**: Shoot bullets
- **Left Mouse**: Exit game

### Code Architecture

#### Main Collision Handler
```assembly
check_collisions:
    move.w  CLXDAT(a5),d0   * Get collision data
    
    * Check bullet vs enemy collisions
    * Bullets are sprites 1-3
    * Enemies are sprites 4-7
    
    * Process each possible collision
    btst    #bit,d0
    bne     handle_collision
```

#### Sprite Update System
```assembly
update_sprites:
    * Update sprite 0 (ship)
    lea     sprite_data(pc),a0
    move.w  ship_y(pc),d0
    move.b  d0,(a0)         * VSTART
    
    * Update bullet sprites
    * Update enemy/explosion sprites
```

### Hardware Collision Advantages

1. **Zero CPU Overhead**: Collision detection happens in hardware
2. **Pixel Perfect**: Detects actual sprite pixel overlap
3. **Automatic**: No distance calculations needed
4. **Real-time**: Updated every scanline

### Common Pitfalls

1. **Forgetting to Clear**: Must read CLXDAT to clear it
2. **Sprite Priority**: Higher number sprites appear on top
3. **Color 0 Transparency**: Transparent pixels don't collide
4. **Attached Sprites**: Special rules for 16-color sprites

### Optimization Techniques

#### Sprite Allocation Strategy
- Group related sprites (bullets together, enemies together)
- Use collision control to ignore unwanted pairs
- Reserve sprite 0 for special purposes

#### Efficient Collision Processing
```assembly
* Use lookup table for collision responses
move.w  d0,d1           * Collision bits
and.w   #$00f0,d1       * Mask relevant bits
lsr.w   #4,d1           * Create index
add.w   d1,d1           * Word offset
move.w  collision_table(pc,d1.w),d1
jsr     (d1)            * Jump to handler
```

### Advanced Techniques

1. **Collision Groups**: Use CLXCON to create collision layers
2. **Playfield Collisions**: Detect sprite vs background
3. **Dual Playfield**: Separate collision detection per playfield
4. **Blitter Collisions**: For non-sprite objects

### Practice Exercises

1. **Add Sound**: Play explosion sound on collision
2. **Score System**: Award points for destroyed enemies
3. **Power-ups**: Create collectible items using sprites
4. **Chain Reactions**: Explosions that destroy nearby enemies

### Next Steps

With hardware collision detection mastered:
- Add multiple enemy types with different behaviors
- Implement power-up system with special weapons
- Create boss enemies using attached sprites
- Add parallax scrolling backgrounds

The Amiga's hardware collision detection is a unique feature that enables smooth, responsive gameplay with minimal CPU usage. This foundation allows you to focus on game logic rather than collision mathematics!