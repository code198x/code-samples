# Unit 3: Player Sprite

Display the player character using OAM.

## What This Unit Covers

- OAM (Object Attribute Memory) structure
- Sprite positioning
- Metasprites (multi-tile characters)

## Key Concepts

| Concept | Description |
|---------|-------------|
| OAM | 256 bytes for 64 sprites |
| Sprite format | Y, tile, attributes, X (4 bytes) |
| OAM DMA | Fast copy from $0200 |
| Metasprite | Multiple sprites for larger character |

## OAM Structure

```asm
; Each sprite: Y, Tile, Attr, X
; Player is 16×16 (4 sprites)
OAM = $0200

player_y:       .res 1
player_x:       .res 1

update_player_sprites:
    ; Top-left sprite
    lda player_y
    sta OAM+0           ; Y
    lda #$00            ; Tile index
    sta OAM+1
    lda #$00            ; Attributes
    sta OAM+2
    lda player_x
    sta OAM+3           ; X

    ; Top-right sprite
    lda player_y
    sta OAM+4
    lda #$01
    sta OAM+5
    lda #$00
    sta OAM+6
    lda player_x
    clc
    adc #8
    sta OAM+7
    ; ... bottom sprites
```

## OAM DMA

```asm
nmi:
    ; Push OAM data
    lda #$00
    sta OAMADDR
    lda #$02
    sta OAMDMA          ; Copy $0200-$02FF to OAM
```

## Expected Result

Player character visible on screen, positioned at starting location.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
