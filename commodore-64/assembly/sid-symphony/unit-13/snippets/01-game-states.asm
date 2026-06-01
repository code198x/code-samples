; ============================================================================
; GAME STATES - Four distinct states for complete game flow
; ============================================================================

STATE_TITLE   = 0               ; Title screen - waiting to start
STATE_PLAYING = 1               ; Main gameplay
STATE_RESULTS = 2               ; Song completed successfully
STATE_GAMEOVER = 3              ; Health depleted - game over

game_state:   !byte 0           ; Current state

; ----------------------------------------------------------------------------
; Main Loop - State Dispatcher
; ----------------------------------------------------------------------------

main_loop:
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            lda game_state
            cmp #STATE_TITLE
            beq do_title
            cmp #STATE_PLAYING
            beq do_playing
            cmp #STATE_RESULTS
            beq do_results
            jmp do_gameover

do_title:
            jsr update_title
            jmp main_loop

do_playing:
            jsr update_playing
            jmp main_loop

do_results:
            jsr update_results
            jmp main_loop

do_gameover:
            jsr update_gameover
            jmp main_loop
