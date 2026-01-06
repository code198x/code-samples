; Handle note movement
            dec move_timer
            bne ug_no_move
            lda current_speed       ; Use current speed based on multiplier
            sta move_timer
            jsr move_notes
ug_no_move:
