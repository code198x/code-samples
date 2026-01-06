ml_not_gameover:
            cmp #STATE_VICTORY
            bne ml_not_victory
            jsr update_victory
            jmp main_loop
ml_not_victory:
            ; STATE_PAUSED (Unit 15)
            jsr update_paused
            jmp main_loop
