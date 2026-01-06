;───────────────────────────────────────
; Draw sound (neutral)
;───────────────────────────────────────
beep_draw:
        ld de, 120
        ld bc, 100
        call play_beep

        ld de, 120
        ld bc, 100
        call play_beep

        ret
