drivelanes:
            lea     vehtab,a2
            moveq   #3-1,d6             ; Three vehicles
.veh:
            move.l  (a2)+,a0            ; A0 = where this one's x lives
            move.w  (a2)+,d1            ; D1 = its speed (signed)
            move.w  (a0),d0
            add.w   d1,d0
            tst.w   d1
            bmi.s   .leftward
            cmp.w   #320,d0             ; Rightward: clear of the right edge?
            blt.s   .store
            move.w  #-16,d0             ; Re-enter from the left
            bra.s   .store
.leftward:
            cmp.w   #-16,d0             ; Leftward: clear of the left edge?
            bgt.s   .store
            move.w  #320,d0             ; Re-enter from the right
.store:
            move.w  d0,(a0)
            dbf     d6,.veh
            rts

vehtab:     dc.l    tractx
            dc.w    TRACTOR_SPEED
            dc.l    cartx
            dc.w    CART_SPEED
            dc.l    roverx
            dc.w    ROVER_SPEED
