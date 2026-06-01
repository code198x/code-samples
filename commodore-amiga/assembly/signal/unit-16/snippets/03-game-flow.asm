; Phase 1 Complete Game Flow
; ==========================

; Startup
; -------
start:
            lea     CUSTOM,a5
            move.w  #$7fff,DMACON(a5)       ; Disable all DMA
            bsr     clear_screen
            ; ... setup bitplane, sprites, copper ...
            move.w  #$87e1,DMACON(a5)       ; Enable DMA
            move.w  #GSTATE_TITLE,game_state
            bsr     show_title

; Main Loop
; ---------
mainloop:
            bsr     wait_vblank

            ; Dispatch based on game state
            move.w  game_state,d0
            cmp.w   #GSTATE_TITLE,d0
            beq     title_loop              ; Wait for fire
            cmp.w   #GSTATE_OVER,d0
            beq     gameover_loop           ; Wait for fire

            ; PLAYING state
            bsr     update_frog
            bsr     update_timer
            bsr     erase_all_cars
            bsr     move_all_cars
            bsr     draw_all_cars
            bsr     check_home
            bsr     check_collision
            bra     mainloop

; State Transitions
; -----------------
; TITLE -> PLAYING: fire button
; PLAYING -> OVER: last life lost
; OVER -> TITLE: fire button
