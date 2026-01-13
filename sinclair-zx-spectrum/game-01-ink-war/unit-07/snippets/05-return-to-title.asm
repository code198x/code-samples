; ----------------------------------------------------------------------------
; Return to Title (in try_claim after game over)
; ----------------------------------------------------------------------------

            ; Game over - show results and return to title
            call    show_results
            call    victory_celebration
            call    wait_for_key

            ; Return to title screen
            ld      a, GS_TITLE
            ld      (game_state), a
            call    init_screen
            call    draw_title_screen
            xor     a
            out     (KEY_PORT), a       ; Black border for title
            ret
