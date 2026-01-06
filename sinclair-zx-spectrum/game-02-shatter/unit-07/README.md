# Unit 7: Wall Collision

Ball bounces off screen edges.

## What This Unit Covers

- Boundary detection
- Reflection (negating velocity)
- Top, left, and right walls

## Key Concepts

| Concept | Description |
|---------|-------------|
| Reflection | Negate the velocity component |
| Left/right | Negate dx when hitting sides |
| Top | Negate dy when hitting top |
| Bottom | Ball lost (handled later) |

## Collision Logic

```asm
check_walls:
    ; Left wall
    ld a, (ball_x)
    cp 8
    jr nc, check_right_wall
    ld a, (ball_dx)
    neg
    ld (ball_dx), a
    ld a, 8
    ld (ball_x), a

check_right_wall:
    ld a, (ball_x)
    cp 248
    jr c, check_top
    ld a, (ball_dx)
    neg
    ld (ball_dx), a
    ld a, 248
    ld (ball_x), a

check_top:
    ld a, (ball_y)
    cp 8
    jr nc, walls_done
    ld a, (ball_dy)
    neg
    ld (ball_dy), a
    ld a, 8
    ld (ball_y), a

walls_done:
    ret
```

## Expected Result

Ball bounces off left, right, and top walls. Falls off bottom (no bounce yet).

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
