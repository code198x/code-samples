; ----------------------------------------------------------------------------
; Check Game Over
; ----------------------------------------------------------------------------
; Returns A=1 if game is over (board full), A=0 otherwise

check_game_over:
            ; Game is over when p1_count + p2_count == 64
            ld      a, (p1_count)
            ld      b, a
            ld      a, (p2_count)
            add     a, b
            cp      TOTAL_CELLS
            jr      z, .cgo_over
            xor     a               ; Not over
            ret
.cgo_over:
            ld      a, 1            ; Game over
            ret
