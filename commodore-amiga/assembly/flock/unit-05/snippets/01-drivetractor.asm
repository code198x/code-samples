drivetractor:
            move.w  tractx,d0
            add.w   #TRACTOR_SPEED,d0
            cmp.w   #320,d0             ; Clear of the right edge?
            blt.s   .keep
            move.w  #-16,d0             ; Re-enter from the left
.keep:      move.w  d0,tractx
            rts
