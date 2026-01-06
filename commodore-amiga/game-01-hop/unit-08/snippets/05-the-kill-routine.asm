DEATH_FRAMES    equ 30              ; Half second at 50fps

kill_frog:
            ; Already dead? Don't kill again
            tst.w   frog_state
            bne.s   .done

            move.w  #STATE_DYING,frog_state
            move.w  #DEATH_FRAMES,death_timer
.done:
            rts
