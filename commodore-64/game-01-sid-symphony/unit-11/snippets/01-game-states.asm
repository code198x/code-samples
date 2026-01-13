; ============================================================================
; GAME STATES
; ============================================================================

STATE_PLAYING = 0
STATE_RESULTS = 1
STATE_GAMEOVER = 2

game_state:   !byte 0

; ----------------------------------------------------------------------------
; Main Loop - State Machine
; ----------------------------------------------------------------------------

main_loop:
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            lda game_state
            cmp #STATE_PLAYING
            beq do_playing
            cmp #STATE_RESULTS
            beq do_results
            jmp do_gameover

do_playing:
            jsr update_playing
            jmp main_loop

do_results:
            jsr update_results
            jmp main_loop

do_gameover:
            jsr update_gameover
            jmp main_loop
