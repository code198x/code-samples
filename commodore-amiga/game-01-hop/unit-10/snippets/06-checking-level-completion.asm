; Check if all home slots are filled
check_level_complete:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7

.loop:
            tst.w   SLOT_FILLED(a0)
            beq.s   .not_done           ; Found empty slot
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop

            ; All slots filled - level complete!
            add.l   #SCORE_LEVEL,score
            bsr     reset_level
            rts

.not_done:
            rts

; Reset level - clear all slots
reset_level:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7

.loop:
            clr.w   SLOT_FILLED(a0)
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop

            ; Could also increase difficulty here
            ; (faster cars, fewer logs, etc.)
            rts
