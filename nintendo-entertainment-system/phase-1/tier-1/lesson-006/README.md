# Lesson 006: Palettes

Loading background palettes for NES colour graphics.

## Files

- `palettes.asm` - Basic palette loading (classic Pong colours)
- `colour-schemes.asm` - Multiple palettes loaded from data table

## Concepts

- **Palette memory**: $3F00-$3F1F (16 bytes background, 16 bytes sprites)
- **4 palettes × 4 colours**: Each palette selects 4 colours from 64-colour master palette
- **Universal background**: $3F00 shows through all transparent pixels (colour 0)
- **Loading pattern**: Reset PPU latch, write $3F00 to PPUADDR, write 16 bytes to PPUDATA

## Palette Structure

```
$3F00: Universal background colour (seen through all colour 0 pixels)
$3F01-$3F03: Palette 0 colours 1-3
$3F04: Unused (mirror of $3F00)
$3F05-$3F07: Palette 1 colours 1-3
$3F08: Unused (mirror of $3F00)
$3F09-$3F0B: Palette 2 colours 1-3
$3F0C: Unused (mirror of $3F00)
$3F0D-$3F0F: Palette 3 colours 1-3
```

## NES 64-Colour Palette

Colours referenced by hexadecimal index $00-$3F. Common Pong colours:
- `$0F`: Black
- `$00`: Dark grey/black
- `$10`: Light grey
- `$20`: White
- `$30`: Bright white
- `$2C`: Cyan
- `$16`: Red
