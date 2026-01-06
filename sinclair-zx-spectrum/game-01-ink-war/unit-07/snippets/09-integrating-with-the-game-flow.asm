claim_cell:
        ; Get cursor position
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a

        ; Check if empty
        call get_board_addr
        ld a, (hl)
        or a
        ret nz                  ; Not empty

        ; Check if adjacent
        call check_adjacency
        ret nz                  ; Not adjacent

        ; Valid! Claim it
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_board_addr
        ld a, (current_player)
        ld (hl), a

        ; Update display
        ld a, (cursor_x)
        ld c, a
        ld a, (cursor_y)
        ld b, a
        call get_cell_addr
        call set_cell_colour

        ; AI's turn
        call ai_think_delay
        call ai_pick_move
        call ai_make_move

        ret
