# Unit 14: Power-Ups

Special bricks that modify gameplay.

## What This Unit Covers

- Power-up brick types
- Falling power-up items
- Paddle and ball modifications

## Key Concepts

| Concept | Description |
|---------|-------------|
| Power-up types | Wide paddle, slow ball, extra life |
| Special bricks | Marked differently in grid |
| Falling item | Drops when brick destroyed |
| Collection | Paddle catches falling power-up |

## Power-Up Types

```asm
POWERUP_NONE    = 0
POWERUP_WIDE    = 1     ; Wider paddle
POWERUP_SLOW    = 2     ; Slower ball
POWERUP_LIFE    = 3     ; Extra life

powerup_active: defb 0
powerup_x:      defb 0
powerup_y:      defb 0
powerup_type:   defb 0
```

## Spawning

```asm
spawn_powerup:
    ; Called when power-up brick destroyed
    ld a, 1
    ld (powerup_active), a
    ; Set position to brick location
    ; Set type based on brick
    ret

update_powerup:
    ld a, (powerup_active)
    or a
    ret z

    ; Move down
    ld a, (powerup_y)
    add a, 2
    ld (powerup_y), a

    ; Check paddle collection
    call check_powerup_catch
    ret
```

## Expected Result

Some bricks drop power-ups when destroyed. Catching them modifies gameplay.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
