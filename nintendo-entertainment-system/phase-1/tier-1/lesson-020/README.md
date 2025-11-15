# Lesson 020: Physics Refinement - Angle Variation

Adds angle variation to wall bounces based on horizontal position.

## Concepts Demonstrated

- **Dynamic angle adjustment**: Hit position affects bounce angle
- **Bitwise masking**: Extract lower bits for variation (`AND #$03`)
- **Velocity clamping**: Keep `ball_dx` within -3 to +3 range
- **Pseudo-randomness**: Use ball_x position for variation

## Key Code

```asm
; After wall bounce, vary horizontal velocity
LDA ball_x
AND #$03            ; Get 0-3 based on X position
CMP #$02
BCC :+              ; If 0-1, decrease dx (left)
INC ball_dx         ; If 2-3, increase dx (right)
JMP :++
: DEC ball_dx
```

## Building

```bash
ca65 physics-angles.asm -o physics-angles.o
ld65 physics-angles.o -C ../lesson-001/nes.cfg -o physics-angles.nes
```

## Testing

Ball bounces now have slight horizontal variation. Hit the left side of screen → ball angles left. Right side → angles right.

## What Changed from Lesson 019

1. Angle variation added to top/bottom bounces
2. Velocity clamping prevents extreme angles
3. Uses ball X position for semi-random variation
