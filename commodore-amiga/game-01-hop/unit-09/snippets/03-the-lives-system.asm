.respawn:
            ; Check for game over
            tst.w   lives
            beq.s   .game_over

            ; Respawn
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            move.w  #STATE_ALIVE,frog_state
            clr.w   on_log
            bra.s   .done

.game_over:
            move.w  #STATE_GAMEOVER,frog_state
