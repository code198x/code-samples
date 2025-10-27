# Lesson 015: Paddle Control

Direct player control of paddle with boundaries.

## Files

- `paddle-control.asm` - Complete player-controlled paddle with clamping

## Concepts

- **Direct control**: Controller input directly modifies paddle position
- **No velocity**: Removed automatic movement for player control
- **Responsive feel**: 3 pixels/frame movement speed
- **Boundary clamping**: Prevent paddle from leaving screen

## Control System

```asm
PADDLE_SPEED = 3

MainLoop:
    JSR ReadController

    ; Up button
    LDA buttons
    AND #%00001000
    BEQ :+
    LDA paddle_y
    SEC
    SBC #PADDLE_SPEED
    STA paddle_y

    ; Down button
:   LDA buttons
    AND #%00000100
    BEQ :+
    LDA paddle_y
    CLC
    ADC #PADDLE_SPEED
    STA paddle_y

:   JSR ClampPaddle
    JSR UpdateOAM
```

## Clamping Boundaries

```asm
ClampPaddle:
    ; Top boundary
    LDA paddle_y
    CMP #PADDLE_TOP
    BCS :+               ; Branch if >= top
    LDA #PADDLE_TOP
    STA paddle_y

    ; Bottom boundary
:   LDA paddle_y
    CMP #PADDLE_BOTTOM
    BCC :+               ; Branch if < bottom
    LDA #PADDLE_BOTTOM
    STA paddle_y

:   RTS
```

## Control Feel

Different speeds create different gameplay feel:
- 1-2 px/frame: Slow, precise (puzzle games)
- 3 px/frame: **Good for Pong** (responsive but controllable)
- 4-5 px/frame: Fast, twitchy (action games)

## Building

```bash
ca65 paddle-control.asm -o paddle-control.o
ld65 paddle-control.o -C ../../nes.cfg -o paddle-control.nes
```
