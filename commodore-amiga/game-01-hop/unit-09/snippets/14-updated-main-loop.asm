.draw:
            bsr     update_frog_sprite
            bsr     draw_objects

            ; Draw HUD
            bsr     clear_score_area
            bsr     draw_score
            bsr     draw_lives

            ; Check for exit
            btst    #6,CIAA_PRA
            bne     main_loop
