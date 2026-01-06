wrap_x:
            ; D0 = current X
            ; Wrap right edge
            cmp.w   #320,d0
            blt.s   .check_left
            sub.w   #336,d0             ; Wrap to -16 (off left edge)
            move.w  d0,CAR_X(a2)
            rts
.check_left:
            ; Wrap left edge
            cmp.w   #-16,d0
            bge.s   .done
            add.w   #336,d0             ; Wrap to 320
            move.w  d0,CAR_X(a2)
.done:
            rts
