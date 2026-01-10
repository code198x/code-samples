; Claim cells for players
; B = row, C = column, A = player

        ; Player 1 claims cell (0,0)
        ld b, 0             ; Row 0
        ld c, 0             ; Column 0
        ld a, PLAYER1       ; Player 1
        call set_cell

        ; Player 2 claims cell (7,7)
        ld b, 7             ; Row 7
        ld c, 7             ; Column 7
        ld a, PLAYER2       ; Player 2
        call set_cell

        ; Player 1 claims cell (1,1)
        ld b, 1
        ld c, 1
        ld a, PLAYER1
        call set_cell
