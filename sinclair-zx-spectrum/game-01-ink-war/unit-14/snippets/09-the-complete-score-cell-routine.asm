score_cell:
        xor a
        ld (tmp_score), a

        push bc

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

        ; Add centre bonus based on difficulty
        ld a, (difficulty)
        cp 1
        jr z, .check_blocking    ; Easy = no centre bonus

        ; Check if in centre columns (2-5)
        pop bc
        push bc
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
        ld a, b
        cp 2
        jr c, .check_blocking
        cp 6
        jr nc, .check_blocking

        ; In centre row - add bonus
        ld a, (difficulty)
        cp 3
        jr nz, .normal_row_bonus
        ld a, (tmp_score)
        add a, 2
        ld (tmp_score), a
        jr .check_blocking
.normal_row_bonus:
        ld a, (tmp_score)
        inc a
        ld (tmp_score), a

.check_blocking:
        pop bc
        push bc
        call count_enemy_neighbours
        cp 2
        jr c, .add_noise

        ; Apply blocking bonus based on difficulty
        ld a, (difficulty)
        cp 1
        jr z, .add_noise         ; Easy = no blocking bonus

        cp 3
        jr nz, .normal_block

        ; Hard blocking bonus (+6)
        ld a, (tmp_score)
        add a, 6
        ld (tmp_score), a
        jr .add_noise

.normal_block:
        ; Normal blocking bonus (+4)
        ld a, (tmp_score)
        add a, 4
        ld (tmp_score), a

.add_noise:
        ; Add small random element
        ld a, (frame_counter)
        and %00000001
        ld b, a
        ld a, (tmp_score)
        add a, b
        ld (tmp_score), a

        pop bc
        ld a, (tmp_score)
        ret
