; ----------------------------------------------------------------------------
; State Machine
; ----------------------------------------------------------------------------
; Entry point and main loop dispatch

start:
            ; Start at title screen
            ld      a, GS_TITLE
            ld      (game_state), a
            call    init_screen
            call    draw_title_screen

            ; Black border for title
            xor     a
            out     (KEY_PORT), a

main_loop:
            halt

            ; Dispatch based on game state
            ld      a, (game_state)
            or      a
            jr      z, state_title      ; GS_TITLE = 0
            cp      GS_PLAYING
            jr      z, state_playing

            jp      main_loop
