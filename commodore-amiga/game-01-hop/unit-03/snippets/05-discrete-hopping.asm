move.w  joy_current,d0
            move.w  joy_prev,d1
            not.w   d1              ; Invert: 1 where previously NOT pressed
            and.w   d0,d1           ; AND: 1 where NOW pressed AND wasn't before
            move.w  d0,joy_prev     ; Save for next frame
            ; D1 now has edge-triggered directions
