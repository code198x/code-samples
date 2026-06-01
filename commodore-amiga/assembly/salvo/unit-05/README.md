# Unit 5: Bullet Movement

Animate bullet travelling upward.

## What This Unit Covers

- Updating bullet position each frame
- Deactivating when off-screen
- Bullet speed control

## Key Concepts

| Concept | Description |
|---------|-------------|
| Velocity | Pixels per frame (4-8 typical) |
| Off-screen | Y < top of playfield |
| Deactivate | Clear active flag, hide sprite |
| Frame timing | VBlank synchronisation |

## Movement Logic

```asm
BULLET_SPEED = 6

update_bullet:
    tst.b   bullet_active
    beq.s   .done

    ; Move up
    move.w  bullet_y,d0
    sub.w   #BULLET_SPEED,d0
    move.w  d0,bullet_y

    ; Off screen?
    cmp.w   #24,d0              ; Top boundary
    bgt.s   .update_sprite

    ; Deactivate
    clr.b   bullet_active
    bra.s   .done

.update_sprite:
    bsr     update_bullet_sprite

.done:
    rts
```

## Expected Result

Bullet travels upward from player and disappears at top of screen.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
