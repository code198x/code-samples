; Clear shadow OAM to $FF (sprites off-screen)
    lda #$ff
    ldx #0
@clear_oam:
    sta $0200, x
    inx
    bne @clear_oam
