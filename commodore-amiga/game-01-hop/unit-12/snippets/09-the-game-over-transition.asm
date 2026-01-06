; In the death handling code, after decrementing lives:
            subq.w  #1,lives
            bne.s   .still_alive

            ; No lives left - game over
            move.w  #MODE_GAMEOVER,game_mode
            rts

.still_alive:
            ; Reset for next life
            bsr     reset_frog
            move.w  #STATE_ALIVE,game_state
            rts
