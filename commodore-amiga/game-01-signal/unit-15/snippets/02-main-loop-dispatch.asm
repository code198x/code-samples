;==============================================================================
; MAIN LOOP - Dispatches based on game_state
;==============================================================================

mainloop:
            bsr     wait_vblank

            move.w  game_state,d0
            cmp.w   #GSTATE_TITLE,d0
            beq     title_loop
            cmp.w   #GSTATE_OVER,d0
            beq     gameover_loop

            ; GSTATE_PLAYING - active gameplay
            bsr     update_frog
            bsr     update_sprite

            ; Check if frog died (transition to game over)
            cmp.w   #STATE_GAMEOVER,frog_state
            beq     .enter_gameover

            ; ... rest of game logic ...

            bra     mainloop

.enter_gameover:
            move.w  #GSTATE_OVER,game_state
            bsr     show_gameover
            bra     mainloop
