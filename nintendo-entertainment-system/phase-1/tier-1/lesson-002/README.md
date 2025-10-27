# Lesson 002: Understanding PPU

Code samples for NES Phase 1, Tier 1, Lesson 2.

## Files

- `colour-change.asm` - Basic example: Change background to blue using PPU registers
- `colour-palette.asm` - Full palette setup with multiple colours

## Building

Using ca65/ld65 (cc65 toolchain):

```bash
ca65 colour-change.asm -o colour-change.o
ld65 colour-change.o -C nes.cfg -o colour-change.nes

ca65 colour-palette.asm -o colour-palette.o
ld65 colour-palette.o -C nes.cfg -o colour-palette.nes
```

## Testing

Load the resulting `.nes` files in Mesen or another NES emulator.

**colour-change.nes** - Should display solid blue screen
**colour-palette.asm** - Should display screen using first palette colour (black)

## Learning Outcomes

After assembling and running these examples, you will understand:

- How to access PPU memory through $2006/$2007 registers
- The two-step process for setting PPU address (high byte, then low byte)
- Palette memory layout ($3F00-$3F1F)
- How background colour 0 controls the entire screen colour when no tiles are drawn
- The auto-increment behaviour of PPUADDR after each PPUDATA access

## Key Concepts

### PPU Registers

- **$2006 (PPUADDR)** - Set PPU memory address (write twice: high byte, then low byte)
- **$2007 (PPUDATA)** - Read/write PPU memory at current address
- **$2001 (PPUMASK)** - Control rendering (bit 3 = show background)

### Palette Structure

- Background palettes: $3F00-$3F0F (4 palettes × 4 colours)
- Sprite palettes: $3F10-$3F1F (4 palettes × 4 colours)
- Each palette entry is a single byte indexing into the NES's 64-colour master palette

### Common NES Colours

- $0F - Black
- $00 - Dark grey
- $10 - Light grey
- $20/$30 - White
- $12 - Blue
- $16 - Red
- $27 - Orange
- $29 - Green
- $1A - Light green
- $21 - Sky blue
