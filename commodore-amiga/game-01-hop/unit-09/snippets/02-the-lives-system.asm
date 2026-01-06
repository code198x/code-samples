kill_frog:
            tst.w   frog_state
            bne.s   .done

            move.w  #STATE_DYING,frog_state
            move.w  #DEATH_FRAMES,death_timer

            ; Lose a life
            subq.w  #1,lives

.done:
            rts
