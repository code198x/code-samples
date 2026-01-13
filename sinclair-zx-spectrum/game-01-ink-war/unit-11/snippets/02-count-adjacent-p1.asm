; ----------------------------------------------------------------------------
; Count Adjacent Human Cells
; ----------------------------------------------------------------------------
; A = cell index (0-63)
; Returns A = count of adjacent cells owned by human (P1)

count_adjacent_p1:
            ld      (temp_cell), a
            xor     a
            ld      (adj_count), a

            ; Get row and column
            ld      a, (temp_cell)
            ld      b, a
            and     %00000111           ; Column
            ld      c, a
            ld      a, b
            rrca
            rrca
            rrca
            and     %00000111           ; Row
            ld      b, a                ; B = row, C = col

            ; Check up (row-1)
            ld      a, b
            or      a
            jr      z, .cap_skip_up     ; Row 0, no up neighbor
            dec     a                   ; Row - 1
            push    bc
            ld      b, a
            call    .cap_check_cell
            pop     bc
.cap_skip_up:

            ; Check down, left, right... (same pattern)

            ld      a, (adj_count)
            ret

            ; Helper: check if cell at (B,C) is human owned
.cap_check_cell:
            ; Calculate index: row*8 + col
            ld      a, b
            rlca
            rlca
            rlca                        ; Row * 8
            add     a, c                ; + col
            ld      hl, board_state
            ld      d, 0
            ld      e, a
            add     hl, de
            ld      a, (hl)
            cp      STATE_P1            ; Human is Player 1
            ret     nz                  ; Not human cell
            ; Human cell - increment count
            ld      a, (adj_count)
            inc     a
            ld      (adj_count), a
            ret
