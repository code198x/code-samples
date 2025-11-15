# Lesson 019: Screen Boundaries

Ball now bounces off top/bottom walls and wraps at screen edges.

## Concepts Demonstrated

- **Boundary detection**: Compare position with screen limits
- **Velocity reversal**: Negate velocity for bounce (two's complement)
- **Natural wrapping**: X position wraps 0-255 automatically
- **Screen constants**: `SCREEN_TOP`, `SCREEN_BOTTOM`

## Velocity Negation Technique

```asm
; To negate a signed 8-bit value:
LDA ball_dy
EOR #$FF        ; Invert all bits
CLC
ADC #1          ; Add 1 (two's complement)
STA ball_dy
```

This converts +1 to -1 ($01 → $FF), +2 to -2 ($02 → $FE), etc.

## Building

```bash
ca65 ball-boundaries.asm -o ball-boundaries.o
ld65 ball-boundaries.o -C ../lesson-001/nes.cfg -o ball-boundaries.nes
```

## Testing

Ball bounces between top (Y=8) and bottom (Y=232) walls. It wraps horizontally at screen edges.

## What Changed from Lesson 018

1. Added boundary constants
2. Top/bottom collision detection with velocity reversal
3. X wrapping happens naturally (no explicit check)
