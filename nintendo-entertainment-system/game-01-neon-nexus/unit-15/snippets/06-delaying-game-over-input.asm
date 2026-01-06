gameover_state:
    jsr update_flash

    lda screen_drawn
    bne @check_delay

    ; Don't draw until flash is done
    lda flash_timer
    bne game_loop

    jsr draw_game_over
    lda #1
    sta screen_drawn

@check_delay:
    lda gameover_delay
    beq @check_restart
    dec gameover_delay
    jmp game_loop

@check_restart:
    jsr read_controller
    lda buttons
    and #BTN_START
    beq game_loop

    jsr clear_playfield
    jsr init_game
    lda #STATE_PLAYING
    sta game_state
    lda #0
    sta screen_drawn
    jmp game_loop
