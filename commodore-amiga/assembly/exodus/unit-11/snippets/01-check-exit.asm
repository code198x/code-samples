;──────────────────────────────────────────────────────────────
; check_exit — Test if creature is inside the exit zone
;   A2 = creature data. Sets STATE_SAVED if inside.
;──────────────────────────────────────────────────────────────
check_exit:
            move.w  CR_X(a2),d0
            add.w   #FOOT_OFFSET_X,d0       ; Centre of sprite
            cmp.w   #EXIT_X,d0
            blt.s   .not_in
            cmp.w   #EXIT_X+EXIT_W,d0
            bge.s   .not_in

            move.w  CR_Y(a2),d1
            add.w   #FOOT_OFFSET_Y,d1       ; Below feet
            cmp.w   #EXIT_Y,d1
            blt.s   .not_in
            cmp.w   #EXIT_Y+EXIT_H,d1
            bge.s   .not_in

            ; Inside exit zone — save this creature
            move.w  #STATE_SAVED,CR_STATE(a2)
            addq.w  #1,saved_count

            ; Move sprite off screen
            move.w  #0,CR_Y(a2)

.not_in:
            rts
