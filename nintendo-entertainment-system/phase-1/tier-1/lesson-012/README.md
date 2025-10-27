# Lesson 012: Moving Paddle

Automatic sprite animation using velocity and boundaries.

## Files

- `moving-paddle.asm` - Paddle with velocity-based movement and bouncing

## Concepts

- **Velocity**: Separate variable for speed and direction (pixels per frame)
- **Signed arithmetic**: Two's complement on 6502 ($FF = -1, $FE = -2, etc.)
- **Boundary detection**: Check position limits, reverse velocity on collision
- **Frame-rate independence**: VBlank synchronization ensures consistent 60fps motion

## Velocity System

```asm
paddle_vy:  .res 1   ; Signed velocity

; Each frame
LDA paddle_y
CLC
ADC paddle_vy        ; Add velocity (works for positive and negative)
STA paddle_y
```

## Two's Complement Negation

To reverse velocity (create bouncing):

```asm
LDA paddle_vy
EOR #$FF             ; Flip all bits
CLC
ADC #$01             ; Add 1
STA paddle_vy        ; Now moving opposite direction
```

## Boundary Check Pattern

```asm
; Top boundary (Y < 8)
LDA paddle_y
CMP #8
BCS within           ; Branch if >= 8
; Handle collision (clamp and negate velocity)
within:
```

## Building

```bash
ca65 moving-paddle.asm -o moving-paddle.o
ld65 moving-paddle.o -C ../../nes.cfg -o moving-paddle.nes
```
