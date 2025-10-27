# Lesson 008: Playfield

Complete Pong court synthesis using tiles, palettes, and nametables.

## Files

- `pong-playfield.asm` - Complete playfield with borders and center line

## Concepts

- **Subroutines**: JSR/RTS for reusable code blocks
- **Code organization**: Separate initialization, drawing, and rendering
- **Efficient tile writing**: Loops for borders, calculated addresses for center line
- **Background synthesis**: Combining tiles, palettes, and nametable

## Playfield Structure

```
+--------------------------------+
|  Top Border (2 rows)           |
+--------------------------------+
|                |               |
|                |               |
|   Play Area    | Center Line   |
|                |               |
|                |               |
+--------------------------------+
|  Bottom Border (2 rows)        |
+--------------------------------+
```

## Subroutines

### LoadPalettes
Loads background palettes from RODATA table using indexed addressing.

### DrawPlayfield
Orchestrates playfield creation:
1. Clear nametable
2. Draw top border (2 rows)
3. Draw bottom border (2 rows)
4. Draw center line (vertical)

### ClearNametable
Fills nametable with blank tiles (tile $00).

## Tiles Used

- **Tile $00**: Blank (transparent)
- **Tile $01**: Solid block (unused in playfield)
- **Tile $02**: Top border (2 pixels thick at top)
- **Tile $03**: Center line (2 pixels wide vertical)

## Address Calculation

Center line at column 15 requires calculating address for each row:
```
Address = $2000 + (row × 32) + column
```

Code multiplies Y (row) by 32 using five left shifts (× 2^5 = × 32), then adds column 15.
