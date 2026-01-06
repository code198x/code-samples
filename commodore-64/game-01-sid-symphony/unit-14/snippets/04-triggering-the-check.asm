; Game over!
            jsr check_high_score    ; Check for new high score
            lda #STATE_GAMEOVER
            sta game_state
            jsr draw_gameover_screen
