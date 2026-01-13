; ----------------------------------------------------------------------------
; State Handlers
; ----------------------------------------------------------------------------

state_title:
            ; Wait for any key press
            xor     a
            in      a, (KEY_PORT)
            cpl
            and     %00011111
            jr      z, main_loop        ; No key - keep waiting

            ; Key pressed - start game
            call    start_game
            jp      main_loop

state_playing:
            call    read_keyboard
            call    handle_input
            jp      main_loop

; ----------------------------------------------------------------------------
; Start Game
; ----------------------------------------------------------------------------
; Transitions from title to playing state

start_game:
            ld      a, GS_PLAYING
            ld      (game_state), a

            call    init_screen
            call    init_game
            call    draw_board_border
            call    draw_board
            call    draw_ui
            call    draw_cursor
            call    update_border

            ; Wait for key release before playing
            call    wait_key_release

            ret
