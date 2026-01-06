# Unit 2: The Frog

Hardware sprite display for the player character.

## What This Unit Covers

- Amiga hardware sprite format
- Sprite pointer registers
- Sprite control words
- Colour register assignment

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. The frog sprite appears on screen.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Sprite data | 16-pixel wide, variable height |
| SPRxPT | Sprite pointer registers in copper |
| Control words | Position and vertical stop embedded in data |
| Sprite colours | COLOR17-19 for sprite 0 |

## Sprite Format

```asm
frog_data:
    dc.w    $5080, $5800    ; VSTART=80, HSTART=128, VSTOP=88
    dc.w    %0000011111100000, %0000000110000000    ; Line 1
    dc.w    %0001111111111000, %0000011111100000    ; Line 2
    ; ... 16 lines
    dc.w    0, 0            ; End marker
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
