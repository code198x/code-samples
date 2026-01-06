# Unit 8: Paddle Collision

Ball bounces off paddle with angle control.

## What This Unit Covers

- Paddle hit detection
- Bounce angle based on hit position
- Ball launch from paddle

## Key Concepts

| Concept | Description |
|---------|-------------|
| Hit zone | Ball Y near paddle Y, X within paddle width |
| Angle control | Hit left = bounce left, hit right = bounce right |
| Centre hit | Bounce straight up |
| Launch | Ball starts attached to paddle |

## Paddle Hit Detection

```asm
check_paddle:
    ; Check Y position (is ball at paddle level?)
    ld a, (ball_y)
    cp PADDLE_Y - 4
    jr c, no_paddle_hit     ; Above paddle
    cp PADDLE_Y + 4
    jr nc, no_paddle_hit    ; Below paddle

    ; Check X position (is ball within paddle?)
    ld a, (ball_x)
    ld b, a
    ld a, (paddle_x)
    sub 4                   ; Left edge
    cp b
    jr nc, no_paddle_hit    ; Ball left of paddle

    add a, PADDLE_WIDTH + 8
    cp b
    jr c, no_paddle_hit     ; Ball right of paddle

    ; Hit! Calculate angle
    call calculate_bounce
    ld a, (ball_dy)
    neg
    ld (ball_dy), a         ; Reverse vertical

no_paddle_hit:
    ret
```

## Expected Result

Ball bounces off paddle. Hit position affects bounce angle.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
