; Fill a home slot
; d0 = slot index
fill_home_slot:
            ; Calculate slot address
            lea     home_slots,a0
            move.w  d0,d1
            lsl.w   #2,d1               ; * 4 (SLOT_SIZE)
            add.w   d1,a0

            ; Check if already filled
            tst.w   SLOT_FILLED(a0)
            bne.s   .already_filled

            ; Fill the slot
            move.w  #1,SLOT_FILLED(a0)

            ; Award bonus points
            add.l   #SCORE_HOME,score

            ; Reset frog to start
            move.w  #FROG_START_X,frog_x
            move.w  #FROG_START_Y,frog_y
            clr.w   on_log

            ; Check if all slots filled
            bsr     check_level_complete
            rts

.already_filled:
            ; Slot already has a frog - death!
            bsr     kill_frog
            rts
