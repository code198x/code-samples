# Lesson 009: Sprite Basics

Creating sprite graphics in CHR-ROM pattern table 1.

## Files

- `sprite-tiles.asm` - Paddle and ball tile definitions in CHR-ROM

## Concepts

- **64 hardware sprites**: NES supports 64 sprites simultaneously
- **8×8 or 8×16 mode**: PPUCTRL bit 5 selects sprite size
- **Pattern table 1**: Sprites use $1000-$1FFF (second 4KB bank)
- **Transparent colour 0**: Background shows through pixel value 0
- **Sprite palettes**: $3F10-$3F1F (separate from background palettes)

## Tile Designs

### Paddle (8×16 sprite)
- Tile $00: Top half (4 pixels wide vertical bar)
- Tile $01: Bottom half (identical pattern)
- Pattern: $3C = 00111100 (middle 4 pixels colour 3)

### Ball (8×8 sprite)
- Tile $02: Diamond shape
- Rows: $00, $18, $3C, $7E, $7E, $3C, $18, $00
- Creates circular appearance with 2-bit pixels
