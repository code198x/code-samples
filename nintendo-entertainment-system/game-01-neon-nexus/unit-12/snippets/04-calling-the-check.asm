@game_over:
    jsr check_high_score    ; compare before changing state

    lda #STATE_GAMEOVER
    sta game_state
    lda #0
    sta screen_drawn
    rts
