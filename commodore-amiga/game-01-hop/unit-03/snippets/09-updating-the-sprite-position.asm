update_sprite:
            lea     frog_data,a0
            move.w  frog_y,d0           ; Get Y position
            move.w  frog_x,d1           ; Get X position

            ; Build Word 1: VSTART | HSTART>>1
            move.w  d0,d2               ; D2 = Y
            lsl.w   #8,d2               ; Y in high byte
            lsr.w   #1,d1               ; X >> 1
            or.b    d1,d2               ; Combine
            move.w  d2,(a0)             ; Write Word 1

            ; Build Word 2: VSTOP | 0
            add.w   #FROG_HEIGHT,d0     ; VSTOP = Y + height
            lsl.w   #8,d0               ; In high byte
            move.w  d0,2(a0)            ; Write Word 2

            rts
