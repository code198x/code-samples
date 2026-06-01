            ; --- Check floor ahead ---
            ; Test the pixel below where the creature's feet will be
            move.w  creature_x,d0
            add.w   creature_dx,d0      ; Proposed new x
            add.w   #FOOT_OFFSET_X,d0   ; Centre of sprite
            move.w  creature_y,d1
            add.w   #FOOT_OFFSET_Y,d1   ; Below feet
            bsr     check_pixel

            tst.b   d0                  ; D0 = 1 if solid, 0 if empty
            beq.s   .no_floor

            ; Floor exists — walk forward
            move.w  creature_x,d0
            add.w   creature_dx,d0
            move.w  d0,creature_x
            bra.s   .done_move

.no_floor:
            ; No floor ahead — turn around
            neg.w   creature_dx

.done_move:
