; ----------------------------------------------------------------------------
; Find Best Adjacent Cell
; ----------------------------------------------------------------------------
; Returns A = index of empty cell with most AI neighbors, or $FF if none
; Prefers cells adjacent to existing AI territory

find_best_adjacent_cell:
            ; Initialize best tracking
            ld      a, $ff
            ld      (best_cell), a      ; No best cell yet
            xor     a
            ld      (best_score), a     ; Best score = 0

            ; Scan all 64 cells
            ld      c, 0                ; C = current cell index

.fbac_loop:
            ; Check if cell is empty
            ld      hl, board_state
            ld      d, 0
            ld      e, c
            add     hl, de
            ld      a, (hl)
            or      a
            jr      nz, .fbac_next      ; Not empty, skip

            ; Empty cell - count adjacent AI cells
            push    bc
            ld      a, c
            call    count_adjacent_ai
            pop     bc
            ; A = number of adjacent AI cells

            ; Compare with best score
            ld      b, a                ; B = this score
            ld      a, (best_score)
            cp      b
            jr      nc, .fbac_next      ; Current best >= this score

            ; New best found
            ld      a, b
            ld      (best_score), a
            ld      a, c
            ld      (best_cell), a

.fbac_next:
            inc     c
            ld      a, c
            cp      64
            jr      c, .fbac_loop       ; Continue if c < 64

            ; Check if we found an adjacent cell
            ld      a, (best_score)
            or      a
            jr      z, .fbac_random     ; No adjacent cells, use random

            ; Return best adjacent cell
            ld      a, (best_cell)
            ret

.fbac_random:
            ; Fall back to random empty cell
            call    find_random_empty_cell
            ret

best_cell:      defb    0
best_score:     defb    0
