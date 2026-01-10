; Update the screen to show who owns the cell

update_cell_display:
        ; Get screen address for cursor position
        ld a, (cursor_row)
        ld b, a
        ld a, (cursor_col)
        ld c, a
        call get_cell_address   ; HL = attribute address

        ; Get colour for current player
        ld a, (current_player)
        cp PLAYER1
        jr nz, show_p2
        ld a, P1_ATTR           ; Bright red
        jr show_it
show_p2:
        ld a, P2_ATTR           ; Bright blue
show_it:
        ld (hl), a              ; Write to screen
        ret

; The display now reflects the board state
; Red cells = Player 1 territory
; Blue cells = Player 2 territory
