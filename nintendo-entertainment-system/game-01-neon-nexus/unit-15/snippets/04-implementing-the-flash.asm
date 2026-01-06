lose_life:
    dec lives
    jsr play_death_sound
    lda lives
    beq @game_over
    jsr respawn_player
    rts
@game_over:
    jsr check_high_score
    lda #FLASH_TIME
    sta flash_timer
    lda #STATE_GAMEOVER
    sta game_state
    lda #0
    sta screen_drawn
    sta pause_flag

    ; Start the flash - enable emphasis bits
    lda #%11111110          ; RGB emphasis + display on
    sta PPUMASK
    rts
