; Cursor colour matches current player

draw_cursor:
        ; Get cell address
        call get_cell_address

        ; Check if cell is claimed
        call get_board_state
        or a
        jr z, cursor_empty

        ; On claimed cell: add FLASH to existing colour
        ld a, (hl)
        or %10000000        ; Set FLASH bit
        ld (hl), a
        ret

cursor_empty:
        ; On empty cell: use current player's colour with FLASH
        ld a, (current_player)
        cp PLAYER1
        jr nz, cursor_blue
        ld a, P1_ATTR       ; Red
        jr cursor_flash
cursor_blue:
        ld a, P2_ATTR       ; Blue
cursor_flash:
        or %10000000        ; Add FLASH
        ld (hl), a
        ret

; The flashing cursor shows where you are
; The colour shows whose turn it is
