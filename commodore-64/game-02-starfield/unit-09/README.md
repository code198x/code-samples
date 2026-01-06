# Unit 9: Bullet Pooling

Support multiple bullets in flight simultaneously.

## What This Unit Covers

- Bullet pool data structure
- Iterating through active bullets
- Reusing inactive bullet slots

## Key Concepts

| Concept | Description |
|---------|-------------|
| Pool size | 4 bullets (using sprites 1-4) |
| Pool structure | Arrays for active, x, y |
| Finding free slot | Scan for inactive bullet |

## Pool Structure

```asm
MAX_BULLETS = 4
bullet_active:  !byte 0, 0, 0, 0
bullet_x:       !byte 0, 0, 0, 0
bullet_y:       !byte 0, 0, 0, 0
```

## Spawn Logic

```asm
spawn_bullet:
    ldx #0
find_slot:
    lda bullet_active,x
    beq found_slot
    inx
    cpx #MAX_BULLETS
    bne find_slot
    rts                 ; No free slots

found_slot:
    lda #1
    sta bullet_active,x
    lda player_x
    sta bullet_x,x
    ; ... etc
```

## Expected Result

Player can fire up to 4 bullets simultaneously.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
