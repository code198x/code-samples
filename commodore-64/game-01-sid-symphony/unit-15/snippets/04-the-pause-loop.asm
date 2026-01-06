update_paused:
            ; Check for P key to unpause
            jsr check_pause_key
            bne up_done

            ; P just pressed - unpause
            jsr erase_paused_text
            lda #STATE_PLAYING
            sta game_state

up_done:
            rts
