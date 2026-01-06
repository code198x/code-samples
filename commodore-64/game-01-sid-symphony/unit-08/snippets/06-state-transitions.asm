trigger_game_over:
            lda #STATE_GAMEOVER
            sta game_state
            jsr draw_gameover_screen
            rts
