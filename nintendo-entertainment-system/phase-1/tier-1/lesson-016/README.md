# Lesson 016: Boundaries

Complete paddle control with robust boundary and conflict handling.

## Files

- `complete-control.asm` - Polished player control system

## Concepts

- **Edge case handling**: Save/restore pattern for conflicts
- **Order of operations**: Input → Update → Clamp → Render
- **Conflict resolution**: Up+Down simultaneously = no movement
- **Boundary constants**: Clear min/max values

## UpdatePaddle Routine

```asm
UpdatePaddle:
    ; Save original position
    LDA paddle_y
    PHA

    ; Handle Up
    LDA buttons
    AND #%00001000
    BEQ :+
    LDA paddle_y
    SEC
    SBC #PADDLE_SPEED
    STA paddle_y

    ; Handle Down
:   LDA buttons
    AND #%00000100
    BEQ :+
    LDA paddle_y
    CLC
    ADC #PADDLE_SPEED
    STA paddle_y

    ; Check conflict (both pressed)
:   LDA buttons
    AND #%00001100
    CMP #%00001100
    BNE :+
    PLA                  ; Restore original
    STA paddle_y
    JMP done

    ; Apply boundaries
:   PLA                  ; Discard saved value
    ; [Clamping code]
done:
    RTS
```

## Why Save/Restore?

Handles Up+Down conflict cleanly:
1. Save position before any changes
2. Apply both inputs (would move both directions)
3. Detect conflict (both buttons set)
4. Restore original position (net zero movement)

Alternative: Priority system (Up takes precedence over Down).

## Boundary Constants

```asm
PADDLE_TOP = 8
PADDLE_BOTTOM = 216   ; 240 - 16 (sprite height) - 8 (border)
PADDLE_SPEED = 3
```

Clear constants improve readability and make tuning easier.

## Testing Checklist

- [ ] Paddle stops at top edge
- [ ] Paddle stops at bottom edge
- [ ] Up+Down simultaneously = no movement
- [ ] No visual flicker at boundaries
- [ ] Smooth movement throughout range
- [ ] No wrap-around (255 → 0 or 0 → 255)

## Building

```bash
ca65 complete-control.asm -o complete-control.o
ld65 complete-control.o -C ../../nes.cfg -o complete-control.nes
```
