; ----------------------------------------------------------------------------
; Count Cells
; ----------------------------------------------------------------------------
; Counts cells owned by each player

count_cells:
            xor     a
            ld      (p1_count), a
            ld      (p2_count), a

            ld      hl, board_state
            ld      b, 64               ; 64 cells

.count_loop:
            ld      a, (hl)
            cp      STATE_P1
            jr      nz, .not_p1
            ld      a, (p1_count)
            inc     a
            ld      (p1_count), a
            jr      .next
.not_p1:
            cp      STATE_P2
            jr      nz, .next
            ld      a, (p2_count)
            inc     a
            ld      (p2_count), a
.next:
            inc     hl
            djnz    .count_loop

            ret
