; Check if frog reached home zone
; Called from main loop when frog is alive
check_home_zone:
            ; Check if in home zone (Y position)
            move.w  frog_y,d0
            cmp.w   #HOME_TOP,d0
            blt.s   .done               ; Above home zone
            cmp.w   #HOME_BOT,d0
            bge.s   .done               ; Below home zone

            ; In home zone - check which slot (if any)
            bsr     find_home_slot
            tst.w   d0
            bmi.s   .in_gap             ; d0 = -1 means gap

            ; d0 = slot index (0-4)
            bsr     fill_home_slot
            bra.s   .done

.in_gap:
            ; Landed in gap between slots - death!
            bsr     kill_frog

.done:
            rts
