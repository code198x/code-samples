# Unit 12: Collision Detection

Use hardware collision registers to detect hits.

## What This Unit Covers

- Sprite-to-sprite collision register
- Reading and clearing collision flags
- Identifying which sprites collided

## Key Concepts

| Concept | Description |
|---------|-------------|
| Collision register | $D01E - sprite-to-sprite |
| Bit meaning | Bit N set if sprite N collided |
| Clearing | Read register to clear flags |
| Check timing | After sprite positions updated |

## Collision Check

```asm
check_collisions:
    lda $D01E           ; Read collision register
    sta collision_temp  ; Store (reading clears it)

    ; Check if bullet hit enemy
    and #%00100010      ; Sprite 1 (bullet) and 5 (enemy)
    beq no_collision
    jsr handle_hit

no_collision:
```

## Expected Result

Game detects when bullet sprite overlaps enemy sprite.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
