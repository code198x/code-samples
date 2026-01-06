;───────────────────────────────────────
; Defeat sound (descending)
;───────────────────────────────────────
beep_defeat:
        ld de, 100
        ld bc, 100
        call play_beep

        ld de, 150
        ld bc, 100
        call play_beep

        ld de, 200
        ld bc, 150
        call play_beep

        ld de, 300
        ld bc, 200
        call play_beep

        ret
