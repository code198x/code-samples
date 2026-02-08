write_sprite_pos:
            move.w  CR_STATE(a2),d0
            cmp.w   #STATE_SAVED,d0
            beq.s   .hide

            ; ...normal position packing...

.hide:
            ; Saved creature — hide sprite (VSTART=VSTOP=0)
            move.w  #0,(a0)+
            move.w  #0,(a0)
            rts
