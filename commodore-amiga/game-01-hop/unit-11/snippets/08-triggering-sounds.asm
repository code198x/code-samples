kill_frog:
            tst.w   frog_state
            bne.s   .done

            move.w  #STATE_DYING,frog_state
            move.w  #DEATH_FRAMES,death_timer
            subq.w  #1,lives

            bsr     play_death_sound    ; ADD THIS
.done:
            rts
