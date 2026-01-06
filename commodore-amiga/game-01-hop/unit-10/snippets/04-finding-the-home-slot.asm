; Find which home slot the frog is in
; Returns: d0 = slot index (0-4) or -1 if in gap
find_home_slot:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7
            moveq   #0,d1               ; Slot index

.loop:
            ; Get slot X position
            move.w  SLOT_X(a0),d2

            ; Check if frog X is within this slot
            move.w  frog_x,d0
            cmp.w   d2,d0
            blt.s   .next               ; Frog left of slot

            add.w   #SLOT_WIDTH,d2
            cmp.w   d2,d0
            bge.s   .next               ; Frog right of slot

            ; Frog is in this slot!
            move.w  d1,d0
            rts

.next:
            add.w   #SLOT_SIZE,a0
            addq.w  #1,d1
            dbf     d7,.loop

            ; Not in any slot - in a gap
            moveq   #-1,d0
            rts
