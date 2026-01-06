;───────────────────────────────────────
; Score a cell for the AI (improved version)
; Input: B = y, C = x
; Output: A = score (higher is better)
;───────────────────────────────────────
score_cell:
        ; Reset score
        xor a
        ld (tmp_score), a

        ; Save coordinates
        push bc

        ; Score neighbours (same as Unit 7)
        call score_neighbour_up
        pop bc
        push bc
        call score_neighbour_down
        pop bc
        push bc
        call score_neighbour_left
        pop bc
        push bc
        call score_neighbour_right

        ; Blocking bonus: if enemy has 2+ adjacent cells, add bonus
        pop bc
        push bc
        call count_enemy_neighbours
        cp 2                    ; 2 or more?
        jr c, .no_block         ; Carry set if A < 2

        ld a, (tmp_score)
        add a, 4                ; Big bonus for blocking threats
        ld (tmp_score), a

.no_block:
        ; Add small randomness (0 or 1) from frame counter
        ld a, (frame_counter)
        and %00000001           ; Keep only bit 0
        ld b, a
        ld a, (tmp_score)
        add a, b
        ld (tmp_score), a

        pop bc
        ld a, (tmp_score)
        ret
