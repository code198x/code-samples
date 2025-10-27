# Lesson 010: OAM Structure

Loading sprite data into Object Attribute Memory.

## Files

- `oam-sprites.asm` - Display paddle sprite using OAM buffer

## Concepts

- **OAM (Object Attribute Memory)**: 256 bytes in PPU storing 64 sprites × 4 bytes
- **OAM buffer**: CPU builds sprite data at $0200-$02FF in RAM
- **4-byte format**: Y position, tile index, attributes, X position
- **Hiding sprites**: Set Y = $FF to move sprite off-screen

## 4-Byte Sprite Format

Each sprite uses 4 consecutive bytes in OAM:

```
Byte 0: Y position (0-239, but 0-1 hides sprite at top)
Byte 1: Tile index (0-255, selects pattern table tile)
Byte 2: Attributes (palette, priority, flip bits)
Byte 3: X position (0-255)
```

## Attribute Byte (Byte 2)

```
Bits 0-1: Palette (0-3, selects sprite palette)
Bits 2-4: Unused
Bit 5:    Priority (0=front, 1=behind background colour 1-3)
Bit 6:    Flip horizontal
Bit 7:    Flip vertical
```

## OAM Memory Layout

```
$0200-$0203: Sprite 0
$0204-$0207: Sprite 1
$0208-$020B: Sprite 2
...
$02FC-$02FF: Sprite 63
```
