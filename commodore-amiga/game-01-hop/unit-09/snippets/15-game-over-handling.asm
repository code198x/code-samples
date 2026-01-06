main_loop:
            bsr     wait_vblank

            ; Check for game over
            cmp.w   #STATE_GAMEOVER,frog_state
            beq.s   .game_over_loop

            ; ... normal game code ...
            bra     main_loop

.game_over_loop:
            ; Game is over - just wait for exit
            btst    #6,CIAA_PRA
            bne.s   .game_over_loop

            ; Exit
            bra     exit
