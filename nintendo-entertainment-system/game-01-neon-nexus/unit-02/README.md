# Unit 2: The Player

OAM sprite display for player character.

## What This Unit Covers

- OAM (Object Attribute Memory) format
- Sprite DMA transfer
- Sprite positioning
- Sprite attributes (palette, flip, priority)

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. The player sprite appears on screen.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| OAM format | Y, tile, attribute, X per sprite |
| Shadow OAM | RAM buffer at $0200-$02FF |
| OAM DMA | Write $02 to $4014 for transfer |
| Sprite palette | Uses palettes 4-7 ($3F10-$3F1F) |

## OAM Format

```asm
; Each sprite: 4 bytes
; Byte 0: Y position (top of sprite)
; Byte 1: Tile index
; Byte 2: Attributes (palette, priority, flip)
; Byte 3: X position (left of sprite)

oam_player:
    .byte 100       ; Y
    .byte $01       ; Tile
    .byte $00       ; No flip, palette 0
    .byte 128       ; X
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
