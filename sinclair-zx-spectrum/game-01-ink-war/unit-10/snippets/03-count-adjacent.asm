; ----------------------------------------------------------------------------
; Count Adjacent AI Cells
; ----------------------------------------------------------------------------
; A = cell index (0-63)
; Returns A = count of adjacent cells owned by AI (P2)

count_adjacent_ai:
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
            jr      z, .caa_skip_up     ; Row 0, no up neighbor
            dec     a                   ; Row - 1
            push    bc
            ld      b, a
            call    .caa_check_cell
            pop     bc
.caa_skip_up:

            ; Check down (row+1)
            ld      a, b
            cp      7
            jr      z, .caa_skip_down   ; Row 7, no down neighbor
            inc     a                   ; Row + 1
            push    bc
            ld      b, a
            call    .caa_check_cell
            pop     bc
.caa_skip_down:

            ; Check left (col-1)
            ld      a, c
            or      a
            jr      z, .caa_skip_left   ; Col 0, no left neighbor
            dec     a                   ; Col - 1
            push    bc
            ld      c, a
            call    .caa_check_cell
            pop     bc
.caa_skip_left:

            ; Check right (col+1)
            ld      a, c
            cp      7
            jr      z, .caa_skip_right  ; Col 7, no right neighbor
            inc     a                   ; Col + 1
            push    bc
            ld      c, a
            call    .caa_check_cell
            pop     bc
.caa_skip_right:

            ld      a, (adj_count)
            ret

            ; Helper: check if cell at (B,C) is AI owned
.caa_check_cell:
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
            cp      STATE_P2            ; AI is Player 2
            ret     nz                  ; Not AI cell
            ; AI cell - increment count
            ld      a, (adj_count)
            inc     a
            ld      (adj_count), a
            ret

temp_cell:      defb    0
adj_count:      defb    0
