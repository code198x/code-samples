; Count cells owned by each player

count_cells:
        ld hl, board_state
        ld bc, 64           ; 64 cells to check
        ld d, 0             ; P1 count
        ld e, 0             ; P2 count

count_loop:
        ld a, (hl)
        or a
        jr z, count_next    ; Empty - skip

        cp PLAYER1
        jr nz, count_p2
        inc d               ; P1 cell
        jr count_next
count_p2:
        inc e               ; P2 cell

count_next:
        inc hl
        dec bc
        ld a, b
        or c
        jr nz, count_loop

        ; Store results
        ld a, d
        ld (p1_score), a
        ld a, e
        ld (p2_score), a
        ret
