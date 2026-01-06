init_home:
            lea     home_slots,a0
            move.w  #NUM_SLOTS-1,d7

.loop:
            clr.w   SLOT_FILLED(a0)
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop
            rts
