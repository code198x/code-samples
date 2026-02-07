    ; --- Write ground tiles (rows 26-29) ---
    bit PPUSTATUS
    lda #$23
    sta PPUADDR
    lda #$40
    sta PPUADDR             ; PPU address $2340 (row 26)

    lda #GROUND_TILE        ; Tile index 3
    ldx #128                ; 4 rows × 32 tiles
@write_ground:
    sta PPUDATA
    dex
    bne @write_ground
