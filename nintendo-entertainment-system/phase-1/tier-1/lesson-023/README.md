# Lesson 023: Momentum Transfer

Paddle velocity now transfers to ball, rewarding active play.

## Concepts Demonstrated

- **Velocity tracking**: Store `paddle_y_old` to calculate movement
- **Momentum transfer**: Paddle velocity added to ball velocity
- **Enhanced physics**: Moving paddle = faster ball
- **Velocity clamping**: Keep ball_dy within -4 to +4

## Key Code

```asm
; Calculate paddle velocity
LDA paddle_y
SEC
SBC paddle_y_old        ; Current - previous = velocity

; Add to ball Y velocity
CLC
ADC ball_dy
STA ball_dy

; Clamp to prevent excessive speed
```

## Building

```bash
ca65 momentum-transfer.asm -o momentum-transfer.o
ld65 momentum-transfer.o -C ../lesson-001/nes.cfg -o momentum-transfer.nes
```

## Testing

Hit ball while moving paddle upward → ball moves faster upward. Stationary paddle → normal bounce.

## What Changed from Lesson 022

1. Added `paddle_y_old` variable
2. Track paddle position each frame
3. Calculate paddle velocity on collision
4. Add paddle velocity to ball velocity
5. Extended clamping range (-4 to +4)
