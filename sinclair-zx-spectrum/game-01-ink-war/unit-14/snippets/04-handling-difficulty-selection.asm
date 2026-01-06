wait_for_difficulty:
.wait_release:
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr z, .wait_release

.wait_key:
        halt

        ; Check for "1" key (row $F7, bit 0)
        ld a, $F7
        in a, ($FE)
        bit 0, a
        jr z, .easy

        ; Check for "2" key (row $F7, bit 1)
        ld a, $F7
        in a, ($FE)
        bit 1, a
        jr z, .normal

        ; Check for "3" key (row $F7, bit 2)
        ld a, $F7
        in a, ($FE)
        bit 2, a
        jr z, .hard

        jr .wait_key

.easy:
        ld a, 1
        ld (difficulty), a
        ret

.normal:
        ld a, 2
        ld (difficulty), a
        ret

.hard:
        ld a, 3
        ld (difficulty), a
        ret
