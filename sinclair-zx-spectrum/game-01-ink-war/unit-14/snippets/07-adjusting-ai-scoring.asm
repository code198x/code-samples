; Add centre bonus based on difficulty
        ld a, (difficulty)
        cp 1
        jr z, .no_centre_bonus

        ; Calculate distance from centre (3.5, 3.5)
        ; We'll use a simple approximation: bonus for columns/rows 2-5
        pop bc
        push bc

        ; Check if in centre columns (2-5)
        ld a, c
        cp 2
        jr c, .check_centre_row
        cp 6
        jr nc, .check_centre_row

        ; In centre column - add bonus
        ld a, (difficulty)
        cp 3
        jr nz, .normal_col_bonus
        ld a, (tmp_score)
        add a, 2
        ld (tmp_score), a
        jr .check_centre_row
.normal_col_bonus:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a

.check_centre_row:
        pop bc
        push bc

        ; Check if in centre rows (2-5)
        ld a, b
        cp 2
        jr c, .no_centre_bonus
        cp 6
        jr nc, .no_centre_bonus

        ; In centre row - add bonus
        ld a, (difficulty)
        cp 3
        jr nz, .normal_row_bonus
        ld a, (tmp_score)
        add a, 2
        ld (tmp_score), a
        jr .no_centre_bonus
.normal_row_bonus:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a

.no_centre_bonus:
