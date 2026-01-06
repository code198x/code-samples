;───────────────────────────────────────
; Check keyboard and move cursor
;───────────────────────────────────────
check_keyboard:
        ; Check Q (up)
        ld bc, $fbfe
        in a, (c)
        bit 0, a
        jr nz, .not_up
        call move_up
        ret
.not_up:

        ; Check A (down)
        ld bc, $fdfe
        in a, (c)
        bit 0, a
        jr nz, .not_down
        call move_down
        ret
.not_down:

        ; Check O (left)
        ld bc, $dffe
        in a, (c)
        bit 1, a
        jr nz, .not_left
        call move_left
        ret
.not_left:

        ; Check P (right)
        ; Same half-row as O, just different bit
        ld bc, $dffe
        in a, (c)
        bit 0, a
        jr nz, .not_right
        call move_right
        ret
.not_right:

        ret
