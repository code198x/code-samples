; Move Frog with Boundaries
; Pixel-based movement with screen boundary checking

move_frog:
            bsr     read_joystick

            ; --- Check UP ---
            btst    #8,d0
            beq.s   .not_up
            move.w  frog_y,d1
            cmp.w   #44,d1              ; Top boundary
            beq.s   .not_up
            subq.w  #2,d1
            move.w  d1,frog_y
.not_up:

            ; --- Check DOWN ---
            btst    #0,d0
            beq.s   .not_down
            move.w  frog_y,d1
            cmp.w   #220,d1             ; Bottom boundary
            beq.s   .not_down
            addq.w  #2,d1
            move.w  d1,frog_y
.not_down:

            ; --- Check LEFT ---
            btst    #9,d0
            beq.s   .not_left
            move.w  frog_x,d1
            cmp.w   #48,d1              ; Left boundary
            beq.s   .not_left
            subq.w  #2,d1
            move.w  d1,frog_x
.not_left:

            ; --- Check RIGHT ---
            btst    #1,d0
            beq.s   .not_right
            move.w  frog_x,d1
            cmp.w   #288,d1             ; Right boundary
            beq.s   .not_right
            addq.w  #2,d1
            move.w  d1,frog_x
.not_right:
            rts
