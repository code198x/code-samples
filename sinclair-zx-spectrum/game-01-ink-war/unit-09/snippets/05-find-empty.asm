; ----------------------------------------------------------------------------
; Find Random Empty Cell
; ----------------------------------------------------------------------------
; Returns A = index of a random empty cell (0-63), or $FF if none

find_random_empty_cell:
            ; Get random starting position
            call    get_random
            and     %00111111       ; Limit to 0-63

            ld      c, a            ; C = start index
            ld      b, 64           ; B = cells to check

.frec_loop:
            ; Check if cell at index C is empty
            ld      hl, board_state
            ld      d, 0
            ld      e, c
            add     hl, de
            ld      a, (hl)
            or      a
            jr      z, .frec_found  ; Found empty cell

            ; Try next cell (wrap around)
            inc     c
            ld      a, c
            and     %00111111       ; Wrap at 64
            ld      c, a

            djnz    .frec_loop

            ; No empty cells found
            ld      a, $ff
            ret

.frec_found:
            ld      a, c            ; Return cell index
            ret
