# Lesson 022: Angle Control

Hit position on paddle now affects bounce angle, adding player skill.

## Concepts Demonstrated

- **Relative position calculation**: `ball_y - paddle_y`
- **Three-zone control**: Top/middle/bottom thirds have different angles
- **Y velocity modification**: -2 (up), 0 (straight), +2 (down)
- **Player skill integration**: Positioning matters

## Angle Zones

```
Paddle (32 pixels tall):
  Top third (0-10):    dy = -2 (upward)
  Middle third (11-21): dy = 0 (straight)
  Bottom third (22-31): dy = +2 (downward)
```

## Building

```bash
ca65 angle-control.asm -o angle-control.o
ld65 angle-control.o -C ../lesson-001/nes.cfg -o angle-control.nes
```

## Testing

Hit ball with top of paddle → angles upward. Middle → straight. Bottom → downward.

## What Changed from Lesson 021

1. Added `temp` variable for calculations
2. Calculate relative hit position on paddle
3. Three-zone angle control system
4. Y velocity now controlled by hit position
