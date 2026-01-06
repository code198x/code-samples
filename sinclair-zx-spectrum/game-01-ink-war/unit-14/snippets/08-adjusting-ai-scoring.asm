; Check blocking bonus
        pop bc
        push bc
        call count_enemy_neighbours
        cp 2
        jr c, .no_block

        ; Apply blocking bonus based on difficulty
        ld a, (difficulty)
        cp 1
        jr z, .no_block          ; Easy = no blocking bonus

        cp 3
        jr nz, .normal_block

        ; Hard blocking bonus (+6)
        ld a, (tmp_score)
        add a, 6
        ld (tmp_score), a
        jr .after_block

.normal_block:
        ; Normal blocking bonus (+4)
        ld a, (tmp_score)
        add a, 4
        ld (tmp_score), a

.after_block:
.no_block:
