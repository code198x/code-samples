draw_title_screen:
    ; ... hide sprites ...

    ; Draw title
    ; ... existing title code ...

    ; Draw "PRESS START"
    ; ... existing press code ...

    ; Draw version "V1.0" at bottom right
    lda #$23            ; near bottom of nametable
    sta PPUADDR
    lda #$98            ; right side
    sta PPUADDR

    lda #TILE_V
    sta PPUDATA
    lda #TILE_1
    sta PPUDATA
    lda #0              ; period (empty tile works)
    sta PPUDATA
    lda #TILE_0
    sta PPUDATA

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts
