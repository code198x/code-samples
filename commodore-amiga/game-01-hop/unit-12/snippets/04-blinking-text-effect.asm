blink_timer:    dc.w    0
blink_visible:  dc.w    1       ; 1 = visible, 0 = hidden

update_blink:
            addq.w  #1,blink_timer
            cmpi.w  #30,blink_timer
            blt.s   .no_toggle
            clr.w   blink_timer
            ; Toggle visibility
            tst.w   blink_visible
            beq.s   .make_visible
            clr.w   blink_visible
            bra.s   .no_toggle
.make_visible:
            move.w  #1,blink_visible
.no_toggle:
            rts
