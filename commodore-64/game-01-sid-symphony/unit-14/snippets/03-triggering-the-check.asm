; No notes left - victory!
            jsr check_high_score    ; Check for new high score
            lda #STATE_VICTORY
            sta game_state
            jsr draw_victory_screen
