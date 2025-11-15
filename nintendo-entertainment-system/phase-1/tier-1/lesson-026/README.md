# Lesson 026: Number to Tiles

Convert decimal numbers (0-99) to tile indices for score display.

## Concepts Demonstrated

- **Decimal to BCD**: Extract tens and ones digits
- **Subtraction algorithm**: Count how many tens fit
- **Tile mapping**: Digits $30-$39 = ASCII '0'-'9'
- **CHR-ROM digits**: Number tiles 0-9 in pattern table

## Algorithm

```asm
DecimalToTiles:
    ; Input: A = 47 (example)
    LDX #0              ; tens counter
@count_tens:
    CMP #10
    BCC @done_tens      ; < 10? Done
    SBC #10             ; 47-10=37, 37-10=27, 27-10=17, 17-10=7
    INX                 ; X = 4 (four tens)
    JMP @count_tens
@done_tens:
    ; A = 7 (ones), X = 4 (tens)
    ; Add $30 to get tile indices ($34, $37)
```

## Building

```bash
ca65 number-to-tiles.asm -o number-to-tiles.o
ld65 number-to-tiles.o -C ../lesson-001/nes.cfg -o number-to-tiles.nes
```

## Testing

Scores stored as decimal, `DecimalToTiles` converts for display.

## What Changed from Lesson 025

1. Added `DecimalToTiles` function
2. `digit_tens` and `digit_ones` variables
3. Number tiles $30-$39 in CHR-ROM
4. Subtraction-based decimal extraction
