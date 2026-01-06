# Unit 3: Paddle Drawing

Create the player paddle using XOR technique.

## What This Unit Covers

- Calculating screen address from coordinates
- XOR drawing for easy erase
- Paddle sprite data

## Key Concepts

| Concept | Description |
|---------|-------------|
| XOR drawing | Draw once to show, draw again to erase |
| Screen address | Complex calculation from Y coordinate |
| Paddle size | 24 pixels wide × 4 pixels tall |
| Fixed Y | Paddle stays at bottom of screen |

## Screen Address Calculation

```asm
; Get screen address for Y coordinate in A
; Returns HL = screen address
get_screen_addr:
    ld l, a
    and %00000111       ; Y mod 8
    or %01000000        ; Screen base $4000
    ld h, a
    ld a, l
    and %00111000       ; (Y/8) mod 8
    rrca
    rrca
    rrca
    or %00000000        ; X byte offset (add later)
    ld l, a
    ld a, l
    and %11000000       ; Y/64
    rrca
    rrca
    rrca
    or h
    ld h, a
    ret
```

## Paddle Drawing

```asm
draw_paddle:
    ; XOR paddle sprite at paddle_x, paddle_y
    ; 3 bytes wide × 4 rows
```

## Expected Result

Paddle visible at bottom of playfield. Drawing again erases it cleanly.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
