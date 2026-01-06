@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    lda #0
    sta screen_drawn        ; trigger game over screen draw
    rts
