# Lesson 007: Nametables

Writing tiles to the NES background 32×30 tile grid.

## Files

- `nametable.asm` - Basic nametable writing (fill first row, individual tiles)
- `coordinates.asm` - Addressing tiles by row/column coordinates

## Concepts

- **Nametable**: 32×30 tile grid at $2000-$23BF (960 bytes)
- **Tile addressing**: Address = $2000 + (row × 32) + column
- **PPUDATA auto-increment**: Address increments after each write
- **Attribute table**: $23C0-$23FF (controls palette selection)

## Nametable Structure

```
$2000-$23BF: Tile indices (960 bytes, 32 columns × 30 rows)
$23C0-$23FF: Attribute table (64 bytes, palette selection)
```

## Coordinate Calculation

For tile at row R, column C:
```
Address = $2000 + (R × 32) + C
```

Examples:
- Row 0, Column 0: $2000 + 0 = $2000
- Row 0, Column 31: $2000 + 31 = $201F
- Row 1, Column 0: $2000 + 32 = $2020
- Row 5, Column 10: $2000 + (5×32) + 10 = $20AA
- Row 29, Column 31: $2000 + (29×32) + 31 = $23BF (last tile)

## Attribute Table

Each byte in attribute table controls palette selection for 16×16 pixel area (4×4 tiles):
- Bits 0-1: Top-left 2×2 tiles
- Bits 2-3: Top-right 2×2 tiles
- Bits 4-5: Bottom-left 2×2 tiles
- Bits 6-7: Bottom-right 2×2 tiles

Value 0-3 selects palette 0-3 for that quadrant.
