; Check for water death
; Must be called AFTER log platform check
check_water_death:
            ; Only check if alive
            tst.w   frog_state
            bne.s   .done

            ; Check if in water zone
            move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .done               ; Above water
            cmp.w   #WATER_BOT,d0
            bge.s   .done               ; Below water

            ; In water - are we on a log?
            tst.w   on_log
            bne.s   .done               ; Safe on log

            ; Not on log = drowning!
            bsr     kill_frog
.done:
            rts
