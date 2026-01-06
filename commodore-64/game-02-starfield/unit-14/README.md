# Unit 14: Wave System

Multiple enemies and wave progression.

## What This Unit Covers

- Enemy pool (multiple enemies)
- Wave counter
- Increasing difficulty per wave

## Key Concepts

| Concept | Description |
|---------|-------------|
| Enemy pool | 3 enemies using sprites 5-7 |
| Wave number | Increments when all enemies destroyed |
| Difficulty scaling | Faster enemies each wave |
| Wave clear check | All enemies inactive |

## Wave Structure

```asm
MAX_ENEMIES = 3
enemy_active:   !byte 1, 1, 1
enemy_x:        !byte 50, 150, 250
enemy_y:        !byte 60, 60, 60
enemy_dir:      !byte 1, -1, 1
wave_number:    !byte 1
```

## Wave Clear Check

```asm
check_wave_clear:
    ldx #0
    ldy #0              ; Count active
check_loop:
    lda enemy_active,x
    beq next_enemy
    iny
next_enemy:
    inx
    cpx #MAX_ENEMIES
    bne check_loop

    cpy #0
    bne not_clear
    jsr next_wave
not_clear:
```

## Expected Result

Three enemies on screen. Clearing all starts next wave with faster enemies.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
