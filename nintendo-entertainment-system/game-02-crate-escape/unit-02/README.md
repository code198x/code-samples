# Unit 2: Background Tiles

Draw the level using background tiles.

## What This Unit Covers

- Pattern table (CHR) data
- Nametable structure
- Attribute table for colours

## Key Concepts

| Concept | Description |
|---------|-------------|
| Pattern table | $0000 or $1000, tile graphics |
| Nametable | $2000, 32×30 tile indices |
| Attribute table | $23C0, 2-bit palette per 16×16 area |
| Tile design | 8×8 pixels, 2 bitplanes |

## Level Layout

```asm
; Warehouse level - crates as platforms
level_data:
    .byte $00,$00,$00,$00,...  ; Row 0 (empty)
    .byte $00,$00,$00,$00,...  ; Row 1
    ; ...
    .byte $00,$01,$01,$00,...  ; Row with crate platform
    ; ...
    .byte $02,$02,$02,$02,...  ; Floor tiles
```

## Tile Definitions

```asm
; CHR data for tiles
tile_empty:     ; Tile $00
    .byte %00000000
    .byte %00000000
    ; ... 8 rows × 2 planes

tile_crate:     ; Tile $01
    .byte %11111111
    .byte %10000001
    .byte %10111101
    .byte %10100101
    ; ...
```

## Loading Nametable

```asm
load_level:
    lda PPUSTATUS       ; Reset latch
    lda #$20
    sta PPUADDR         ; $2000 = nametable 0
    lda #$00
    sta PPUADDR

    ldx #0
@loop:
    lda level_data,x
    sta PPUDATA
    inx
    cpx #$3C0           ; 960 bytes
    bne @loop
```

## Expected Result

Warehouse level visible with crate platforms and floor.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
