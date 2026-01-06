# Unit 5: Ball Sprite

Add the ball as a small moving object.

## What This Unit Covers

- Small sprite design (4×4 or 8×8 pixels)
- Ball position variables
- Initial ball placement

## Key Concepts

| Concept | Description |
|---------|-------------|
| Ball size | 4×4 pixels for smooth movement |
| Position | X and Y in pixels (0-255, 0-191) |
| Starting position | Above paddle, centre |
| Sub-pixel | Later units add fractional positioning |

## Ball Sprite

```
.##.  = $60
####  = $F0
####  = $F0
.##.  = $60
```

## Ball Drawing

```asm
draw_ball:
    ; Calculate screen address from ball_x, ball_y
    ; XOR the 4×4 sprite
    ; Handle byte boundary crossing
```

## Expected Result

Small ball visible on screen above the paddle.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
