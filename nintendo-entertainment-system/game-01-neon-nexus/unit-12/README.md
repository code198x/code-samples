# Unit 12: High Score

Best score tracking and display.

## What This Unit Covers

- High score comparison
- Score persistence (session)
- High score display
- New high celebration

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. High score shown on title and game over.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Multi-byte compare | Compare high bytes first |
| Score copy | Copy current to high if greater |
| Display format | Same rendering as current score |
| New high flag | Trigger celebration effect |

## High Score Check

```asm
check_high_score:
    ; Compare byte 2 (highest)
    lda score+2
    cmp high_score+2
    bcc @not_high
    bne @new_high
    ; Compare byte 1
    lda score+1
    cmp high_score+1
    bcc @not_high
    bne @new_high
    ; Compare byte 0
    lda score
    cmp high_score
    bcc @not_high
@new_high:
    ; Copy score to high_score
    ldx #2
@copy:
    lda score,x
    sta high_score,x
    dex
    bpl @copy
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
