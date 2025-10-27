# Lesson 013: Controller Basics

Reading NES controller button states.

## Files

- `controller-read.asm` - Read controller and test A button

## Concepts

- **Controller registers**: $4016 (controller 1), $4017 (controller 2)
- **Strobe sequence**: Write $01 then $00 to $4016 to latch button states
- **Serial reading**: 8 reads return buttons in order (A, B, Select, Start, Up, Down, Left, Right)
- **Button states**: Bit 0 of each read = pressed (1) or not pressed (0)

## ReadController Routine

```asm
ReadController:
    ; Strobe controller (latch current button states)
    LDA #$01
    STA $4016
    LDA #$00
    STA $4016

    ; Read 8 buttons
    LDX #$08
:   LDA $4016        ; Read one button (bit 0)
    LSR              ; Shift bit 0 into carry
    ROL buttons      ; Rotate carry into buttons variable
    DEX
    BNE :-
    RTS
```

Result in `buttons`:
- Bit 7: A button
- Bit 6: B button
- Bit 5: Select
- Bit 4: Start
- Bit 3: Up
- Bit 2: Down
- Bit 1: Left
- Bit 0: Right

## Testing Buttons

```asm
LDA buttons
AND #%10000000   ; Test bit 7 (A button)
BEQ not_pressed  ; Branch if zero (not pressed)
; Button is pressed
```

## Building

```bash
ca65 controller-read.asm -o controller-read.o
ld65 controller-read.o -C ../../nes.cfg -o controller-read.nes
```
