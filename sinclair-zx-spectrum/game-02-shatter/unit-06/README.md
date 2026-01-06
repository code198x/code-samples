# Unit 6: Ball Movement

Animate ball with velocity.

## What This Unit Covers

- Velocity variables (dx, dy)
- Signed movement
- Frame-based update

## Key Concepts

| Concept | Description |
|---------|-------------|
| Velocity | Signed bytes for direction and speed |
| dx | Horizontal: negative=left, positive=right |
| dy | Vertical: negative=up, positive=down |
| Update | Add velocity to position each frame |

## Movement Logic

```asm
update_ball:
    ; Erase at old position
    call draw_ball

    ; Update X
    ld a, (ball_x)
    ld b, a
    ld a, (ball_dx)
    add a, b
    ld (ball_x), a

    ; Update Y
    ld a, (ball_y)
    ld b, a
    ld a, (ball_dy)
    add a, b
    ld (ball_y), a

    ; Draw at new position
    call draw_ball
    ret

ball_x:     defb 128
ball_y:     defb 100
ball_dx:    defb 2      ; Moving right
ball_dy:    defb -2     ; Moving up
```

## Expected Result

Ball moves diagonally across screen (passes through walls - collision in next unit).

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
