;───────────────────────────────────────
; Add to score based on cell above
; Input: B = y, C = x
;───────────────────────────────────────
score_neighbour_up:
        ld a, b
        or a
        ret z                   ; At top edge - no neighbour

        dec a
        ld b, a                 ; B = y-1
        call get_owner          ; A = owner of neighbour

        ; Score based on owner
        or a
        jr z, .neutral
        cp 2                    ; Is it AI (player 2)?
        jr z, .friendly
        ; It's player 1 (enemy)
        ld a, (tmp_score)
        sub 2                   ; Penalty for enemy neighbour
        ld (tmp_score), a
        ret
.friendly:
        ld a, (tmp_score)
        add a, 3                ; Bonus for friendly neighbour
        ld (tmp_score), a
        ret
.neutral:
        ld a, (tmp_score)
        inc a                   ; Small bonus for expansion room
        ld (tmp_score), a
        ret
