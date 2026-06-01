;------------------------------------------------------------------------------
; TITLE_LOOP - Wait for fire button on title screen
;------------------------------------------------------------------------------
title_loop:
            bsr     read_fire_edge
            tst.w   d0
            beq     mainloop        ; No fire press, keep waiting

            ; Fire pressed - start game!
            move.w  #GSTATE_PLAYING,game_state
            bsr     init_game
            bsr     clear_screen
            bsr     update_life_display
            bsr     display_score
            bsr     display_timer
            bsr     display_level
            bsr     update_sprite
            bra     mainloop

;------------------------------------------------------------------------------
; GAMEOVER_LOOP - Wait for fire button on game over screen
;------------------------------------------------------------------------------
gameover_loop:
            bsr     read_fire_edge
            tst.w   d0
            beq     mainloop        ; No fire press, keep waiting

            ; Fire pressed - return to title
            move.w  #GSTATE_TITLE,game_state
            bsr     clear_screen
            bsr     show_title
            bra     mainloop
