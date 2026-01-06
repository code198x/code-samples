update_game:
            ; Check for pause key (P)
            jsr check_pause_key
            bne ug_no_pause

            ; P just pressed - pause game
            jsr silence_sid
            jsr draw_paused_text
            lda #STATE_PAUSED
            sta game_state
            rts
ug_no_pause:
            ; ... rest of game update
