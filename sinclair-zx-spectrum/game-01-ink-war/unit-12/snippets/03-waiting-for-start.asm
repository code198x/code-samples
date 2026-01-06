;───────────────────────────────────────
; Wait for SPACE to start
;───────────────────────────────────────
wait_for_start:
        ; Wait for SPACE release first
.wait_release:
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr z, .wait_release

        ; Wait for SPACE press
.wait_press:
        halt
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr nz, .wait_press

        ret
