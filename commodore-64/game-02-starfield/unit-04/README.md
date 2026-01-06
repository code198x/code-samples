# Unit 4: Joystick Reading

Read joystick input from CIA port.

## What This Unit Covers

- CIA #1 port structure
- Reading joystick directions
- Reading fire button state

## Key Concepts

| Concept | Description |
|---------|-------------|
| CIA #1 Port A | $DC00 - joystick port 2 |
| Direction bits | Bits 0-3 (inverted: 0 = pressed) |
| Fire button | Bit 4 (inverted: 0 = pressed) |

## Bit Layout

| Bit | Direction |
|-----|-----------|
| 0 | Up |
| 1 | Down |
| 2 | Left |
| 3 | Right |
| 4 | Fire |

## Reading Pattern

```asm
    lda $DC00       ; Read joystick
    lsr             ; Bit 0 → Carry (Up)
    bcs not_up
    ; Handle up
not_up:
```

## Expected Result

Program reads joystick and displays direction (debug output or visual feedback).

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
