;───────────────────────────────────────
; Victory jingle (ascending)
;───────────────────────────────────────
beep_victory:
        ld de, 200
        ld bc, 100
        call play_beep

        ld de, 150
        ld bc, 100
        call play_beep

        ld de, 100
        ld bc, 150
        call play_beep

        ld de, 75
        ld bc, 200
        call play_beep

        ret
