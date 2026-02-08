            ; --- Falling: descend until floor found ---
.do_fall:
            move.w  creature_y,d0
            add.w   #FALL_SPEED,d0

            ; Safety: don't fall below screen
            cmp.w   #SCREEN_HEIGHT-SPRITE_HEIGHT,d0
            blt.s   .fall_ok
            move.w  #SCREEN_HEIGHT-SPRITE_HEIGHT,d0
            move.w  d0,creature_y
            move.w  #STATE_WALKING,creature_state
            bra.s   .done_move

.fall_ok:
            move.w  d0,creature_y

            ; Check if we've landed
            move.w  creature_x,d0
            add.w   #FOOT_OFFSET_X,d0
            move.w  creature_y,d1
            add.w   #FOOT_OFFSET_Y,d1
            bsr     check_pixel

            tst.b   d0
            beq.s   .done_move          ; Still falling

            ; Landed — snap to surface and resume walking
            move.w  #STATE_WALKING,creature_state

.done_move:
