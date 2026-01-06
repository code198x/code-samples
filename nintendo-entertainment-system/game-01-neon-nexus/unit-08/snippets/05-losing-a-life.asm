lose_life:
    dec lives           ; one fewer life

    lda lives
    beq @game_over      ; no lives left?

    ; Still have lives - respawn
    jsr respawn_player
    rts

@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    rts
