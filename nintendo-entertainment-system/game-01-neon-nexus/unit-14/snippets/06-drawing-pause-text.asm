draw_pause_text:
    lda PPUSTATUS       ; reset latch
    lda #$21            ; nametable row ~12
    sta PPUADDR
    lda #$CD            ; centre column
    sta PPUADDR

    lda #TILE_P
    sta PPUDATA
    lda #TILE_A
    sta PPUDATA
    lda #TILE_U
    sta PPUDATA
    lda #TILE_S
    sta PPUDATA
    lda #TILE_E
    sta PPUDATA
    lda #TILE_D
    sta PPUDATA

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts
