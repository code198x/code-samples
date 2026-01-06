;───────────────────────────────────────
; Count enemy neighbours of a cell
; Input: B = y, C = x
; Output: A = count of enemy-owned neighbours
;───────────────────────────────────────
count_enemy_neighbours:
        xor a
        ld (enemy_count), a
        push bc

        ; Check Up
        ld a, b
        or a
        jr z, .skip_up
        dec a
        ld b, a
        call get_owner
        cp 1                    ; Is it player 1 (enemy)?
        jr nz, .skip_up
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_up:
        pop bc
        push bc

        ; Check Down
        ld a, b
        cp 7
        jr z, .skip_down
        inc a
        ld b, a
        call get_owner
        cp 1
        jr nz, .skip_down
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_down:
        pop bc
        push bc

        ; Check Left
        ld a, c
        or a
        jr z, .skip_left
        dec a
        ld c, a
        call get_owner
        cp 1
        jr nz, .skip_left
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_left:
        pop bc
        push bc

        ; Check Right
        ld a, c
        cp 7
        jr z, .skip_right
        inc a
        ld c, a
        call get_owner
        cp 1
        jr nz, .skip_right
        ld a, (enemy_count)
        inc a
        ld (enemy_count), a
.skip_right:
        pop bc

        ld a, (enemy_count)
        ret

enemy_count:    defb 0
