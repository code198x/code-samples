# Lesson 4: Collision Detection

## Underground Assault - NES Assembly Programming

In this lesson, we add enemy sprites and implement hardware sprite collision detection to create engaging combat gameplay. The NES's sprite system makes collision detection straightforward and efficient.

### What You'll Learn

- Implementing sprite-based collision detection
- Managing multiple enemy sprites with movement patterns
- Creating explosion animations using sprite animation
- Understanding collision box concepts
- Optimizing sprite usage within NES limitations

### New Concepts Introduced

#### Sprite-Based Collision
```assembly
; Collision box sizes (in pixels)
COLLISION_WIDTH = 6
COLLISION_HEIGHT = 6
```

Unlike character-based systems, the NES uses pixel-precise collision detection with adjustable hit boxes.

#### Enemy Management
```assembly
; Enemy system variables
enemy_active:       .res MAX_ENEMIES
enemy_x:            .res MAX_ENEMIES
enemy_y:            .res MAX_ENEMIES
enemy_timer:        .res MAX_ENEMIES
```

Parallel arrays track each enemy's state, position, and behavior timer.

#### Collision Algorithm
```assembly
check_object_collision:
    ; Check X overlap
    lda obj1_x
    sec
    sbc obj2_x
    bcs @positive_x         ; obj1 >= obj2
    
    ; Make positive and check range
    eor #$FF
    clc
    adc #1
    cmp #COLLISION_WIDTH
    bcs @no_collision
```

The algorithm checks if objects overlap in both X and Y dimensions.

#### Explosion Animation
```assembly
; Alternate explosion frames
lda explosion_timer,y
and #4
beq @explosion_frame2

lda #EXPLOSION_1
jmp @draw_explosion

@explosion_frame2:
lda #EXPLOSION_2
```

Timer-based animation creates dynamic explosion effects.

### Technical Details

#### Sprite Management
- **Sprite Limit**: 64 sprites total, 8 per scanline
- **OAM Updates**: Use sprite DMA for flicker-free updates
- **Priority System**: Earlier sprites have higher priority
- **Palette Assignment**: 4 palettes for sprites

#### Performance Considerations
- Pixel-precise collision is more expensive than tile-based
- Limit active objects to maintain 60 FPS
- Use simple rectangular hit boxes
- Early exit from collision loops

#### NES Hardware Features Used
- Hardware sprites for all game objects
- Sprite DMA for efficient updates
- Multiple sprite palettes for variety
- Frame-based timing via NMI

### Building and Running

```bash
make        # Build the ROM
make run    # Build and run in FCEUX emulator
```

### Controls
- **D-Pad Up/Down**: Move ship
- **A Button**: Fire bullets
- **Start**: Pause (not implemented yet)

### Gameplay Elements
- Player ship fires projectiles
- Enemy sprites move in patterns
- Collisions create explosions
- Enemies respawn after destruction
- Smooth 60 FPS gameplay

### Code Architecture

#### Main Game Loop
```assembly
update_game:
    jsr update_starfield
    jsr update_ship
    jsr update_bullets
    jsr update_enemies
    jsr check_collisions
    jsr update_explosions
    jsr update_sprites      ; Final sprite update
```

#### Collision System Design
1. Update all object positions
2. Check each bullet against each enemy
3. On collision: deactivate both, start explosion
4. Update sprite display data
5. DMA transfer during vblank

### NES Programming Techniques

#### Efficient Sprite Updates
```assembly
update_sprites:
    ; Clear OAM
    ldx #0
    lda #$FF
@clear_loop:
    sta $0200,x
    inx
    bne @clear_loop
    
    ; Then draw active sprites...
```

#### Managing Sprite Flicker
- Limit objects per scanline
- Rotate sprite priority
- Hide off-screen sprites
- Use sprite 0 for HUD elements

### Common Challenges

1. **Sprite Overflow**: More than 8 sprites on a line causes flicker
2. **OAM Corruption**: Always use DMA, not direct writes
3. **Collision Accuracy**: Balance hit box size for gameplay
4. **Performance**: Too many collision checks slow the game

### Next Steps

In future lessons, we'll add:
- Score display using background tiles
- Different enemy types and patterns
- Power-ups and weapon upgrades
- Sound effects for explosions
- Multiple hit points for enemies

### Optimization Tips

1. **Spatial Partitioning**: Only check nearby objects
2. **Broad Phase**: Quick rejection before detailed check
3. **Fixed Point Math**: Use for sub-pixel movement
4. **Lookup Tables**: Pre-calculate common values

This collision system provides smooth, responsive gameplay that takes full advantage of the NES hardware!