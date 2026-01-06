;───────────────────────────────────────
; Beep for claiming a cell
;───────────────────────────────────────
beep_claim:
        ld de, 150              ; Medium pitch
        ld bc, 80               ; Short
        call play_beep
        ret
