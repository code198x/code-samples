# Unit 8: Enemy Movement

Animate enemy with patrol pattern.

## What This Unit Covers

- Horizontal movement
- Direction reversal at edges
- Optional descent when reversing

## Key Concepts

| Concept | Description |
|---------|-------------|
| Patrol | Move left/right across screen |
| Reverse | Change direction at boundaries |
| Descent | Move down when reversing |
| Speed | Pixels per frame |

## Movement Logic

```asm
ENEMY_SPEED = 2
ENEMY_LEFT  = 32
ENEMY_RIGHT = 288

update_enemy:
    tst.b   enemy_active
    beq.s   .done

    move.w  enemy_x,d0
    add.w   enemy_dir,d0
    move.w  d0,enemy_x

    ; Check boundaries
    cmp.w   #ENEMY_LEFT,d0
    blt.s   .reverse
    cmp.w   #ENEMY_RIGHT,d0
    bgt.s   .reverse
    bra.s   .update_sprite

.reverse:
    neg.w   enemy_dir

    ; Optional: descend
    move.w  enemy_y,d0
    addq.w  #8,d0
    move.w  d0,enemy_y

.update_sprite:
    bsr     update_enemy_sprite

.done:
    rts
```

## Expected Result

Enemy moves left and right across the screen, reversing at edges.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
