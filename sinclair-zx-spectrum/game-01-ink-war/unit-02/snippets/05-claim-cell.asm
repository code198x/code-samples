; ----------------------------------------------------------------------------
; Claim Cell
; ----------------------------------------------------------------------------
; Claims current cell for current player

claim_cell:
            ; Calculate board state index
            ld      a, (cursor_row)
            add     a, a
            add     a, a
            add     a, a
            ld      hl, board_state
            ld      b, 0
            ld      c, a
            add     hl, bc
            ld      a, (cursor_col)
            ld      c, a
            add     hl, bc          ; HL = &board_state[row*8+col]

            ; Set to current player
            ld      a, (current_player)
            ld      (hl), a

            ; Update attribute colour
            push    af

            ld      a, (cursor_row)
            add     a, BOARD_ROW
            ld      l, a
            ld      h, 0
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            add     hl, hl
            ld      a, (cursor_col)
            add     a, BOARD_COL
            add     a, l
            ld      l, a
            ld      bc, ATTR_BASE
            add     hl, bc

            pop     af
            cp      1
            jr      z, .player1
            ld      (hl), P2_ATTR
            ret
.player1:
            ld      (hl), P1_ATTR
            ret
