draw_game_over:
    ; Set PPU address for "GAME OVER" (row 12, column 11)
    lda PPUSTATUS
    lda #$21
    sta PPUADDR
    lda #$8B                ; $218B
    sta PPUADDR

    ldx #0
@loop:
    lda gameover_text, x
    beq @done
    sta PPUDATA
    inx
    bne @loop

@done:
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL
    rts

gameover_text:
    .byte 16, 14, 17, 15    ; GAME
    .byte 0                 ; space
    .byte 19, 25, 15, 21    ; OVER
    .byte 0                 ; terminator
