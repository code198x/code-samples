wait_for_mode:
        ; Wait for key release first
.wait_release:
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr z, .wait_release

        ; Wait for 1 or 2
.wait_key:
        halt

        ; Check for "1" key (row $F7, bit 0)
        ld a, $F7
        in a, ($FE)
        bit 0, a
        jr z, .mode_1

        ; Check for "2" key (row $F7, bit 1)
        ld a, $F7
        in a, ($FE)
        bit 1, a
        jr z, .mode_2

        jr .wait_key

.mode_1:
        ld a, 1
        ld (game_mode), a
        ret

.mode_2:
        ld a, 2
        ld (game_mode), a
        ret
