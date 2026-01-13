; ----------------------------------------------------------------------------
; Find Best Cell (Offense + Defense)
; ----------------------------------------------------------------------------
; Returns A = index of empty cell with best combined score, or $FF if none
; Score = adjacent AI cells (offense) + adjacent human cells (defense)
; This makes the AI both expand territory AND block the human

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

            ; Empty cell - count adjacent AI cells (offense)
            push    bc
            ld      a, c
            call    count_adjacent_ai
            ld      b, a                ; B = AI adjacent count

            ; Count adjacent human cells (defense)
            ld      a, c
            call    count_adjacent_p1
            add     a, b                ; A = combined score (AI + P1)
            pop     bc

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

            ; ... fallback to random if no adjacent cells
