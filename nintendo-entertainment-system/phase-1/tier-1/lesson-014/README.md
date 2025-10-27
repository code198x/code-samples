# Lesson 014: Button Detection

Detecting multiple buttons including D-pad directions.

## Files

- `button-detection.asm` - Test Up/Down buttons for paddle control

## Concepts

- **Bit masking**: AND to isolate specific button bits
- **Multiple buttons**: Test each button independently
- **D-pad handling**: Up/Down for vertical movement
- **Button state logic**: Z flag indicates pressed/not pressed

## Testing Individual Buttons

```asm
; Test Up button (bit 3)
LDA buttons
AND #%00001000
BEQ not_pressed  ; Z set = not pressed
; Button pressed

; Test Down button (bit 2)
LDA buttons
AND #%00000100
BEQ not_pressed
; Button pressed
```

## Bit Masks for All Buttons

```
A button:      AND #%10000000
B button:      AND #%01000000
Select:        AND #%00100000
Start:         AND #%00010000
Up:            AND #%00001000
Down:          AND #%00000100
Left:          AND #%00000010
Right:         AND #%00000001
```

## Handling Simultaneous Presses

Multiple buttons can be pressed simultaneously. Test each independently:

```asm
; Up pressed?
LDA buttons
AND #%00001000
BEQ :+
; Handle Up
:

; Down pressed?
LDA buttons
AND #%00000100
BEQ :+
; Handle Down
:
```

## Building

```bash
ca65 button-detection.asm -o button-detection.o
ld65 button-detection.o -C ../../nes.cfg -o button-detection.nes
```
