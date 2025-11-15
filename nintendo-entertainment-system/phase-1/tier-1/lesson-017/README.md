# Lesson 017: The Ball Entity

This lesson introduces the ball as a game entity with its own position and velocity stored in RAM.

## Concepts Demonstrated

- **Entity variables in Zero Page**: `ball_x`, `ball_y`, `ball_dx`, `ball_dy`
- **Multiple sprites**: Paddle (sprite 0) and ball (sprite 1)
- **Velocity storage**: Separate variables for X and Y movement (not yet applied)
- **CHR-ROM tiles**: Ball tile pattern (circular 8x8 sprite)

## RAM Layout

```
$00: nmi_ready
$01: buttons
$02: paddle_y
$03: ball_x      ; NEW - ball X position
$04: ball_y      ; NEW - ball Y position
$05: ball_dx     ; NEW - ball X velocity (signed)
$06: ball_dy     ; NEW - ball Y velocity (signed)
```

## Building

```bash
ca65 ball-entity.asm -o ball-entity.o
ld65 ball-entity.o -C ../lesson-001/nes.cfg -o ball-entity.nes
```

## Testing

The ball appears at screen center (128, 120) and remains stationary. Movement will be added in lesson 018.

## What Changed from Lesson 016

1. Added ball entity variables (position + velocity)
2. Ball initialized at center screen
3. Ball sprite added to OAM (slot 1)
4. New CHR tile for ball (circular pattern)
