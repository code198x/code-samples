ai_make_move:
        ld a, (best_score)
        or a
        ret z

        ld a, 2
        ld (current_player), a

        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_board_addr
        ld a, 2
        ld (hl), a

        ld a, (best_y)
        ld b, a
        ld a, (best_x)
        ld c, a
        call get_cell_addr
        call set_cell_colour
        call capture_flash      ; Add flash effect

        ; ... rest of routine ...
