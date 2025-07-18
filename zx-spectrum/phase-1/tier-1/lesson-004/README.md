# Lesson 4: Collision Detection

## Quantum Shatter - ZX Spectrum Assembly Programming

In this lesson, we add enemy ships and implement collision detection to create engaging space combat. When bullets hit enemies, both are destroyed and an explosion animation plays.

### What You'll Learn

- Implementing efficient collision detection on the ZX Spectrum
- Managing multiple enemy objects with movement patterns
- Creating explosion animations with color cycling
- Understanding Z80 index registers (IX/IY) for data structures
- Building interactive gameplay systems

### New Concepts Introduced

#### Enemy Management
```assembly
; Enemy data structure (3 bytes per enemy)
enemy_active:   ds      MAX_ENEMIES * 3
; +0: active flag (0/1)
; +1: X position
; +2: Y position
```

Enemies move from right to left and respawn when they leave the screen.

#### Collision Detection Using Index Registers
```assembly
check_collisions:
    ld      ix, bullet_active    ; IX points to bullets
    ld      iy, enemy_active     ; IY points to enemies
    
    ; Access data with offsets
    ld      a, (ix+0)           ; Bullet active flag
    ld      d, (ix+1)           ; Bullet X
    ld      e, (ix+2)           ; Bullet Y
```

The Z80's index registers make it easy to work with structured data.

#### Collision Algorithm
```assembly
; Check X collision
ld      a, (iy+1)       ; Enemy X
sub     d               ; Enemy X - Bullet X
jr      c, no_collision ; If negative, too far
cp      2               ; Within 2 chars?
jr      nc, no_collision ; If >= 2, too far
```

Simple distance checking in both axes determines collisions.

#### Explosion Effects
```assembly
explosion_active: ds    MAX_ENEMIES * 4
; +0: timer (counts down)
; +1: X position
; +2: Y position
; +3: unused (padding)
```

Explosions use a timer-based animation with color cycling.

### Technical Details

#### Memory Organization
- **Game Objects**: Structured arrays for bullets, enemies, explosions
- **Index Registers**: IX for bullets, IY for enemies during collision
- **Efficient Access**: Direct offset addressing with (IX+n)

#### Performance Optimizations
- Early exit from collision loops when match found
- Only check active objects
- Simple math (subtraction only, no multiplication)
- Reuse explosion slots

#### Visual Effects
- Color cycling for explosions using timer modulo
- Character-based animation (no sprites)
- Bright attribute for emphasis

### Building and Running

```bash
make        # Build the TAP file
make run    # Build and run in Fuse emulator
```

### Controls
- **Q**: Move ship up
- **A**: Move ship down
- **SPACE**: Fire bullets

### Gameplay Elements
- Player ship on the left shoots right
- Enemy ships move from right to left
- Collisions destroy both bullet and enemy
- Explosion animation at impact point
- Enemies respawn on the right edge

### Code Architecture

#### Main Game Loop
```assembly
game_loop:
    halt                    ; Wait for 50Hz interrupt
    call    update_starfield
    call    read_keyboard
    call    update_player
    call    update_bullets
    call    update_enemies
    call    check_collisions   ; After all movement
    call    update_explosions  ; Visual feedback
    jr      game_loop
```

#### Collision System Flow
1. For each active bullet
2. Check against each active enemy
3. If collision detected:
   - Deactivate both objects
   - Start explosion at enemy position
   - Exit inner loop (bullet consumed)

### Z80 Programming Techniques

#### Using Index Registers
- **IX/IY**: Perfect for array access with structures
- **Offset Addressing**: (IX+n) accesses structure members
- **Pointer Arithmetic**: ADD IX,DE to move to next element

#### Efficient Loops
```assembly
ld      b, MAX_BULLETS
check_loop:
    ; Process bullet
    ld      de, 3           ; Size of bullet structure
    add     ix, de          ; Next bullet
    djnz    check_loop
```

### Next Steps
In future lessons, we'll add:
- Score tracking for destroyed enemies
- Different enemy types and behaviors
- Power-ups and weapon upgrades
- Player lives and game over conditions

### Common Pitfalls
1. **Forgetting to check active flags** - Causes false collisions
2. **Not clearing old positions** - Leaves trails on screen
3. **Index register corruption** - Save/restore when needed
4. **Collision box too large/small** - Adjust threshold for gameplay

This collision system provides the foundation for all gameplay interactions!