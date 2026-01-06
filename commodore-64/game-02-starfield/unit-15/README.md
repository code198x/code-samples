# Unit 15: Score and Lives

Add scoring system and lives counter.

## What This Unit Covers

- Score display using screen characters
- Lives counter
- Player death and respawn
- Game over condition

## Key Concepts

| Concept | Description |
|---------|-------------|
| Score storage | 3 bytes for 6-digit score |
| Score display | Convert to screen codes |
| Lives | Start with 3, lose on enemy collision |
| Game over | Lives reach 0 |

## Score Display

```asm
; Score in BCD for easy display
score:          !byte 0, 0, 0  ; 00 00 00

add_score:
    sed                 ; Decimal mode
    clc
    lda score+2
    adc #$10            ; Add 10 points
    sta score+2
    lda score+1
    adc #0
    sta score+1
    lda score
    adc #0
    sta score
    cld                 ; Clear decimal mode
    jsr display_score
    rts
```

## Lives Display

```asm
lives:          !byte 3

display_lives:
    lda lives
    ora #$30            ; Convert to screen code
    sta $0400           ; Top-left corner
    rts
```

## Expected Result

Score increases when enemies destroyed. Lives decrease on player collision. Game over when lives exhausted.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
