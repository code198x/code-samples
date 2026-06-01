; Calculate Screen Address
; Convert grid row + pixel X to memory address

calc_screen_addr:
            ; Input: D0 = pixel X, D1 = grid row
            ; Output: A0 = screen address

            lea     screen_plane,a0

            ; Y offset: row * CELL_SIZE + margin, then * bytes per line
            move.w  d1,d2
            mulu    #CELL_SIZE,d2           ; Row to pixels
            add.w   #GRID_ORIGIN_Y,d2       ; Add top margin
            mulu    #SCREEN_W,d2            ; Pixels to byte offset
            add.l   d2,a0

            ; X offset: pixel / 8 (8 pixels per byte)
            move.w  d0,d2
            lsr.w   #3,d2                   ; Divide by 8
            ext.l   d2
            add.l   d2,a0

            rts
