; Draw home zone
draw_home_zone:
            lea     home_slots,a0
            lea     CUSTOM,a5
            move.w  #NUM_SLOTS-1,d7

.loop:
            move.w  SLOT_X(a0),d1       ; X position
            move.w  #HOME_TOP,d2        ; Y position

            tst.w   SLOT_FILLED(a0)
            bne.s   .draw_filled

            ; Draw empty slot (dark rectangle)
            bsr     draw_empty_slot
            bra.s   .next

.draw_filled:
            ; Draw filled slot (with frog icon)
            bsr     draw_filled_slot

.next:
            add.w   #SLOT_SIZE,a0
            dbf     d7,.loop
            rts
