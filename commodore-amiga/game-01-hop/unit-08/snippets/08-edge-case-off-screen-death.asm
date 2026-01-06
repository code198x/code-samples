; Check if frog went off-screen
check_bounds_death:
            tst.w   frog_state
            bne.s   .done

            ; Check left edge
            move.w  frog_x,d0
            bmi.s   .kill               ; Negative = off left

            ; Check right edge
            cmp.w   #320-FROG_WIDTH,d0
            bgt.s   .kill

.done:
            rts

.kill:
            bsr     kill_frog
            rts
