# Lesson 5: Neon Nexus - Energy Combat

This folder contains all the code examples for Lesson 5, which teaches projectile combat systems, array management, and sound effects on the Commodore 64.

## Files

- **`complete.s`** - Full combat system with multiple bullets, collision detection, and sound
- **`step1-single-bullet.s`** - Basic single bullet implementation  
- **`step3-multi-bullets.s`** - Array-based system supporting multiple bullets
- **`step6-with-sound.s`** - Complete system with SID sound effects

## Building

All examples require ACME assembler:

```bash
# Install ACME (macOS)
brew install acme

# Assemble any example
acme -f cbm -o combat.prg complete.s

# Run in VICE emulator
x64sc combat.prg
```

## Features Demonstrated

- **Projectile firing mechanics** with SPACE key
- **Bullet pool pattern** using arrays for memory efficiency
- **Multi-object management** with up to 3 active bullets
- **Collision detection** between bullets and enemies
- **SID sound programming** for firing and hit effects
- **Performance optimization** for smooth gameplay

## Progression

Each file builds combat complexity:

1. **Step 1**: Single bullet that can be fired and moves upward
2. **Step 3**: Multiple bullets using array management
3. **Step 6**: Added sound effects for firing and hits
4. **Complete**: Full system with improved enemy AI and visual effects

## What You'll See

- **Yellow diamond player** with WASD movement
- **Red star enemy** that chases the player
- **White bullets** fired with SPACE key
- **Hit effects** - enemy respawns when hit
- **Sound feedback** - laser firing and explosion sounds
- **Screen flashes** for collision events

## Key Concepts

### Bullet Pool Pattern

Instead of dynamically creating/destroying bullets, we use a fixed pool:

```asm
MAX_BULLETS = 3
bullet_active:  !fill MAX_BULLETS, 0
bullet_x:       !fill MAX_BULLETS, 0
bullet_y:       !fill MAX_BULLETS, 0
```

### Array Management

Finding free bullet slots:
```asm
ldx #0
find_loop:
    lda bullet_active,x
    beq found_slot      ; Found inactive
    inx
    cpx #MAX_BULLETS
    bne find_loop
```

### SID Sound Effects

Quick laser blast:
```asm
lda #$81        ; Noise + gate on
sta $d404       ; Voice 1 control
```

## Controls

- **WASD** - Move player
- **SPACE** - Fire bullets
- **Fire rate** - Limited to prevent spam

## Game Mechanics

- **Bullet speed**: 1 character per frame upward
- **Max bullets**: 3 active at once
- **Enemy respawn**: Relocates when hit
- **Collision**: Pixel-perfect matching required

## Common Issues

1. **Bullets leaving trails**: Make sure to clear old positions before drawing new ones
2. **Sound not working**: Check SID initialization and volume settings
3. **Rapid fire**: Fire delay prevents shooting every frame
4. **Performance**: Limited objects keep frame rate smooth

## Next Steps

This combat system prepares you for:
- Enemy bullets firing back
- Multiple enemy types
- Power-ups and weapon upgrades
- Score tracking and lives
- Wave-based gameplay

Perfect foundation for a complete arcade shooter! 🎮💥