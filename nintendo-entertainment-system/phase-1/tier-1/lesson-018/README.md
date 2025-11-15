# Lesson 018: Ball Movement

This lesson adds movement to the ball by applying velocity each frame.

## Concepts Demonstrated

- **Velocity application**: Adding `ball_dx` and `ball_dy` to position
- **Frame-based movement**: Movement happens once per frame (60fps)
- **Simple physics**: Position += Velocity
- **Diagonal movement**: Independent X and Y velocity

## Key Code

```asm
UpdateBall:
    LDA ball_x
    CLC
    ADC ball_dx         ; Add X velocity
    STA ball_x

    LDA ball_y
    CLC
    ADC ball_dy         ; Add Y velocity
    STA ball_y
    RTS
```

## Building

```bash
ca65 ball-movement.asm -o ball-movement.o
ld65 ball-movement.o -C ../lesson-001/nes.cfg -o ball-movement.nes
```

## Testing

Ball moves diagonally down-right at 2 pixels/frame horizontally and 1 pixel/frame vertically. It will eventually move off-screen (boundaries added in lesson 019).

## What Changed from Lesson 017

1. Added `UpdateBall` function
2. Ball position updated every frame based on velocity
3. Main loop calls `UpdateBall` before `UpdateOAM`
