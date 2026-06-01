            ; --- Move creature ---
            move.w  creature_x,d0
            add.w   creature_dx,d0

            ; --- Check right edge ---
            cmp.w   #RIGHT_EDGE,d0
            blt.s   .not_right
            move.w  #RIGHT_EDGE,d0
            neg.w   creature_dx         ; Reverse direction
.not_right:
            ; --- Check left edge ---
            cmp.w   #LEFT_EDGE,d0
            bge.s   .not_left
            move.w  #LEFT_EDGE,d0
            neg.w   creature_dx         ; Reverse direction
.not_left:
            move.w  d0,creature_x
