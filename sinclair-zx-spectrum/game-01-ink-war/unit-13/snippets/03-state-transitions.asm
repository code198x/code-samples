; State transition functions
; Each function prepares everything needed for its state

enter_title_state:
        ld a, STATE_TITLE
        ld (game_state), a

        call clear_screen
        call clear_pixels

        ; Draw title
        call setup_title_attrs
        ld hl, msg_title
        ld b, TITLE_ROW
        ld c, TITLE_COL
        call print_string

        ; Draw prompt
        call setup_prompt_attrs
        ld hl, msg_prompt
        ld b, PROMPT_ROW
        ld c, PROMPT_COL
        call print_string

        ret

enter_playing_state:
        ld a, STATE_PLAYING
        ld (game_state), a

        ; Reset all game variables
        call reset_game

        ; Draw complete game screen
        call clear_screen
        call clear_pixels
        call draw_border
        call draw_board
        call draw_turn_indicator
        call draw_scores

        ; Position cursor in centre
        ld a, 3
        ld (cursor_row), a
        ld (cursor_col), a
        call draw_cursor

        ret

enter_results_state:
        ld a, STATE_RESULTS
        ld (game_state), a

        ; Determine and display winner
        call determine_winner

        ; Clear prev_keys to avoid instant transition
        xor a
        ld (prev_keys), a

        ret
