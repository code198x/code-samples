; Calculate results - winner and margin
; Separates logic from display for cleaner code

calculate_results:
        ld a, (p1_score)
        ld b, a
        ld a, (p2_score)

        cp b
        jr z, calc_draw
        jr c, calc_p1_wins

        ; P2 wins: margin = p2_score - p1_score
        ld c, WINNER_P2
        sub b
        jr calc_store

calc_p1_wins:
        ; P1 wins: margin = p1_score - p2_score
        ld c, WINNER_P1
        ld a, b             ; A = p1_score
        ld b, a
        ld a, (p2_score)
        ld d, a
        ld a, b
        sub d               ; A = p1_score - p2_score
        jr calc_store

calc_draw:
        ld c, WINNER_DRAW
        xor a               ; margin = 0

calc_store:
        ld (win_margin), a
        ld a, c
        ld (winner), a
        ret
