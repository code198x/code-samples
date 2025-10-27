# Lesson 005: Pattern Tables

CHR-ROM tile graphics for NES background rendering.

## Files

- `basic-tiles.asm` - Basic tile set with solid, border, and line tiles

## Concepts

- **Pattern tables**: 8KB CHR-ROM holding 512 tiles (8×8 pixels each)
- **2-bit pixels**: 4 colours per tile, encoded in two bit planes
- **16 bytes per tile**: 8 bytes plane 0 + 8 bytes plane 1

## Tile Encoding

Each tile row is 2 bytes (1 byte per plane):
- Plane 0 byte provides bit 0 of each pixel
- Plane 1 byte provides bit 1 of each pixel
- Combined: pixel value 0-3 (palette index)
