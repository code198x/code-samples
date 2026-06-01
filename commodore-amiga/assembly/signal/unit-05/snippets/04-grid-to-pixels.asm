; Grid to Pixel Conversion
; Convert cell coordinates to screen position

grid_to_pixels:
            ; pixel_x = grid_x * CELL_SIZE + GRID_ORIGIN_X
            move.w  frog_grid_x,d0
            mulu    #CELL_SIZE,d0
            add.w   #GRID_ORIGIN_X,d0
            move.w  d0,frog_pixel_x

            ; pixel_y = grid_y * CELL_SIZE + GRID_ORIGIN_Y
            move.w  frog_grid_y,d0
            mulu    #CELL_SIZE,d0
            add.w   #GRID_ORIGIN_Y,d0
            move.w  d0,frog_pixel_y

            rts

; Example: grid(9, 12) → pixel(192, 236)
;   192 = 9 * 16 + 48
;   236 = 12 * 16 + 44
