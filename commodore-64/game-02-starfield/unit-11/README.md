# Unit 11: Enemy Movement

Animate enemy with patrol pattern.

## What This Unit Covers

- Horizontal movement pattern
- Direction reversal at edges
- Movement speed and timing

## Key Concepts

| Concept | Description |
|---------|-------------|
| Direction flag | +1 or -1 for left/right |
| Edge detection | Reverse at screen boundaries |
| Descent | Move down when reversing (optional) |

## Movement Pattern

```asm
update_enemy:
    lda enemy_x
    clc
    adc enemy_dir       ; Add direction (-1 or +1)
    sta enemy_x

    ; Check boundaries
    cmp #40
    bcc reverse
    cmp #240
    bcs reverse
    jmp update_pos

reverse:
    lda enemy_dir
    eor #$FF            ; Negate
    clc
    adc #1
    sta enemy_dir

update_pos:
    lda enemy_x
    sta $D008           ; Sprite 4 X position
```

## Expected Result

Enemy moves left and right across the screen in patrol pattern.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
