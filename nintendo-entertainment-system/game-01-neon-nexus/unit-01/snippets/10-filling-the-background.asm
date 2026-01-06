.proc fill_background
    ; Set PPU address to first nametable ($2000)
    bit PPUSTATUS
    lda #$20
    sta PPUADDR
    lda #$00
    sta PPUADDR

    ; Fill with tile $00 (960 tiles = 30 rows x 32 cols)
    lda #$00                ; Tile index 0
    ldx #0
    ldy #4                  ; 4 x 256 = 1024 bytes
@outer:
@inner:
    sta PPUDATA
    inx
    bne @inner
    dey
    bne @outer
