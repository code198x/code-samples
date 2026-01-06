# Unit 1: Screen Setup

Establish the playfield with borders.

## What This Unit Covers

- Clearing the screen
- Drawing the play area border
- Setting colours (PAPER, INK, BORDER)

## Key Concepts

| Concept | Description |
|---------|-------------|
| CLS | Clear screen (ROM routine at $0DAF) |
| BORDER | Port $FE bits 0-2 |
| Attribute | INK (0-2), PAPER (3-5), BRIGHT (6), FLASH (7) |
| Screen layout | 256×192 pixels, 32×24 attributes |

## Border Drawing

```asm
draw_border:
    ; Top line
    ld hl, $5800        ; Attribute memory
    ld b, 32            ; Width
    ld a, %01000111     ; White on blue
border_top:
    ld (hl), a
    inc hl
    djnz border_top
    ; ... sides and bottom
```

## Expected Result

Blue playfield with white border outline. Clean area ready for game elements.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
