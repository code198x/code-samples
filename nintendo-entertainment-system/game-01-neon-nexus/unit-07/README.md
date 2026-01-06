# Unit 7: Score

Score tracking and HUD display.

## What This Unit Covers

- Multi-byte score storage
- BCD (Binary Coded Decimal) arithmetic
- Nametable score rendering
- HUD layout design

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Score displays at top and increases when collecting items.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| BCD storage | Each nybble is 0-9 digit |
| Score bytes | 3 bytes = 6 digits (0-999999) |
| Tile offset | Add $30 to convert digit to tile |
| VBlank update | Write to nametable during VBlank |

## Score Addition

```asm
add_score:
    sed                 ; Set decimal mode
    clc
    lda score
    adc #$10            ; Add 10 points
    sta score
    lda score+1
    adc #$00            ; Carry
    sta score+1
    cld                 ; Clear decimal mode
    rts
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
