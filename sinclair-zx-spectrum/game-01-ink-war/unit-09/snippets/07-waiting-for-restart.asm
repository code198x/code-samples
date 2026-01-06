;───────────────────────────────────────
; Wait for SPACE to restart
;───────────────────────────────────────
wait_for_restart:
        ; Wait for SPACE release first (if held from last move)
.wait_release:
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr z, .wait_release     ; Still held - wait

        ; Now wait for SPACE press
.wait_press:
        halt
        ld a, $7F
        in a, ($FE)
        bit 0, a
        jr nz, .wait_press      ; Not pressed - keep waiting

        ret
