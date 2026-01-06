enter_game_over:
            ; Check if score qualifies for high score table
            bsr     check_high_score
            tst.w   d0
            bmi.s   .not_high_score

            ; New high score!
            move.w  d0,hs_position
            bsr     insert_high_score
            bsr     init_name_entry
            rts

.not_high_score:
            move.w  #MODE_GAMEOVER,game_mode
            move.w  #30,fire_delay
            rts
