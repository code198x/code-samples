# Unit 7: Platform Detection

Detect solid tiles below the player.

## What This Unit Covers

- Converting position to tile coordinates
- Reading tile data
- Collision flags

## Key Concepts

| Concept | Description |
|---------|-------------|
| Tile coords | Position ÷ 8 |
| Collision map | Which tiles are solid |
| Check points | Player's feet positions |
| Look-ahead | Check where player will be |

## Position to Tile

```asm
; Convert pixel X,Y to tile index
; Input: A = pixel position
; Output: A = tile coordinate
pixel_to_tile:
    lsr a
    lsr a
    lsr a               ; Divide by 8
    rts
```

## Collision Check

```asm
; Check if tile at (X,Y) is solid
; X = tile X, Y = tile Y
; Returns: A = 1 if solid, 0 if empty
check_tile_solid:
    ; Calculate offset: Y * 32 + X
    tya
    asl a
    asl a
    asl a
    asl a
    asl a               ; Y * 32
    sta temp
    txa
    clc
    adc temp            ; + X
    tax

    lda level_data,x
    cmp #TILE_SOLID
    beq @solid
    lda #0
    rts

@solid:
    lda #1
    rts
```

## Foot Check

```asm
check_ground:
    ; Check tile below player's feet
    lda player_x
    jsr pixel_to_tile
    tax

    lda player_y
    clc
    adc #16             ; Bottom of player
    jsr pixel_to_tile
    tay

    jsr check_tile_solid
    sta player_grounded
    rts
```

## Expected Result

Game knows when player is above solid tiles.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
