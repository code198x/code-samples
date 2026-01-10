; Main loop with state dispatch
; Each frame, check current state and call appropriate handler

main_loop:
        halt                    ; Wait for frame

        ; Dispatch based on game state
        ld a, (game_state)

        cp STATE_TITLE
        jr z, handle_title

        cp STATE_PLAYING
        jr z, handle_playing

        cp STATE_RESULTS
        jr z, handle_results

        ; Default: go to title
        call enter_title_state
        jr main_loop

; State handlers - each handles one frame's worth of logic
handle_title:
        call wait_any_key       ; Block until key pressed
        call enter_playing_state
        jr main_loop

handle_playing:
        call read_keys
        call move_cursor
        call check_claim
        jr main_loop

handle_results:
        call flash_winner_border
        call check_any_key
        jr z, main_loop         ; No key - keep flashing

        ; Key pressed - return to title
        call enter_title_state
        jr main_loop
