;───────────────────────────────────────
; Find the best move for the AI (Player 2)
; Output: best_x, best_y set to chosen cell
;───────────────────────────────────────
ai_pick_move:
        ; Reset best score
        xor a
        ld (best_score), a

        ; Scan all cells
        ld b, 0                 ; y = 0
.y_loop:
        ld c, 0                 ; x = 0
.x_loop:
        push bc                 ; Save coordinates

        ; Check if cell is empty
        call get_owner
        or a
        jr nz, .skip            ; Not empty - skip

        ; Check if adjacent to AI territory (player 2)
        ld a, 2
        ld (current_player), a  ; Temporarily set for adjacency check
        call check_adjacency_at
        jr nz, .skip            ; Not adjacent - skip

        ; Score this cell
        pop bc
        push bc
        call score_cell         ; A = score

        ; Is this better than our best?
        ld e, a
        ld a, (best_score)
        cp e
        jr nc, .skip            ; Current best >= this one

        ; New best!
        ld a, e
        ld (best_score), a
        pop bc
        push bc
        ld a, c
        ld (best_x), a
        ld a, b
        ld (best_y), a

.skip:
        pop bc
        inc c                   ; Next column
        ld a, c
        cp 8
        jr nz, .x_loop

        inc b                   ; Next row
        ld a, b
        cp 8
        jr nz, .y_loop

        ; Restore current_player to 1 (human)
        ld a, 1
        ld (current_player), a

        ret
