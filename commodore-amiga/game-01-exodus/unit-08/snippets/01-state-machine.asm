            ; --- Check state and update ---
            move.w  creature_state,d0
            cmp.w   #STATE_FALLING,d0
            beq.s   .do_fall

            ; --- Walking: check floor ahead ---
.do_walk:
            move.w  creature_x,d0
            add.w   creature_dx,d0
            add.w   #FOOT_OFFSET_X,d0
            move.w  creature_y,d1
            add.w   #FOOT_OFFSET_Y,d1
            bsr     check_pixel

            tst.b   d0
            beq.s   .walk_no_floor

            ; Floor exists — move forward
            move.w  creature_x,d0
            add.w   creature_dx,d0
            move.w  d0,creature_x

            ; Also check if we're standing on something
            ; (might have walked off a ledge)
            move.w  creature_x,d0
            add.w   #FOOT_OFFSET_X,d0
            move.w  creature_y,d1
            add.w   #FOOT_OFFSET_Y,d1
            bsr     check_pixel

            tst.b   d0
            bne.s   .done_move
            ; No floor under us — start falling
            move.w  #STATE_FALLING,creature_state
            bra.s   .done_move

.walk_no_floor:
            neg.w   creature_dx
            bra.s   .done_move
