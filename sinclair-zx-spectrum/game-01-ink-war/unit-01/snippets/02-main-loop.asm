; ----------------------------------------------------------------------------
; Entry Point
; ----------------------------------------------------------------------------

start:
            call    init_screen     ; Clear screen and set border
            call    draw_board      ; Draw the game board
            call    draw_cursor     ; Show cursor at starting position

main_loop:
            halt                    ; Wait for frame (50Hz timing)

            call    read_keyboard   ; Check for input
            call    move_cursor     ; Update cursor if moved

            jp      main_loop       ; Repeat forever
