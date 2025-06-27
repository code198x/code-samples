# Lesson 4: Neon Nexus - Digital Opposition

This folder contains all the code examples for Lesson 4, which teaches enemy creation, AI programming, and collision detection on the Commodore 64.

## Files

- **`complete.s`** - Final program with enemy AI and collision detection
- **`step2-static-enemy.s`** - Enemy that appears but doesn't move
- **`step4-moving-enemy.s`** - Enemy with basic left-to-right movement  
- **`step6-chasing-enemy.s`** - Intelligent enemy that chases the player

## Building

All examples require ACME assembler:

```bash
# Install ACME (macOS)
brew install acme

# Assemble any example
acme -f cbm -o enemy.prg complete.s

# Run in VICE emulator
x64sc enemy.prg
```

## Features Demonstrated

- **Enemy entity creation** with autonomous movement
- **Basic AI programming** with chase behavior
- **Collision detection** between player and enemy
- **Multi-entity management** in game loops
- **Visual feedback** for collision events
- **Memory management** for multiple game objects

## Progression

Each file builds enemy complexity:

1. **Step 2**: Static enemy that appears on screen
2. **Step 4**: Enemy with simple left-to-right movement
3. **Step 6**: Smart enemy that chases the player
4. **Complete**: Full system with improved collision effects

## What You'll See

- **Yellow diamond player** controlled with WASD keys
- **Red star enemy** that moves autonomously  
- **Chase behavior** - enemy follows player around screen
- **Collision detection** - screen flashes when they touch
- **Boundary checking** - entities stay within screen bounds

## Key Concepts

- **AI Decision Making**: Compare positions to decide movement
- **Collision Detection**: Check if X and Y coordinates match
- **Game Loop Management**: Handle multiple moving entities
- **Visual Feedback**: Use screen effects to communicate events

## AI Algorithm

The enemy uses simple but effective AI:

```asm
; Compare X positions
lda player_x
cmp enemy_x
beq check_y     ; Same X, check Y movement
bcc move_left   ; Player left of enemy
                ; Player right of enemy, move right
inc enemy_x
```

This creates believable "intelligent" behavior where the enemy actively hunts the player!

## Collision Detection

Simple but reliable collision checking:

```asm
lda player_x
cmp enemy_x
bne no_collision

lda player_y
cmp enemy_y  
bne no_collision
; Both X AND Y match = collision!
```

This forms the foundation for all game object interactions.