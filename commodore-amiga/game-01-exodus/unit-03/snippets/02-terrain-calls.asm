            ; --- Draw terrain into bitplane ---
            ; Bitplane starts as zeros (sky everywhere).
            ; Each draw_rect call fills a rectangle with 1s (terrain).

            ; Low ground (left side)
            move.w  #GROUND_L_X,d0
            move.w  #GROUND_L_Y,d1
            move.w  #GROUND_L_W,d2
            move.w  #GROUND_L_H,d3
            bsr     draw_rect

            ; High ground (right side — cliff face)
            move.w  #GROUND_R_X,d0
            move.w  #GROUND_R_Y,d1
            move.w  #GROUND_R_W,d2
            move.w  #GROUND_R_H,d3
            bsr     draw_rect

            ; Floating platform
            move.w  #PLATFORM_X,d0
            move.w  #PLATFORM_Y,d1
            move.w  #PLATFORM_W,d2
            move.w  #PLATFORM_H,d3
            bsr     draw_rect
