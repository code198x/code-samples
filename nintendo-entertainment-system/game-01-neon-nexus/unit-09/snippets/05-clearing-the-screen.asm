clear_playfield:
    ; Clear rows 8-16 of nametable (where text appears)
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$00                ; start of row 8
    sta PPUADDR

    lda #0                  ; blank tile
    ldx #0
@loop:
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA
    sta PPUDATA             ; 4 at a time for speed
    inx
    cpx #64                 ; 256 tiles = 8 rows
    bne @loop

    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    rts
