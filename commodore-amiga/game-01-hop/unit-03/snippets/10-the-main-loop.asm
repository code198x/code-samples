mainloop:
            bsr.s   wait_vblank

            ; Read joystick
            bsr.s   read_joystick       ; Returns edge-triggered state in D0

            ; Check each direction
            btst    #8,d0               ; Up?
            beq.s   .no_up
            move.w  frog_y,d1
            sub.w   #HOP_SIZE,d1
            cmp.w   #MIN_Y,d1
            blt.s   .no_up
            move.w  d1,frog_y
.no_up:
            btst    #0,d0               ; Down?
            beq.s   .no_down
            move.w  frog_y,d1
            add.w   #HOP_SIZE,d1
            cmp.w   #MAX_Y,d1
            bgt.s   .no_down
            move.w  d1,frog_y
.no_down:
            btst    #9,d0               ; Left?
            beq.s   .no_left
            move.w  frog_x,d1
            sub.w   #HOP_SIZE,d1
            cmp.w   #MIN_X,d1
            blt.s   .no_left
            move.w  d1,frog_x
.no_left:
            btst    #1,d0               ; Right?
            beq.s   .no_right
            move.w  frog_x,d1
            add.w   #HOP_SIZE,d1
            cmp.w   #MAX_X,d1
            bgt.s   .no_right
            move.w  d1,frog_x
.no_right:

            ; Update sprite
            bsr.s   update_sprite

            bra.s   mainloop
