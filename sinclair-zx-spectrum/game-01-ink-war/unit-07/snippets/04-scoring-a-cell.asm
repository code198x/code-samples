;───────────────────────────────────────
; Score a cell for the AI
; Input: B = y, C = x
; Output: A = score (higher is better)
;───────────────────────────────────────
score_cell:
        ; Reset score
        xor a
        ld (tmp_score), a

        ; Save coordinates
        push bc

        ; Score each neighbour
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

        pop bc
        ld a, (tmp_score)
        ret
