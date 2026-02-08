;──────────────────────────────────────────────────────────────
; start_game — Transition from title to gameplay
;──────────────────────────────────────────────────────────────
start_game:
            bsr     clear_bitplane

            ; Reset creatures
            lea     creatures,a0
            move.w  #80,CR_X(a0)
            move.w  #92,CR_Y(a0)
            move.w  #CREATURE_SPEED,CR_DX(a0)
            move.w  #STATE_WALKING,CR_STATE(a0)
            move.w  #0,CR_STEP(a0)
            ; ...more creatures...

            move.w  #0,saved_count
            move.w  #0,lost_count
            move.w  #GAME_PLAYING,game_state

            ; Draw terrain
            move.w  #GROUND_L_X,d0
            move.w  #GROUND_L_Y,d1
            move.w  #GROUND_L_W,d2
            move.w  #GROUND_L_H,d3
            bsr     draw_rect
            ; ...more terrain...

            ; Draw initial score
            bsr     draw_saved_count
            rts
